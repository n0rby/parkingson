import 'package:flutter/material.dart';
import '../repositories/parking_apps_repository.dart';
import '../theme.dart';

/// Shows a launch button for each parking app the user selected under
/// Opsætning → Parkeringsapps. Tapping a button opens that app so the user can
/// pay for parking straight from the reminder. Renders nothing while loading or
/// when no apps are selected.
class ParkingAppButtons extends StatefulWidget {
  const ParkingAppButtons({super.key});

  @override
  State<ParkingAppButtons> createState() => _ParkingAppButtonsState();
}

class _ParkingAppButtonsState extends State<ParkingAppButtons> {
  final _repo = ParkingAppsRepository();
  List<InstalledApp> _apps = [];
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final apps = await _repo.getSelectedApps();
    if (mounted) {
      setState(() {
        _apps = apps;
        _loaded = true;
      });
    }
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
              padding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            onPressed: () => _repo.launchApp(app.packageName),
            icon: const Icon(Icons.local_parking, size: 18, color: hpTeal),
            label: Text(app.label),
          ),
      ],
    );
  }
}
