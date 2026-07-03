import 'package:shared_preferences/shared_preferences.dart';

enum SoundMode { phone, app }

/// Stores how loud the alarm/voice plays:
/// - [SoundMode.phone]: follow the phone's alarm volume.
/// - [SoundMode.app]: use the app's own volume, ignoring the phone.
class SoundSettingsRepository {
  static const _keyMode = 'sound_mode';
  static const _keyVolume = 'app_volume';
  static const _keyVibrateInDnd = 'vibrate_in_dnd';
  static const _keyVibrateWhenSilent = 'vibrate_when_silent';

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  Future<bool> getVibrateInDnd() async {
    final p = await _prefs;
    return p.getBool(_keyVibrateInDnd) ?? true;
  }

  Future<void> setVibrateInDnd(bool value) async {
    final p = await _prefs;
    await p.setBool(_keyVibrateInDnd, value);
  }

  Future<bool> getVibrateWhenSilent() async {
    final p = await _prefs;
    return p.getBool(_keyVibrateWhenSilent) ?? true;
  }

  Future<void> setVibrateWhenSilent(bool value) async {
    final p = await _prefs;
    await p.setBool(_keyVibrateWhenSilent, value);
  }

  Future<SoundMode> getMode() async {
    final p = await _prefs;
    // Default: follow the phone's volume (don't override the phone's setting).
    return p.getString(_keyMode) == 'app' ? SoundMode.app : SoundMode.phone;
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
