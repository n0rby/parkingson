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
const _evtUpdateUsbAccessories = 'update_usb_accessories';
const _evtParkingDetected = 'parking_detected';
const _evtPayloadKey = 'location';

class MotionService {
  // Motion fallback guard: the phone must actually have moved during the
  // "drive" before a motion-only parking counts — protects against Activity
  // Recognition's occasional false IN_VEHICLE while sitting still.
  static const minDriveDistanceMeters = 250.0;
  // A drive segment is forgotten if IN_VEHICLE hasn't been seen for this long.
  static const driveResetMs = 10 * 60 * 1000;
  // Dedup so a single parking never alarms twice when several sources (BT, USB,
  // motion) report it. A repeat is treated as the *same* park only if it is BOTH
  // very recent AND at ~the same spot as the last one.
  static const dedupCooldownMs = 20000; // 20 s
  static const dedupRadiusMeters = 30.0; // 30 m

  // A car connection must last at least this long to count as a real drive
  // (not a momentary pair/unpair in the driveway). The connection's *duration*
  // is our steadiest "was driving" evidence — far more reliable than Activity
  // Recognition.
  static const minDriveConnectionMs = 90 * 1000;

  // How recently Activity Recognition must have seen IN_VEHICLE for it to count
  // as corroboration. Generous on purpose: AR is laggy/unstable, so it only
  // ever *raises* confidence here — it never gates.
  static const inVehicleWindowMs = 10 * 60 * 1000;

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
    required void Function(LocationSnapshot? location) onParkingDetected,
  }) async {
    await _service.startService();

    // Listen for parking events from the background isolate. A null location
    // means parking was detected but no GPS fix was available (e.g. an
    // underground car park) — the reminder still opens so the alarm can be
    // stopped, just without the location-specific actions.
    _service.on(_evtParkingDetected).listen((data) {
      final encoded = data?[_evtPayloadKey] as String?;
      onParkingDetected(encoded == null ? null : LocationSnapshot.decode(encoded));
    });
  }

  Future<void> stopMonitoring() async {
    _service.invoke(_evtStop);
  }

  Future<void> updateAddresses(Set<String> addresses) async {
    _service.invoke(_evtUpdateAddresses, {'addresses': addresses.toList()});
  }

  Future<void> updateUsbAccessories(Set<String> accessories) async {
    _service.invoke(
        _evtUpdateUsbAccessories, {'accessories': accessories.toList()});
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
  Set<String> selectedUsbAccessories =
      (prefs.getStringList('selected_usb_accessories') ?? [])
          .map((e) => e.toUpperCase())
          .toSet();

  // Fires the parking flow. Duplicate suppression (the same park reported by
  // several sources) is handled by location + time in _handleCarParked.
  // [requireMovement]/[driveStart] apply only to the motion source, so a false
  // IN_VEHICLE while stationary (zero displacement) doesn't alarm.
  Future<void> tryFireReminder(
      {bool requireMovement = false, LocationSnapshot? driveStart}) async {
    await _handleCarParked(service,
        requireMovement: requireMovement, driveStart: driveStart);
  }

  // Where the current drive segment began (last known position when IN_VEHICLE
  // was first seen), used for the motion displacement check.
  LocationSnapshot? driveStartLoc;
  int lastInVehicleTs = 0;

  // Parking is detected from several native sources, all bridged via
  // SharedPreferences: classic-Bluetooth ACL disconnect (CarBluetoothReceiver),
  // USB car head-unit unplug (CarUsbReceiver), USB power drop (PowerReceiver),
  // and drive-then-walk motion (ActivityRecognitionReceiver). Each is a crisp
  // "leaving" trigger; how much corroboration it needs before we sound the loud
  // alarm is decided per-trigger in [_shouldFire]. Baseline every source to now
  // so we don't fire on stale pre-startup events.
  await prefs.reload();
  final startTs = DateTime.now().millisecondsSinceEpoch;
  final lastSeen = <String, int>{
    'bt': startTs,
    'usbAcc': startTs,
    'usbPower': startTs,
    'motion': startTs,
    'fallback': startTs,
  };

  Timer.periodic(const Duration(seconds: 3), (_) async {
    await prefs.reload();
    final now = DateTime.now().millisecondsSinceEpoch;

    // Returns a fresh (id, ts) disconnect for [source], advancing its marker,
    // or null if nothing new. Reuses the "value|timestamp" event format.
    (String, int)? takeFresh(String source, String key) {
      final ev = _parseBtEvent(prefs.getString(key));
      if (ev == null || ev.$2 <= lastSeen[source]!) return null;
      lastSeen[source] = ev.$2;
      return ev;
    }

    // Debounce a connection trigger: wait, then confirm it didn't reconnect
    // (a transient drop while still driving).
    Future<bool> stillDisconnected(String connectKey, int disconnectTs) async {
      await Future.delayed(const Duration(seconds: 5));
      await prefs.reload();
      final reconnect = _parseBtEvent(prefs.getString(connectKey));
      return reconnect == null || reconnect.$2 <= disconnectTs;
    }

    // Soft corroboration: did Activity Recognition see IN_VEHICLE recently?
    // Mirrored to the Flutter store by ActivityRecognitionReceiver. Never a gate.
    final inVehicleAt = int.tryParse(prefs.getString('last_in_vehicle_at') ?? '');
    final inVehicleRecent = inVehicleAt != null &&
        now - inVehicleAt <= MotionService.inVehicleWindowMs;

    // Remember where a drive segment began (its start position), so the motion
    // park can verify the phone actually moved. A brief stop keeps refreshing
    // last_in_vehicle_at; a long gap forgets the segment.
    if (inVehicleAt != null && inVehicleAt > lastInVehicleTs) {
      if (driveStartLoc == null) {
        try {
          final p = await Geolocator.getLastKnownPosition();
          if (p != null) {
            driveStartLoc = LocationSnapshot(
              latitude: p.latitude,
              longitude: p.longitude,
              capturedAtMillis: inVehicleAt,
            );
          }
        } catch (_) {}
      }
      lastInVehicleTs = inVehicleAt;
    } else if (driveStartLoc != null &&
        now - lastInVehicleTs > MotionService.driveResetMs) {
      driveStartLoc = null;
    }

    // ── Motion: drove, then left the vehicle (Activity Recognition) ──────────
    // motion_parking_event is a bare timestamp (no "id|ts"), so it needs its
    // own parse rather than takeFresh/_parseBtEvent.
    final motionTs = int.tryParse(prefs.getString('motion_parking_event') ?? '');
    if (motionTs != null && motionTs > lastSeen['motion']!) {
      lastSeen['motion'] = motionTs;
      if (_shouldFire(
          trigger: _Trigger.motion,
          connectionDurationMs: null,
          inVehicleRecent: inVehicleRecent)) {
        await tryFireReminder(requireMovement: true, driveStart: driveStartLoc);
      }
      driveStartLoc = null; // consumed for this drive segment
    }

    // ── Motion fallback (drove, then stayed STILL/UNKNOWN — never walked) ─────
    // Low-confidence, so only for users with NO BT/USB car (they rely purely on
    // motion). BT/USB users get their reliable trigger instead and never see it.
    final fallbackTs = int.tryParse(prefs.getString('motion_fallback_event') ?? '');
    if (fallbackTs != null && fallbackTs > lastSeen['fallback']!) {
      lastSeen['fallback'] = fallbackTs;
      final hasConnectedCar =
          selectedAddresses.isNotEmpty || selectedUsbAccessories.isNotEmpty;
      if (!hasConnectedCar &&
          _shouldFire(
              trigger: _Trigger.motion,
              connectionDurationMs: null,
              inVehicleRecent: inVehicleRecent)) {
        await tryFireReminder(requireMovement: true, driveStart: driveStartLoc);
      }
      driveStartLoc = null;
    }

    // ── Bluetooth: monitored car stereo disconnected (high trust) ────────────
    final bt = takeFresh('bt', 'bt_last_disconnect');
    if (bt != null && selectedAddresses.contains(bt.$1.toUpperCase())) {
      if (await stillDisconnected('bt_last_connect', bt.$2) &&
          _shouldFire(
              trigger: _Trigger.btWhitelisted,
              connectionDurationMs: _connectionDurationMs(
                  prefs.getString('bt_last_connect'), bt.$2),
              inVehicleRecent: inVehicleRecent)) {
        await tryFireReminder();
      }
    }

    // ── USB accessory: monitored car head unit unplugged (high trust) ────────
    final usbAcc = takeFresh('usbAcc', 'usb_last_disconnect');
    if (usbAcc != null &&
        selectedUsbAccessories.contains(usbAcc.$1.toUpperCase())) {
      if (await stillDisconnected('usb_last_connect', usbAcc.$2) &&
          _shouldFire(
              trigger: _Trigger.usbAccessory,
              connectionDurationMs: _connectionDurationMs(
                  prefs.getString('usb_last_connect'), usbAcc.$2),
              inVehicleRecent: inVehicleRecent)) {
        await tryFireReminder();
      }
    }

    // ── USB power: a plain charge cable dropped (low trust → needs evidence) ──
    final usbPwr = takeFresh('usbPower', 'usbpower_last_disconnect');
    if (usbPwr != null) {
      if (await stillDisconnected('usbpower_last_connect', usbPwr.$2) &&
          _shouldFire(
              trigger: _Trigger.usbPower,
              connectionDurationMs: _connectionDurationMs(
                  prefs.getString('usbpower_last_connect'), usbPwr.$2),
              inVehicleRecent: inVehicleRecent)) {
        await tryFireReminder();
      }
    }
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

  // Same, for the USB car head units registered during setup.
  service.on(_evtUpdateUsbAccessories).listen((data) {
    selectedUsbAccessories = (List<String>.from(data?['accessories'] ?? []))
        .map((e) => e.toUpperCase())
        .toSet();
  });

  service.on(_evtStop).listen((_) {
    service.stopSelf();
  });
}

/// Parses a "value|timestamp" event string written by the native receivers
/// (CarBluetoothReceiver, CarUsbReceiver, PowerReceiver).
(String, int)? _parseBtEvent(String? raw) {
  if (raw == null) return null;
  final i = raw.lastIndexOf('|');
  if (i < 0) return null;
  final ts = int.tryParse(raw.substring(i + 1));
  if (ts == null) return null;
  return (raw.substring(0, i), ts);
}

/// The trigger sources that can start a parking reminder, ordered by how much
/// we trust them on their own.
enum _Trigger { btWhitelisted, usbAccessory, usbPower, motion }

/// The *soft* decision: is this event trustworthy enough to sound the loud
/// reminder? The hard suppression (ignored location) still happens later in
/// [_handleCarParked] — this only stops the weak triggers from firing on noise.
///
/// Principle: unreliable signals (Activity Recognition, GPS) may only *raise*
/// confidence, never gate — otherwise the flakiest signal decides our misses.
bool _shouldFire({
  required _Trigger trigger,
  required int? connectionDurationMs,
  required bool inVehicleRecent,
}) {
  // Independent evidence we were actually driving.
  final droveLongEnough = connectionDurationMs != null &&
      connectionDurationMs >= MotionService.minDriveConnectionMs;
  final drivingEvidence = droveLongEnough || inVehicleRecent;

  switch (trigger) {
    // Self-identifying / high trust: the whitelisted car (BT) or a monitored
    // car head unit (USB accessory) was connected and dropped. Fire on that
    // alone, as BT does today; the ignored-location check is the only guard.
    case _Trigger.btWhitelisted:
    case _Trigger.usbAccessory:
      return true;

    // Activity Recognition already required IN_VEHICLE >= 10s before writing
    // this event, so it carries its own driving evidence.
    case _Trigger.motion:
      return true;

    // Ambiguous: a plain USB power drop fires for *every* charger. Demand
    // independent driving evidence before we dare sound the alarm.
    case _Trigger.usbPower:
      return drivingEvidence;
  }
}

/// Duration of the just-ended connection, from its matching connect event, or
/// null if we never saw a connect (so we can't prove a drive).
int? _connectionDurationMs(String? connectRaw, int disconnectTs) {
  final connect = _parseBtEvent(connectRaw);
  if (connect == null) return null;
  final connectedAt = connect.$2;
  if (connectedAt <= 0 || connectedAt >= disconnectTs) return null;
  return disconnectTs - connectedAt;
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

Future<void> _handleCarParked(ServiceInstance service,
    {bool requireMovement = false, LocationSnapshot? driveStart}) async {
  final ignoredRepo = IgnoredLocationRepository();

  // For duplicate suppression: the last parking we actually reminded about.
  final lastPark = await ignoredRepo.getLastParkingLocation();
  final recentPark = lastPark != null &&
      DateTime.now().millisecondsSinceEpoch - lastPark.capturedAtMillis <
          MotionService.dedupCooldownMs;

  // Get the best location we can: a fresh GPS fix, else a recent cached fix.
  Position? position;
  try {
    position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 10),
      ),
    );
  } catch (_) {
    // GPS unavailable (often indoors) — fall back to a recent cached fix so we
    // can still check ignored locations.
    try {
      final last = await Geolocator.getLastKnownPosition();
      if (last != null &&
          DateTime.now().difference(last.timestamp).inMinutes <= 2) {
        position = last;
      }
    } catch (_) {}
  }

  // Motion displacement guard: a real drive covers ground, but Activity
  // Recognition sometimes reports a false IN_VEHICLE while you sit still. If we
  // know where the "drive" started and the phone hasn't actually moved, it
  // wasn't a real trip — don't alarm. (Only motion sets requireMovement; BT/USB
  // are trusted "left the car" events.)
  if (requireMovement && driveStart != null && position != null) {
    final moved = Geolocator.distanceBetween(
      driveStart.latitude,
      driveStart.longitude,
      position.latitude,
      position.longitude,
    );
    if (moved < MotionService.minDriveDistanceMeters) return;
  }

  // Dedup: the same parking hit by BT + USB + motion fires within moments and
  // ~the same spot. Treat it as a repeat only if it's BOTH recent AND near the
  // last park (or recent and we can't verify the location).
  if (recentPark) {
    if (position == null) return;
    final metersFromLast = Geolocator.distanceBetween(
      position.latitude,
      position.longitude,
      lastPark.latitude,
      lastPark.longitude,
    );
    if (metersFromLast < MotionService.dedupRadiusMeters) return;
  }

  if (position == null) {
    // We can't verify the location. Don't risk a false alarm inside an ignored
    // area (home/work); only remind if the user has no ignored locations.
    if ((await ignoredRepo.getIgnoredLocations()).isNotEmpty) return;
    await showParkingReminderFromBackground();
    service.invoke(_evtParkingDetected, {_evtPayloadKey: null});
    return;
  }

  final snapshot = LocationSnapshot(
    latitude: position.latitude,
    longitude: position.longitude,
    capturedAtMillis: DateTime.now().millisecondsSinceEpoch,
  );

  // Skip ignored locations (home, work, ...).
  if (await ignoredRepo.isIgnored(snapshot)) return;
  await ignoredRepo.saveLastParkingLocation(snapshot);

  await showParkingReminderFromBackground(payload: snapshot.encode());
  service.invoke(_evtParkingDetected, {_evtPayloadKey: snapshot.encode()});
}
