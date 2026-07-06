import 'package:flutter/services.dart';

/// Captures a spoken phrase using the Android system speech recognizer
/// (RecognizerIntent). Each call is a fresh recognition — no reused-recognizer
/// bug — and the OS handles microphone/Bluetooth routing itself.
class VoiceCommandService {
  static const _channel = MethodChannel('dk.parkingson/alarm');

  /// Launches the system recognizer and returns its candidate transcriptions
  /// (best first). Empty if the user cancelled or nothing was recognised.
  Future<List<String>> capture({String? locale}) async {
    try {
      final result =
          await _channel.invokeMethod('startVoiceCapture', {'locale': locale});
      if (result is List) {
        return result.map((e) => e.toString()).where((s) => s.isNotEmpty).toList();
      }
      return const [];
    } catch (_) {
      return const [];
    }
  }
}
