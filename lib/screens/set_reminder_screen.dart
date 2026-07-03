import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../models/location_snapshot.dart';
import '../theme.dart';
import '../widgets/parking_timer_selector.dart';
import '../widgets/screen_scaffold.dart';

/// Lets the user set a "walk back in time" reminder manually from the home
/// screen, using the current location as the car's location.
class SetReminderScreen extends StatefulWidget {
  final Future<LocationSnapshot?> Function() getLocation;
  final LocationSnapshot? fallbackLocation;
  final VoidCallback onDone;

  const SetReminderScreen({
    super.key,
    required this.getLocation,
    required this.fallbackLocation,
    required this.onDone,
  });

  @override
  State<SetReminderScreen> createState() => _SetReminderScreenState();
}

class _SetReminderScreenState extends State<SetReminderScreen> {
  LocationSnapshot? _location;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final loc = await widget.getLocation() ?? widget.fallbackLocation;
    if (mounted) {
      setState(() {
        _location = loc;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ScreenScaffold(
      title: l10n.setReminderTitle,
      children: [
        Text(
          l10n.setReminderDesc,
          style: const TextStyle(color: hpMuted, height: 1.5),
        ),
        const SizedBox(height: 20),
        if (_loading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(),
            ),
          )
        else if (_location == null) ...[
          Text(l10n.locationFetchError, style: const TextStyle(color: hpText)),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                setState(() => _loading = true);
                _load();
              },
              child: Text(l10n.retry),
            ),
          ),
        ] else
          ParkingTimerSelector(
            carLatitude: _location!.latitude,
            carLongitude: _location!.longitude,
            loadExisting: true,
          ),
        const SizedBox(height: 16),
        TextButton(onPressed: widget.onDone, child: Text(l10n.close)),
      ],
    );
  }
}
