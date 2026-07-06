import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:permission_handler/permission_handler.dart';
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
import '../widgets/primary_button.dart';
import '../widgets/screen_scaffold.dart';

enum _VoiceState { idle, listening, timerSet, notUnderstood, unavailable }

class ReminderScreen extends StatefulWidget {
  final LocationSnapshot parkingLocation;
  final VoidCallback onAddIgnoredLocation;
  final VoidCallback onNavigateToCar;
  final VoidCallback onDismiss;

  const ReminderScreen({
    super.key,
    required this.parkingLocation,
    required this.onAddIgnoredLocation,
    required this.onNavigateToCar,
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
  String _partialText = '';
  Duration? _setDuration;
  bool _handled = false;

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
    _voice.cancel();
    _tts.stop();
    super.dispose();
  }

  Future<void> _startVoice() async {
    // The alarm audio/vibration must stop before we listen, or it drowns the mic.
    try {
      await const MethodChannel('dk.parkingson/alarm')
          .invokeMethod('stopAlarmVibration');
    } catch (_) {}

    if (await Permission.microphone.request() != PermissionStatus.granted) {
      if (mounted) setState(() => _voiceState = _VoiceState.unavailable);
      return;
    }

    final available = await _voice.initialize();
    if (!available) {
      if (mounted) setState(() => _voiceState = _VoiceState.unavailable);
      return;
    }

    _handled = false;
    if (mounted) {
      setState(() {
        _voiceState = _VoiceState.listening;
        _partialText = '';
      });
    }
    await _voice.listen(
      onResult: (text, isFinal) {
        if (mounted) setState(() => _partialText = text);
        if (isFinal) _handle(text);
      },
      onDone: () {
        // If listening ended without a matched command, treat the last partial
        // as the final attempt.
        if (!_handled) _handle(_partialText);
      },
    );
  }

  void _handle(String text) {
    if (_handled) return;
    final command = classifyVoiceCommand(text);
    if (command.type == VoiceCommandType.none) {
      if (text.trim().isEmpty) {
        // Nothing was said at all — quietly return to idle so manual controls
        // are the obvious path.
        if (mounted) setState(() => _voiceState = _VoiceState.idle);
        return;
      }
      if (mounted) setState(() => _voiceState = _VoiceState.notUnderstood);
      return;
    }

    _handled = true;
    _voice.stop();

    switch (command.type) {
      case VoiceCommandType.ignoreLocation:
        _speak(AppLocalizations.of(context).voiceIgnoreConfirm);
        widget.onAddIgnoredLocation();
        break;
      case VoiceCommandType.setDuration:
        _applyDuration(command.duration!);
        break;
      case VoiceCommandType.none:
        break;
    }
  }

  Future<void> _applyDuration(Duration d) async {
    await _timerRepo.setTimer(ParkingTimer(
      expiresAt: DateTime.now().add(d),
      carLatitude: widget.parkingLocation.latitude,
      carLongitude: widget.parkingLocation.longitude,
    ));
    if (!mounted) return;
    final l10n = AppLocalizations.of(context);
    _speak(l10n.voiceTimerSet(_formatDuration(d, l10n)));
    setState(() {
      _setDuration = d;
      _voiceState = _VoiceState.timerSet;
      _timerLoadExisting = true;
      _timerKey++; // rebuild the selector so it reloads the active timer
    });
  }

  Future<void> _speak(String text) async {
    try {
      final tag = Localizations.localeOf(context).toLanguageTag();
      await _tts.setLanguage(tag);
    } catch (_) {}
    try {
      await _tts.stop();
      await _tts.speak(text);
    } catch (_) {}
  }

  String _formatDuration(Duration d, AppLocalizations l10n) {
    if (d.inMinutes < 60) return l10n.durationMinutes(d.inMinutes);
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    return m == 0 ? l10n.durationHours(h) : l10n.durationHoursMinutes(h, m);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ScreenScaffold(
      title: l10n.reminderTitle,
      children: [
        Text(
          l10n.reminderBody,
          style: const TextStyle(fontSize: 16, color: hpText, height: 1.5),
        ),
        const SizedBox(height: 16),
        _VoicePanel(
          state: _voiceState,
          partialText: _partialText,
          setDuration: _setDuration == null
              ? null
              : _formatDuration(_setDuration!, l10n),
          onRetry: _startVoice,
        ),
        const SizedBox(height: 16),
        const ParkingAppButtons(),
        const SizedBox(height: 24),
        PrimaryButton(label: l10n.findCar, onPressed: widget.onNavigateToCar),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: widget.onAddIgnoredLocation,
            child: Text(l10n.ignoreThisLocation),
          ),
        ),

        // ── Parking timer ─────────────────────────────────────────────────
        const SizedBox(height: 16),
        ParkingTimerSelector(
          key: ValueKey(_timerKey),
          carLatitude: widget.parkingLocation.latitude,
          carLongitude: widget.parkingLocation.longitude,
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
    );
  }
}

/// The voice-command status card at the top of the reminder screen.
class _VoicePanel extends StatelessWidget {
  final _VoiceState state;
  final String partialText;
  final String? setDuration;
  final VoidCallback onRetry;

  const _VoicePanel({
    required this.state,
    required this.partialText,
    required this.setDuration,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    // Nothing to show when idle or unavailable — keep the screen clean and let
    // the manual controls do the work.
    if (state == _VoiceState.idle || state == _VoiceState.unavailable) {
      return const SizedBox.shrink();
    }

    late final IconData icon;
    late final Color color;
    late final String title;
    String? subtitle;
    switch (state) {
      case _VoiceState.listening:
        icon = Icons.mic;
        color = hpTeal;
        title = l10n.voiceListening;
        subtitle = partialText.isEmpty ? l10n.voicePrompt : partialText;
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
        subtitle = partialText.isEmpty ? null : '"$partialText"';
        break;
      case _VoiceState.idle:
      case _VoiceState.unavailable:
        return const SizedBox.shrink();
    }

    return Container(
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
              ],
            ),
          ),
          if (state == _VoiceState.notUnderstood)
            TextButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.mic, size: 18),
              label: Text(l10n.retry),
            ),
        ],
      ),
    );
  }
}
