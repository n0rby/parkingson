import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../models/ignored_location.dart';
import '../models/location_snapshot.dart';
import '../theme.dart';
import '../widgets/parking_app_buttons.dart';
import '../widgets/parking_timer_selector.dart';
import '../widgets/primary_button.dart';
import '../widgets/screen_scaffold.dart';

class ReminderScreen extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ScreenScaffold(
      title: l10n.reminderTitle,
      children: [
        Text(
          l10n.reminderBody,
          style: const TextStyle(fontSize: 16, color: hpText, height: 1.5),
        ),
        const SizedBox(height: 20),
        const ParkingAppButtons(),
        const SizedBox(height: 24),
        PrimaryButton(label: l10n.findCar, onPressed: onNavigateToCar),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: onAddIgnoredLocation,
            child: Text(l10n.ignoreThisLocation),
          ),
        ),

        // ── Parking timer ─────────────────────────────────────────────────
        const SizedBox(height: 16),
        ParkingTimerSelector(
          carLatitude: parkingLocation.latitude,
          carLongitude: parkingLocation.longitude,
        ),

        const SizedBox(height: 8),
        TextButton(
          onPressed: onDismiss,
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
