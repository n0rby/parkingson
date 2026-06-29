import 'package:flutter/material.dart';
import '../models/ignored_location.dart';
import '../models/location_snapshot.dart';
import '../theme.dart';
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
    return ScreenScaffold(
      title: 'Husk at betale for parkering!',
      children: [
        const Text(
          'Vi har registreret at du har forladt din bil. Husk at betale for parkering!',
          style: TextStyle(fontSize: 16, color: hpText, height: 1.5),
        ),
        const SizedBox(height: 20),
        _InfoRow(
          icon: Icons.location_on_outlined,
          label: 'Koordinater',
          value: parkingLocation.displayCoordinates,
        ),
        _InfoRow(
          icon: Icons.access_time,
          label: 'Registreret',
          value: parkingLocation.displayCapturedAt,
        ),
        const SizedBox(height: 24),
        PrimaryButton(label: 'Find min bil', onPressed: onNavigateToCar),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: onAddIgnoredLocation,
            child: const Text('Ignorer altid denne placering'),
          ),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: onDismiss,
          child: const Text('Luk'),
        ),
        const SizedBox(height: 12),
        Text(
          'Tryk "Ignorer altid" for steder som hjemme eller arbejde, '
          'hvor du sjældent skal betale for parkering. '
          'Alarmen vises ikke igen inden for ${ignoredLocationRadiusMeters.toInt()} meter herfra.',
          style: const TextStyle(color: hpMuted, fontSize: 13, height: 1.5),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: hpTeal),
          const SizedBox(width: 8),
          Text('$label: ', style: const TextStyle(color: hpMuted, fontSize: 13)),
          Text(value, style: const TextStyle(color: hpText, fontSize: 13)),
        ],
      ),
    );
  }
}
