import 'dart:async';
import 'dart:io';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../models/car_device.dart';

class BluetoothService {
  StreamSubscription<BluetoothConnectionState>? _connectionSub;
  StreamSubscription<OnConnectionStateChangedEvent>? _globalSub;

  bool _btActive = false;
  bool get btActive => _btActive;

  /// Returns paired/connected BT devices the user can pick from.
  /// Android: bonded devices list.
  /// iOS: currently connected system devices (no bonded API available).
  Future<List<CarDevice>> getPairedDevices() async {
    final adapterState = await FlutterBluePlus.adapterState
        .firstWhere((s) => s != BluetoothAdapterState.unknown)
        .timeout(const Duration(seconds: 5), onTimeout: () => BluetoothAdapterState.off);
    if (adapterState != BluetoothAdapterState.on) return [];

    try {
      if (Platform.isAndroid) {
        final bonded = await FlutterBluePlus.bondedDevices;
        return bonded
            .map((d) => CarDevice(name: d.platformName, address: d.remoteId.str))
            .toList();
      } else {
        // iOS: return devices currently connected at system level
        final connected = FlutterBluePlus.connectedDevices;
        return connected
            .map((d) => CarDevice(name: d.platformName, address: d.remoteId.str))
            .toList();
      }
    } catch (_) {
      return [];
    }
  }

  /// Monitors connection state of [selectedAddresses].
  /// [onDisconnect] fires when a previously connected selected device disconnects.
  void startMonitoring(
    Set<String> selectedAddresses, {
    required void Function(String deviceAddress) onDisconnect,
  }) {
    _btActive = selectedAddresses.isNotEmpty &&
        FlutterBluePlus.connectedDevices
            .any((d) => selectedAddresses.contains(d.remoteId.str));

    _globalSub = FlutterBluePlus.events.onConnectionStateChanged.listen((event) {
      final address = event.device.remoteId.str;
      if (!selectedAddresses.contains(address)) return;

      if (event.connectionState == BluetoothConnectionState.connected) {
        _btActive = true;
      } else if (event.connectionState == BluetoothConnectionState.disconnected &&
          _btActive) {
        _btActive = false;
        onDisconnect(address);
      }
    });
  }

  void stopMonitoring() {
    _globalSub?.cancel();
    _globalSub = null;
    _connectionSub?.cancel();
    _connectionSub = null;
    _btActive = false;
  }

  void updateSelectedAddresses(Set<String> selectedAddresses) {
    // Re-evaluate btActive based on currently connected devices
    _btActive = selectedAddresses.isNotEmpty &&
        FlutterBluePlus.connectedDevices
            .any((d) => selectedAddresses.contains(d.remoteId.str));
  }
}
