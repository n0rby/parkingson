import 'dart:io';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../models/car_device.dart';

/// Provides the list of pairable Bluetooth devices for the car picker.
///
/// Connection *monitoring* is handled natively (see CarBluetoothReceiver) via
/// classic Bluetooth ACL events, so this service only exposes the device list.
class BluetoothService {
  /// Returns paired/connected BT devices the user can pick from.
  /// Android: bonded devices list (includes classic car stereos and BLE).
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
}
