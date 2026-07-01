import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/widgets.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../l10n/app_localizations.dart';
import '../models/location_snapshot.dart';
import '../models/parking_timer.dart';
import '../repositories/ignored_location_repository.dart';
import 'notification_service.dart';

/// Localizations based on the device locale, for use without a BuildContext.
AppLocalizations _deviceL10n() {
  final device = PlatformDispatcher.instance.locale;
  final match = AppLocalizations.supportedLocales.firstWhere(
    (l) => l.languageCode == device.languageCode,
    orElse: () => const Locale('en'),
  );
  return lookupAppLocalizations(match);
}

// Keys for background ↔ UI messaging
const _evtStop = 'stop';
const _evtUpdateAddresses = 'update_addresses';
const _evtParkingDetected = 'parking_detected';
const _evtPayloadKey = 'location';

class MotionService {
  static const minVehicleDurationMs = 10000;
  // Shared across BT and motion sources so a single parking never fires twice
  // (e.g. BT disconnect + on-foot both detected for the same park).
  static const reminderCooldownMs = 120000;

  final _service = FlutterBackgroundService();

  Future<void> initialize() async {
    final l10n = _deviceL10n();
    await _service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: _onStart,
        autoStart: false,
        isForegroundMode: true,
        notificationChannelId: 'parkingson_monitoring',
        initialNotificationTitle: l10n.monitoringTitle,
        initialNotificationContent: l10n.monitoringBody,
        foregroundServiceNotificationId: 888,
      ),
      iosConfiguration: IosConfiguration(
        autoStart: false,
        onForeground: _onStart,
        onBackground: _onIosBackground,
      ),
    );
  }

  Future<void> startMonitoring({
    required void Function(LocationSnapshot) onParkingDetected,
  }) async {
    await _service.startService();

    // Listen for parking events from the background isolate
    _service.on(_evtParkingDetected).listen((data) {
      final encoded = data?[_evtPayloadKey] as String?;
      if (encoded == null) return;
      final snapshot = LocationSnapshot.decode(encoded);
      if (snapshot != null) onParkingDetected(snapshot);
    });
  }

  Future<void> stopMonitoring() async {
    _service.invoke(_evtStop);
  }

  Future<void> updateAddresses(Set<String> addresses) async {
    _service.invoke(_evtUpdateAddresses, {'addresses': addresses.toList()});
  }

  Future<bool> get isRunning => _service.isRunning();
}

// ── Background isolate entry points ──────────────────────────────────────────

@pragma('vm:entry-point')
Future<bool> _onIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  return true;
}

@pragma('vm:entry-point')
void _onStart(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();

  if (service is AndroidServiceInstance) {
    service.on('setForeground').listen((_) => service.setAsForegroundService());
    service.on('setBackground').listen((_) => service.setAsBackgroundService());
  }

  // Load settings from SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  Set<String> selectedAddresses =
      (prefs.getStringList('selected_car_addresses') ?? [])
          .map((e) => e.toUpperCase())
          .toSet();

  int? lastReminderMs;

  // Fires the parking flow unless we're still within the shared cooldown.
  Future<void> tryFireReminder() async {
    final now = DateTime.now().millisecondsSinceEpoch;
    if (lastReminderMs != null &&
        now - lastReminderMs! < MotionService.reminderCooldownMs) {
      return;
    }
    lastReminderMs = now;
    await _handleCarParked(service);
  }

  // Parking is detected from two native sources, both bridged via
  // SharedPreferences: classic-Bluetooth ACL disconnect (CarBluetoothReceiver)
  // and drive-then-walk motion (ActivityRecognitionReceiver). Baseline the
  // "last seen" markers to now so we don't fire on stale pre-startup events.
  await prefs.reload();
  int lastSeenDisconnectTs = DateTime.now().millisecondsSinceEpoch;
  int lastSeenMotionTs = DateTime.now().millisecondsSinceEpoch;

  Timer.periodic(const Duration(seconds: 3), (_) async {
    await prefs.reload();

    // ── Motion: car without Bluetooth (drove, then started walking) ──────────
    final motionTs = int.tryParse(prefs.getString('motion_parking_event') ?? '');
    if (motionTs != null && motionTs > lastSeenMotionTs) {
      lastSeenMotionTs = motionTs;
      await tryFireReminder();
    }

    // ── Bluetooth: monitored car stereo disconnected ─────────────────────────
    final event = _parseBtEvent(prefs.getString('bt_last_disconnect'));
    if (event == null) return;
    final (address, ts) = event;
    if (ts <= lastSeenDisconnectTs) return;
    lastSeenDisconnectTs = ts;

    if (!selectedAddresses.contains(address.toUpperCase())) return;

    // Debounce: wait a few seconds and make sure the car didn't reconnect
    // (transient drop while still driving).
    await Future.delayed(const Duration(seconds: 5));
    await prefs.reload();
    final reconnect = _parseBtEvent(prefs.getString('bt_last_connect'));
    if (reconnect != null && reconnect.$2 > ts) return;

    await tryFireReminder();
  });

  // Parking timer check — every minute
  Timer.periodic(const Duration(minutes: 1), (_) async {
    await _checkParkingTimer();
  });

  // UI can push updated selected addresses when user changes settings
  service.on(_evtUpdateAddresses).listen((data) {
    selectedAddresses = (List<String>.from(data?['addresses'] ?? []))
        .map((e) => e.toUpperCase())
        .toSet();
  });

  service.on(_evtStop).listen((_) {
    service.stopSelf();
  });
}

/// Parses a "ADDRESS|timestamp" event string written by CarBluetoothReceiver.
(String, int)? _parseBtEvent(String? raw) {
  if (raw == null) return null;
  final i = raw.lastIndexOf('|');
  if (i < 0) return null;
  final ts = int.tryParse(raw.substring(i + 1));
  if (ts == null) return null;
  return (raw.substring(0, i), ts);
}

Future<void> _checkParkingTimer() async {
  final prefs = await SharedPreferences.getInstance();
  final encoded = prefs.getString('parking_timer');
  if (encoded == null) return;

  final timer = ParkingTimer.decode(encoded);
  if (timer == null || timer.isExpired) {
    prefs.remove('parking_timer');
    return;
  }

  Position? position;
  try {
    position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.medium,
        timeLimit: Duration(seconds: 8),
      ),
    );
  } catch (_) {
    return;
  }

  final walkingSeconds = await _osrmWalkingSeconds(
    fromLat: position.latitude,
    fromLon: position.longitude,
    toLat: timer.carLatitude,
    toLon: timer.carLongitude,
  );
  if (walkingSeconds == null) return;

  final bufferSeconds = walkingSeconds + 5 * 60;
  if (timer.remaining.inSeconds <= bufferSeconds) {
    prefs.remove('parking_timer');
    final walkMinutes = (walkingSeconds / 60).ceil();
    await showTimerAlarmFromBackground(walkMinutes: walkMinutes);
  }
}

Future<int?> _osrmWalkingSeconds({
  required double fromLat,
  required double fromLon,
  required double toLat,
  required double toLon,
}) async {
  try {
    final uri = Uri.parse(
      'https://router.project-osrm.org/route/v1/foot/$fromLon,$fromLat;$toLon,$toLat?overview=false',
    );
    final client = HttpClient();
    client.connectionTimeout = const Duration(seconds: 8);
    final request = await client.getUrl(uri);
    final response = await request.close().timeout(const Duration(seconds: 8));
    if (response.statusCode != 200) return null;
    final body = await response.transform(utf8.decoder).join();
    client.close();
    final json = jsonDecode(body) as Map<String, dynamic>;
    final routes = json['routes'] as List?;
    if (routes == null || routes.isEmpty) return null;
    return ((routes[0]['duration'] as num?)?.toDouble() ?? 0).ceil();
  } catch (_) {
    return null;
  }
}

Future<void> _handleCarParked(ServiceInstance service) async {
  // Get current GPS location
  LocationSnapshot? snapshot;
  try {
    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 10),
      ),
    );
    snapshot = LocationSnapshot(
      latitude: position.latitude,
      longitude: position.longitude,
      capturedAtMillis: DateTime.now().millisecondsSinceEpoch,
    );
  } catch (_) {
    // Location unavailable — show reminder without coordinates
  }

  // Check if location is ignored
  if (snapshot != null) {
    final ignoredRepo = IgnoredLocationRepository();
    if (await ignoredRepo.isIgnored(snapshot)) return;
    await ignoredRepo.saveLastParkingLocation(snapshot);
  }

  // Show notification
  await showParkingReminderFromBackground(payload: snapshot?.encode());

  // Notify the UI if it's alive
  service.invoke(_evtParkingDetected, {
    _evtPayloadKey: snapshot?.encode(),
  });
}
