// TODO: Implement using flutter_blue_plus
// Mirrors BluetoothMonitorService.kt from the Android version.
// On connect to a selected car: set btActive = true, trigger reminder flow.
// On disconnect: set btActive = false, show parking reminder.
import '../models/car_device.dart';

class BluetoothService {
  bool _btActive = false;
  bool get btActive => _btActive;

  Future<List<CarDevice>> getPairedDevices() async {
    // TODO: Use FlutterBluePlus.bondedDevices (Android)
    // or scan for known peripherals (iOS via CoreBluetooth)
    return [];
  }

  void startMonitoring(Set<String> selectedAddresses, {required Function onDisconnect}) {
    // TODO: Listen to FlutterBluePlus connection events
  }

  void stopMonitoring() {
    // TODO: Cancel subscription
  }

  void setBtActive(bool active) {
    _btActive = active;
  }
}
