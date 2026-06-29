import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/location_snapshot.dart';
import '../repositories/ignored_location_repository.dart';
import 'notification_service.dart';

// Keys for background ↔ UI messaging
const _evtStop = 'stop';
const _evtUpdateAddresses = 'update_addresses';
const _evtParkingDetected = 'parking_detected';
const _evtPayloadKey = 'location';

class MotionService {
  static const minVehicleDurationMs = 20000;
  static const reminderCooldownMs = 10000;

  final _service = FlutterBackgroundService();

  Future<void> initialize() async {
    await _service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: _onStart,
        autoStart: false,
        isForegroundMode: true,
        notificationChannelId: 'parkingson_monitoring',
        initialNotificationTitle: 'Parkingson',
        initialNotificationContent: 'Overvåger din bil...',
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
      prefs.getStringList('selected_car_addresses')?.toSet() ?? {};

  bool btWasConnected = false;
  int? lastReminderMs;

  StreamSubscription? btSub;

  void startBtMonitoring() {
    btSub?.cancel();
    btSub = FlutterBluePlus.events.onConnectionStateChanged.listen((event) async {
      final address = event.device.remoteId.str;
      if (!selectedAddresses.contains(address)) return;

      if (event.connectionState == BluetoothConnectionState.connected) {
        btWasConnected = true;
      } else if (event.connectionState == BluetoothConnectionState.disconnected &&
          btWasConnected) {
        btWasConnected = false;

        // Cooldown check
        final now = DateTime.now().millisecondsSinceEpoch;
        if (lastReminderMs != null &&
            now - lastReminderMs! < MotionService.reminderCooldownMs) {
          return;
        }
        lastReminderMs = now;

        await _handleCarParked(service);
      }
    });
  }

  startBtMonitoring();

  // UI can push updated selected addresses when user changes settings
  service.on(_evtUpdateAddresses).listen((data) {
    selectedAddresses = Set<String>.from(data?['addresses'] ?? []);
    startBtMonitoring();
  });

  service.on(_evtStop).listen((_) {
    btSub?.cancel();
    service.stopSelf();
  });
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
