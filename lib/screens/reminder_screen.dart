import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../l10n/app_localizations.dart';
import '../models/ignored_location.dart';
import '../models/location_snapshot.dart';
import '../models/parking_timer.dart';
import '../repositories/parking_timer_repository.dart';
import '../services/voice_command_parser.dart';
import '../services/voice_command_service.dart';
import '../theme.dart';
import '../widgets/parking_app_buttons.dart';
import '../widgets/parking_timer_selector.dart';
import '../widgets/screen_scaffold.dart';

enum _VoiceState { idle, listening, timerSet, notUnderstood }

class ReminderScreen extends StatefulWidget {
  // Null when parking was detected without a GPS fix (e.g. an underground car
  // park). The reminder still opens so the alarm can be stopped; the
  // location-specific "ignore here" action is hidden.
  final LocationSnapshot? parkingLocation;
  final VoidCallback onAddIgnoredLocation;
  final VoidCallback onDismiss;

  const ReminderScreen({
    super.key,
    required this.parkingLocation,
    required this.onAddIgnoredLocation,
    required this.onDismiss,
  });

  @override
  State<ReminderScreen> createState() => _ReminderScreenState();
}

class _ReminderScreenState extends State<ReminderScreen> {
  final _voice = VoiceCommandService();
  final _timerRepo = ParkingTimerRepository();
  final _tts = FlutterTts();

  _VoiceState _voiceState = _VoiceState.idle;
  String _heardText = '';
  Duration? _setDuration;
  bool _capturing = false;
  // Let the alarm siren play once before the reminder silences it.
  bool _sirenPlayed = false;
  // When the phone is silenced (silent/vibrate ringer, DND, or the alarm is
  // muted), the native alarm only vibrates — so the reminder screen stays silent
  // too and never speaks aloud. Set once when the screen opens.
  bool _phoneSilenced = false;
  // If the user doesn't react (speak or tap a button) within this window, the
  // reminder stops listening and closes itself. Just this one timer.
  // TODO: pause this while a confirmation is being spoken instead of relying on
  // the window being long enough.
  static const _noResponseTimeout = Duration(seconds: 20);
  Timer? _idleTimeout;

  // Forces the timer selector to reload after a voice-set timer so its UI
  // reflects the spoken duration.
  int _timerKey = 0;
  bool _timerLoadExisting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startVoice());
  }

  @override
  void dispose() {
    _idleTimeout?.cancel();
    _tts.stop();
    super.dispose();
  }

  /// (Re)starts the no-response countdown. Called whenever the user does
  /// something (speaks a command, taps anywhere). The countdown also runs
  /// through the announce + listen phase, so a recognizer that never returns
  /// is torn down instead of listening forever.
  void _bumpIdleTimeout() {
    _idleTimeout?.cancel();
    _idleTimeout = Timer(_noResponseTimeout, _autoDismiss);
  }

  /// No reaction in time: stop the spoken reminder, stop listening, stop any
  /// lingering alarm sound/vibration, and close the reminder.
  Future<void> _autoDismiss() async {
    _idleTimeout?.cancel();
    const channel = MethodChannel('dk.parkingson/alarm');
    try {
      await _tts.stop();
    } catch (_) {}
    try {
      await channel.invokeMethod('cancelVoiceCapture');
    } catch (_) {}
    try {
      await channel.invokeMethod('stopAlarm');
    } catch (_) {}
    if (mounted) widget.onDismiss();
  }

  // Sequence: stop the alarm → speak the reminder to completion → then listen
  // for a command. Listening auto-closes after 15 s if nothing is recognised.
  Future<void> _startVoice() async {
    if (_capturing) return;
    _capturing = true;
    _bumpIdleTimeout();
    const channel = MethodChannel('dk.parkingson/alarm');

    // Mirror the native alarm: if the phone is silenced, don't speak aloud.
    try {
      _phoneSilenced = await channel.invokeMethod('isVoiceSuppressed') == true;
    } catch (_) {}

    // Cancel the native spoken reminder right away (the siren keeps playing).
    // Otherwise, if a screen lock delays this screen past the native voice's
    // trigger, both it and the announcement below play and you hear it twice.
    try {
      await channel.invokeMethod('stopAlarmVoice');
    } catch (_) {}

    // Non-silenced: let the alarm siren actually play before we silence it. When
    // the reminder opens instantly (device unlocked), stopping it right away
    // kills the siren before it's even audible — you'd only hear the spoken
    // reminder. Wait once (~the siren's length, and before the native voice at
    // 3.3 s), then stop it so the announcement below isn't captured.
    //
    // Silenced phone: there is no siren, only the vibration pulse. Don't stop it
    // here — let it keep buzzing so the user notices even in a pocket. It's
    // stopped just below once they engage (unlock), and is bounded by the
    // no-response timeout and the native 30 s safety stop.
    if (!_phoneSilenced) {
      if (!_sirenPlayed) {
        _sirenPlayed = true;
        await Future.delayed(const Duration(milliseconds: 2500));
        if (!mounted) {
          _capturing = false;
          return;
        }
      }
      try {
        await channel.invokeMethod('stopAlarm');
      } catch (_) {}
    }

    // Speech recognition needs an unlocked device (Android privacy rule). If the
    // full-screen alarm launched us over the lock screen, bring up the unlock
    // prompt first; a single biometric scan flows straight into listening.
    try {
      final locked = await channel.invokeMethod('isDeviceLocked') == true;
      if (locked) {
        final unlocked = await channel.invokeMethod('requestUnlock') == true;
        if (!unlocked) {
          _capturing = false;
          if (mounted) setState(() => _voiceState = _VoiceState.idle);
          return;
        }
        // Let the activity fully resume after the keyguard dismiss before we
        // speak — TTS fired too eagerly right after unlock can be dropped.
        await Future.delayed(const Duration(milliseconds: 500));
        if (!mounted) {
          _capturing = false;
          return;
        }
      }
    } catch (_) {}

    // Silenced phone: the pulse kept buzzing so the user would feel it. Now that
    // they've engaged (unlocked the phone, or it was already open), stop it.
    if (_phoneSilenced) {
      try {
        await channel.invokeMethod('stopAlarmVibration');
      } catch (_) {}
    }

    // 1) Speak "remember parking" and wait for it to finish.
    await _announce();
    if (!mounted) {
      _capturing = false;
      return;
    }

    // 2) Then listen. The no-response countdown from _bumpIdleTimeout keeps
    // running, so if nothing is recognised the screen closes on its own.
    setState(() => _voiceState = _VoiceState.listening);

    final locale = Localizations.localeOf(context).toLanguageTag();
    final candidates = await _voice.capture(locale: locale);
    _capturing = false;
    if (!mounted) return;
    await _handle(candidates);
  }

  /// Speaks the parking reminder and returns only once it has finished, so it
  /// is never picked up by the recognizer.
  Future<void> _announce() async {
    if (!mounted) return;
    // Silenced phone → vibrate-only alarm → no spoken reminder either.
    if (_phoneSilenced) return;
    final text = AppLocalizations.of(context).ttsRemember;
    final tag = Localizations.localeOf(context).toLanguageTag();
    try {
      await _tts.setLanguage(tag);
      await _tts.awaitSpeakCompletion(true);
      await _tts.speak(text);
    } catch (_) {}
  }

  // Pauses the no-response timer while a confirmation is spoken so it can't cut
  // the announcement off, then restarts the full window afterwards (or lets the
  // screen navigate away).
  Future<void> _handle(List<String> candidates) async {
    final command = classifyBestOf(candidates);
    switch (command.type) {
      case VoiceCommandType.ignoreLocation:
        _idleTimeout?.cancel(); // paused; we navigate away after confirming
        await _speak(AppLocalizations.of(context).voiceIgnoreConfirm);
        if (!mounted) return;
        widget.onAddIgnoredLocation();
        break;
      case VoiceCommandType.setDuration:
        _idleTimeout?.cancel(); // paused while confirming
        await _applyDuration(command.duration!);
        if (mounted) _bumpIdleTimeout(); // full window starts after the confirmation
        break;
      case VoiceCommandType.none:
        _bumpIdleTimeout();
        setState(() {
          _heardText = candidates.isEmpty ? '' : candidates.first;
          // Nothing heard (cancelled) → back to idle; heard-but-unmatched →
          // show the "didn't understand" hint with a retry.
          _voiceState =
              candidates.isEmpty ? _VoiceState.idle : _VoiceState.notUnderstood;
        });
        break;
    }
  }

  Future<void> _applyDuration(Duration d) async {
    await _timerRepo.setTimer(ParkingTimer(
      expiresAt: DateTime.now().add(d),
      carLatitude: widget.parkingLocation?.latitude ?? 0,
      carLongitude: widget.parkingLocation?.longitude ?? 0,
    ));
    if (!mounted) return;
    final l10n = AppLocalizations.of(context);
    setState(() {
      _setDuration = d;
      _voiceState = _VoiceState.timerSet;
      _timerLoadExisting = true;
      _timerKey++; // rebuild the selector so it reloads the active timer
    });
    // Awaited so the no-response timer stays paused until the confirmation ends.
    await _speak(l10n.voiceTimerSet(_formatDuration(d, l10n)));
  }

  /// Speaks a confirmation and returns only once it has finished, so the
  /// no-response timer can stay paused for exactly as long as we're talking.
  Future<void> _speak(String text) async {
    // Silenced phone → stay silent for spoken confirmations too.
    if (_phoneSilenced) return;
    try {
      final tag = Localizations.localeOf(context).toLanguageTag();
      await _tts.setLanguage(tag);
      await _tts.awaitSpeakCompletion(true);
    } catch (_) {}
    try {
      await _tts.stop();
      await _tts.speak(text);
    } catch (_) {}
  }

  // Spelled-out form for the spoken + on-screen confirmation ("5 minutter", not
  // "5 min") so it reads naturally aloud. The compact "min" form stays on the
  // timer-selector chips.
  String _formatDuration(Duration d, AppLocalizations l10n) {
    if (d.inMinutes < 60) return l10n.spokenMinutes(d.inMinutes);
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    if (m == 0) return l10n.spokenHours(h);
    return l10n.spokenHoursAndMinutes(l10n.spokenHours(h), l10n.spokenMinutes(m));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    // Any tap anywhere counts as "the user reacted" and restarts the countdown.
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) => _bumpIdleTimeout(),
      child: ScreenScaffold(
      title: l10n.reminderTitle,
      children: [
        Text(
          l10n.reminderBody,
          style: const TextStyle(fontSize: 16, color: hpText, height: 1.5),
        ),
        const SizedBox(height: 16),
        _VoicePanel(
          state: _voiceState,
          heardText: _heardText,
          setDuration: _setDuration == null
              ? null
              : _formatDuration(_setDuration!, l10n),
          onSpeak: _startVoice,
        ),
        const SizedBox(height: 16),
        const ParkingAppButtons(),
        // "Ignore here" only makes sense with a known location.
        if (widget.parkingLocation != null) ...[
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: widget.onAddIgnoredLocation,
              child: Text(l10n.ignoreThisLocation),
            ),
          ),
        ],

        // ── Parking timer ─────────────────────────────────────────────────
        const SizedBox(height: 16),
        ParkingTimerSelector(
          key: ValueKey(_timerKey),
          carLatitude: widget.parkingLocation?.latitude ?? 0,
          carLongitude: widget.parkingLocation?.longitude ?? 0,
          loadExisting: _timerLoadExisting,
        ),

        const SizedBox(height: 8),
        TextButton(
          onPressed: widget.onDismiss,
          child: Text(l10n.close),
        ),
        const SizedBox(height: 12),
        Text(
          l10n.ignoreHint(ignoredLocationRadiusMeters.toInt()),
          style: const TextStyle(color: hpMuted, fontSize: 13, height: 1.5),
        ),
      ],
      ),
    );
  }
}

/// The voice-command status card at the top of the reminder screen.
class _VoicePanel extends StatelessWidget {
  final _VoiceState state;
  final String heardText;
  final String? setDuration;
  final VoidCallback onSpeak;

  const _VoicePanel({
    required this.state,
    required this.heardText,
    required this.setDuration,
    required this.onSpeak,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    late final IconData icon;
    late final Color color;
    late final String title;
    String? subtitle;
    // Spoken-command examples, shown while listening and after a miss so the
    // user learns what to say (idle already shows them as the title).
    String? examplesLine;
    var tappable = false;
    switch (state) {
      case _VoiceState.idle:
        icon = Icons.mic_none;
        color = hpTeal;
        title = l10n.voicePrompt;
        tappable = true;
        break;
      case _VoiceState.listening:
        icon = Icons.mic;
        color = hpTeal;
        title = l10n.voiceListening;
        examplesLine = l10n.voicePrompt;
        break;
      case _VoiceState.timerSet:
        icon = Icons.check_circle;
        color = hpTeal;
        title = l10n.voiceTimerSet(setDuration ?? '');
        break;
      case _VoiceState.notUnderstood:
        icon = Icons.help_outline;
        color = hpOrange;
        title = l10n.voiceNotUnderstood;
        subtitle = heardText.isEmpty ? null : '"$heardText"';
        examplesLine = l10n.voicePrompt;
        tappable = true;
        break;
    }

    final card = Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: hpCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 26),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(fontWeight: FontWeight.bold, color: color)),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(color: hpMuted, height: 1.3)),
                ],
                if (examplesLine != null) ...[
                  const SizedBox(height: 4),
                  Text(examplesLine,
                      style: const TextStyle(
                          color: hpMuted, fontSize: 12, height: 1.3)),
                ],
              ],
            ),
          ),
          if (state == _VoiceState.notUnderstood)
            TextButton.icon(
              onPressed: onSpeak,
              icon: const Icon(Icons.mic, size: 18),
              label: Text(l10n.retry),
            ),
        ],
      ),
    );

    return tappable ? GestureDetector(onTap: onSpeak, child: card) : card;
  }
}
