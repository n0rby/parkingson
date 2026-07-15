import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../repositories/car_repository.dart';
import '../repositories/other_settings_repository.dart';
import '../theme.dart';
import '../widgets/list_card.dart';
import '../widgets/screen_scaffold.dart';

/// "Andet" — advanced/less-common settings. Currently the motion fallback timer.
class OtherSettingsScreen extends StatefulWidget {
  final VoidCallback onBack;

  const OtherSettingsScreen({super.key, required this.onBack});

  @override
  State<OtherSettingsScreen> createState() => _OtherSettingsScreenState();
}

class _OtherSettingsScreenState extends State<OtherSettingsScreen> {
  final _repo = OtherSettingsRepository();
  final _carRepo = CarRepository();

  // Selectable fallback windows, in seconds (0 = off).
  static const _options = [0, 60, 120, 180, 300];

  int _fallbackSeconds = OtherSettingsRepository.defaultFallbackSeconds;
  bool _hasConnectedCar = false;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final s = await _repo.getMotionFallbackSeconds();
    final bt = await _carRepo.getSelectedCarAddresses();
    final usb = await _carRepo.getSelectedUsbAccessories();
    if (mounted) {
      setState(() {
        _fallbackSeconds = s;
        _hasConnectedCar = bt.isNotEmpty || usb.isNotEmpty;
        _loaded = true;
      });
    }
  }

  void _select(int seconds) {
    setState(() => _fallbackSeconds = seconds);
    _repo.setMotionFallbackSeconds(seconds);
  }

  String _label(AppLocalizations l10n, int seconds) =>
      seconds == 0 ? l10n.settingOff : l10n.durationMinutes(seconds ~/ 60);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ScreenScaffold(
      title: l10n.otherTitle,
      children: [
        if (!_loaded)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(),
            ),
          )
        else ...[
          Text(l10n.motionFallbackTitle,
              style: const TextStyle(fontWeight: FontWeight.bold, color: hpText)),
          const SizedBox(height: 6),
          if (_hasConnectedCar)
            // Has a BT/USB car → the reliable trigger handles it; the fallback
            // doesn't apply, so don't offer the (confusing) timer.
            Text(l10n.motionFallbackHasCar,
                style: const TextStyle(color: hpMuted, fontSize: 13, height: 1.4))
          else ...[
            Text(l10n.motionFallbackDesc,
                style: const TextStyle(color: hpMuted, fontSize: 13, height: 1.4)),
            const SizedBox(height: 12),
            for (final s in _options) ...[
              _RadioTile(
                title: _label(l10n, s),
                selected: _fallbackSeconds == s,
                onTap: () => _select(s),
              ),
              const SizedBox(height: 8),
            ],
          ],
        ],
        const SizedBox(height: 8),
        TextButton(onPressed: widget.onBack, child: Text(l10n.backToOverview)),
      ],
    );
  }
}

class _RadioTile extends StatelessWidget {
  final String title;
  final bool selected;
  final VoidCallback onTap;

  const _RadioTile(
      {required this.title, required this.selected, required this.onTap});

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
