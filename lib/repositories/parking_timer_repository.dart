import 'package:shared_preferences/shared_preferences.dart';
import '../models/parking_timer.dart';

class ParkingTimerRepository {
  static const _key = 'parking_timer';

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  Future<ParkingTimer?> getActiveTimer() async {
    final p = await _prefs;
    final encoded = p.getString(_key);
    if (encoded == null) return null;
    final timer = ParkingTimer.decode(encoded);
    if (timer == null || timer.isExpired) {
      await clearTimer();
      return null;
    }
    return timer;
  }

  Future<void> setTimer(ParkingTimer timer) async {
    final p = await _prefs;
    await p.setString(_key, timer.encode());
  }

  Future<void> clearTimer() async {
    final p = await _prefs;
    await p.remove(_key);
  }
}
