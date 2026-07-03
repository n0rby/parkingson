import 'package:flutter/material.dart';
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
  final _repo = SoundSettingsRepository();
  SoundMode _mode = SoundMode.app;
  int _volume = 100;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final mode = await _repo.getMode();
    final volume = await _repo.getVolume();
    if (mounted) {
      setState(() {
        _mode = mode;
        _volume = volume;
        _loaded = true;
      });
    }
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
        ],
        const SizedBox(height: 16),
        TextButton(onPressed: widget.onBack, child: Text(l10n.backToOverview)),
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
