import 'package:shared_preferences/shared_preferences.dart';
import '../models/monitoring_mode.dart';

class CarRepository {
  static const _keySelectedAddresses = 'selected_car_addresses';
  static const _keySelectedUsbAccessories = 'selected_usb_accessories';
  static const _keyMonitoringMode = 'monitoring_mode';
  static const _keySetupCompleted = 'setup_completed';
  static const _keyBtOnlyMode = 'bt_only_mode';
  // True once the user has toggled the "monitor BT/USB cars only" checkbox
  // themselves. Until then the app manages it as a smart default (on when at
  // least one BT/USB car exists); after that we respect the user's choice.
  static const _keyBtOnlyUserSet = 'bt_only_user_set';

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  Future<Set<String>> getSelectedCarAddresses() async {
    final p = await _prefs;
    return p.getStringList(_keySelectedAddresses)?.toSet() ?? {};
  }

  Future<void> saveSelectedCarAddresses(Set<String> addresses) async {
    final p = await _prefs;
    await p.setStringList(_keySelectedAddresses, addresses.toList());
  }

  Future<Set<String>> getSelectedUsbAccessories() async {
    final p = await _prefs;
    return p.getStringList(_keySelectedUsbAccessories)?.toSet() ?? {};
  }

  Future<void> saveSelectedUsbAccessories(Set<String> accessories) async {
    final p = await _prefs;
    await p.setStringList(_keySelectedUsbAccessories, accessories.toList());
  }

  Future<MonitoringMode> getMonitoringMode() async {
    final p = await _prefs;
    return p.getString(_keyMonitoringMode) == MonitoringMode.motion.name
        ? MonitoringMode.motion
        : MonitoringMode.bluetooth;
  }

  Future<void> saveMonitoringMode(MonitoringMode mode) async {
    final p = await _prefs;
    await p.setString(_keyMonitoringMode, mode.name);
  }

  Future<bool> isSetupCompleted() async {
    final p = await _prefs;
    return p.getBool(_keySetupCompleted) ?? false;
  }

  Future<void> saveSetupCompleted(bool completed) async {
    final p = await _prefs;
    await p.setBool(_keySetupCompleted, completed);
  }

  Future<bool> getBtOnlyMode() async {
    final p = await _prefs;
    return p.getBool(_keyBtOnlyMode) ?? false;
  }

  Future<void> saveBtOnlyMode(bool enabled) async {
    final p = await _prefs;
    await p.setBool(_keyBtOnlyMode, enabled);
  }

  Future<bool> getBtOnlyModeUserSet() async {
    final p = await _prefs;
    return p.getBool(_keyBtOnlyUserSet) ?? false;
  }

  Future<void> saveBtOnlyModeUserSet(bool userSet) async {
    final p = await _prefs;
    await p.setBool(_keyBtOnlyUserSet, userSet);
  }

  Future<bool> isSelectedCar(String address) async {
    return (await getSelectedCarAddresses()).contains(address);
  }
}
