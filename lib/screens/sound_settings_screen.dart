import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../l10n/app_localizations.dart';
import '../repositories/sound_settings_repository.dart';
import '../theme.dart';
import '../widgets/list_card.dart';
import '../widgets/screen_scaffold.dart';

class SoundSettingsScreen extends StatefulWidget {
  final VoidCallback onBack;

  const SoundSettingsScreen({super.key, required this.onBack});

  @override
  State<SoundSettingsScreen> createState() => _SoundSettingsScreenState();
}

class _SoundSettingsScreenState extends State<SoundSettingsScreen> {
  static const _channel = MethodChannel('dk.parkingson/alarm');

  final _repo = SoundSettingsRepository();
  SoundMode _mode = SoundMode.app;
  int _volume = 100;
  bool _vibrateInDnd = true;
  bool _vibrateWhenSilent = true;
  String _alarmSoundTitle = '';
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final mode = await _repo.getMode();
    final volume = await _repo.getVolume();
    final vibrateDnd = await _repo.getVibrateInDnd();
    final vibrateSilent = await _repo.getVibrateWhenSilent();
    String soundTitle = '';
    try {
      soundTitle = await _channel.invokeMethod('getAlarmSoundTitle') ?? '';
    } catch (_) {}
    if (mounted) {
      setState(() {
        _mode = mode;
        _volume = volume;
        _vibrateInDnd = vibrateDnd;
        _vibrateWhenSilent = vibrateSilent;
        _alarmSoundTitle = soundTitle;
        _loaded = true;
      });
    }
  }

  Future<void> _pickAlarmSound() async {
    final l10n = AppLocalizations.of(context);
    try {
      final title = await _channel
          .invokeMethod('pickAlarmSound', {'title': l10n.soundAlarmSound});
      if (title is String && mounted) {
        setState(() => _alarmSoundTitle = title);
      }
    } catch (_) {}
  }

  void _selectMode(SoundMode mode) {
    setState(() => _mode = mode);
    _repo.setMode(mode);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ScreenScaffold(
      title: l10n.soundTitle,
      children: [
        if (!_loaded)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(),
            ),
          )
        else ...[
          ListCard(
            onTap: _pickAlarmSound,
            children: [
              const Icon(Icons.music_note_outlined, color: hpTeal),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.soundAlarmSound,
                        style: const TextStyle(fontWeight: FontWeight.bold, color: hpText)),
                    if (_alarmSoundTitle.isNotEmpty)
                      Text(_alarmSoundTitle,
                          style: const TextStyle(color: hpMuted, fontSize: 12)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: hpSubtle),
            ],
          ),
          const SizedBox(height: 16),
          _ModeTile(
            title: l10n.soundUsePhone,
            selected: _mode == SoundMode.phone,
            onTap: () => _selectMode(SoundMode.phone),
          ),
          const SizedBox(height: 8),
          _ModeTile(
            title: l10n.soundUseApp,
            selected: _mode == SoundMode.app,
            onTap: () => _selectMode(SoundMode.app),
          ),
          if (_mode == SoundMode.app) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Text(l10n.soundVolume,
                    style: const TextStyle(fontWeight: FontWeight.bold, color: hpText)),
                const Spacer(),
                Text('$_volume%', style: const TextStyle(color: hpTeal, fontWeight: FontWeight.bold)),
              ],
            ),
            Slider(
              value: _volume.toDouble(),
              min: 0,
              max: 100,
              divisions: 20,
              activeColor: hpTeal,
              label: '$_volume%',
              onChanged: (v) => setState(() => _volume = v.round()),
              onChangeEnd: (v) => _repo.setVolume(v.round()),
            ),
          ],
          const SizedBox(height: 16),
          _CheckRow(
            label: l10n.soundVibrateDnd,
            value: _vibrateInDnd,
            onChanged: (v) {
              setState(() => _vibrateInDnd = v);
              _repo.setVibrateInDnd(v);
            },
          ),
          const SizedBox(height: 8),
          _CheckRow(
            label: l10n.soundVibrateSilent,
            value: _vibrateWhenSilent,
            onChanged: (v) {
              setState(() => _vibrateWhenSilent = v);
              _repo.setVibrateWhenSilent(v);
            },
          ),
        ],
        const SizedBox(height: 16),
        TextButton(onPressed: widget.onBack, child: Text(l10n.backToOverview)),
      ],
    );
  }
}

class _CheckRow extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _CheckRow({required this.label, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return ListCard(
      onTap: () => onChanged(!value),
      children: [
        Expanded(
          child: Text(label, style: const TextStyle(color: hpText)),
        ),
        Checkbox(
          value: value,
          activeColor: hpTeal,
          onChanged: (v) => onChanged(v ?? false),
        ),
      ],
    );
  }
}

class _ModeTile extends StatelessWidget {
  final String title;
  final bool selected;
  final VoidCallback onTap;

  const _ModeTile({required this.title, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListCard(
      onTap: onTap,
      children: [
        Icon(
          selected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
          color: selected ? hpTeal : hpMuted,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              color: hpText,
              fontWeight: selected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ],
    );
  }
}
