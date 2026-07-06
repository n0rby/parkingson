import 'package:speech_to_text/speech_to_text.dart';

/// Thin wrapper around [SpeechToText] for the reminder screen's voice commands.
/// Owns initialisation, a single listen window, and status/error routing.
class VoiceCommandService {
  final SpeechToText _speech = SpeechToText();
  bool _available = false;

  void Function(String text, bool isFinal)? _onResult;
  void Function()? _onDone;

  Future<bool> initialize() async {
    try {
      _available = await _speech.initialize(
        onError: (_) => _onDone?.call(),
        onStatus: (status) {
          if (status == 'done' || status == 'notListening') _onDone?.call();
        },
      );
    } catch (_) {
      _available = false;
    }
    return _available;
  }

  bool get isAvailable => _available;
  bool get isListening => _speech.isListening;

  /// Starts a single listen window. [onResult] fires for partial and final
  /// results; [onDone] fires once listening has ended (may fire more than once,
  /// so the caller should guard).
  Future<void> listen({
    required void Function(String text, bool isFinal) onResult,
    required void Function() onDone,
    String? localeId,
  }) async {
    if (!_available) return;
    _onResult = onResult;
    _onDone = onDone;
    await _speech.listen(
      onResult: (r) => _onResult?.call(r.recognizedWords, r.finalResult),
      listenOptions: SpeechListenOptions(
        partialResults: true,
        cancelOnError: true,
        listenMode: ListenMode.dictation,
        localeId: localeId,
        listenFor: const Duration(seconds: 15),
        pauseFor: const Duration(seconds: 4),
      ),
    );
  }

  Future<void> stop() async {
    try {
      await _speech.stop();
    } catch (_) {}
  }

  Future<void> cancel() async {
    try {
      await _speech.cancel();
    } catch (_) {}
  }
}
