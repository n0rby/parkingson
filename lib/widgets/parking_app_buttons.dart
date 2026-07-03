import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../repositories/parking_apps_repository.dart';
import '../theme.dart';

/// Shows a launch button for each parking app the user selected under
/// Opsætning → Parkeringsapps. Each button shows the app's own icon; tapping it
/// opens that app so the user can pay for parking straight from the reminder.
/// Renders nothing while loading or when no apps are selected.
class ParkingAppButtons extends StatefulWidget {
  const ParkingAppButtons({super.key});

  @override
  State<ParkingAppButtons> createState() => _ParkingAppButtonsState();
}

class _ParkingAppButtonsState extends State<ParkingAppButtons> {
  final _repo = ParkingAppsRepository();
  List<InstalledApp> _apps = [];
  final Map<String, Uint8List> _icons = {};
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final apps = await _repo.getSelectedApps();
    final icons = await Future.wait(apps.map((a) => _repo.getAppIcon(a.packageName)));
    if (!mounted) return;
    setState(() {
      _apps = apps;
      for (var i = 0; i < apps.length; i++) {
        final icon = icons[i];
        if (icon != null) _icons[apps[i].packageName] = icon;
      }
      _loaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded || _apps.isEmpty) return const SizedBox.shrink();
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final app in _apps)
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: hpCard,
              foregroundColor: hpText,
              minimumSize: const Size(0, 44),
              padding: const EdgeInsets.symmetric(horizontal: 14),
            ),
            onPressed: () => _repo.launchApp(app.packageName),
            icon: _icon(app.packageName),
            label: Text(app.label),
          ),
      ],
    );
  }

  Widget _icon(String packageName) {
    final bytes = _icons[packageName];
    if (bytes == null) {
      return const Icon(Icons.local_parking, size: 22, color: hpTeal);
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(5),
      child: Image.memory(bytes, width: 24, height: 24, filterQuality: FilterQuality.medium),
    );
  }
}
