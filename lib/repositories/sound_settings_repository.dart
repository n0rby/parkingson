import 'package:shared_preferences/shared_preferences.dart';

enum SoundMode { phone, app }

/// Stores how loud the alarm/voice plays:
/// - [SoundMode.phone]: follow the phone's alarm volume.
/// - [SoundMode.app]: use the app's own volume, ignoring the phone.
class SoundSettingsRepository {
  static const _keyMode = 'sound_mode';
  static const _keyVolume = 'app_volume';

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  Future<SoundMode> getMode() async {
    final p = await _prefs;
    return p.getString(_keyMode) == 'phone' ? SoundMode.phone : SoundMode.app;
  }

  Future<void> setMode(SoundMode mode) async {
    final p = await _prefs;
    await p.setString(_keyMode, mode == SoundMode.phone ? 'phone' : 'app');
  }

  Future<int> getVolume() async {
    final p = await _prefs;
    return p.getInt(_keyVolume) ?? 100;
  }

  Future<void> setVolume(int volume) async {
    final p = await _prefs;
    await p.setInt(_keyVolume, volume.clamp(0, 100));
  }
}
