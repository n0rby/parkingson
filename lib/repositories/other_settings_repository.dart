import 'package:shared_preferences/shared_preferences.dart';

/// "Andet" (Other) settings.
class OtherSettingsRepository {
  // Read natively by ActivityRecognitionReceiver (flutter.motion_fallback_seconds).
  static const _keyFallbackSeconds = 'motion_fallback_seconds';

  /// Default fallback window: 2 minutes.
  static const defaultFallbackSeconds = 120;

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  Future<int> getMotionFallbackSeconds() async {
    final p = await _prefs;
    return p.getInt(_keyFallbackSeconds) ?? defaultFallbackSeconds;
  }

  Future<void> setMotionFallbackSeconds(int seconds) async {
    final p = await _prefs;
    await p.setInt(_keyFallbackSeconds, seconds);
  }
}
