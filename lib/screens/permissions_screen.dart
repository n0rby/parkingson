import 'package:flutter/material.dart';
import '../widgets/primary_button.dart';
import '../widgets/screen_scaffold.dart';

class PermissionsScreen extends StatelessWidget {
  final VoidCallback onActivate;

  const PermissionsScreen({super.key, required this.onActivate});

  @override
  Widget build(BuildContext context) {
    return ScreenScaffold(
      title: 'Aktiver påmindelser',
      children: [
        const Text('For at sende påmindelser om dine biler, aktivér følgende.'),
        const SizedBox(height: 24),
        // TODO: Show permission items with status indicators
        // Bluetooth, Activity Recognition, Location, Notifications, Background
        const Placeholder(fallbackHeight: 200),
        const SizedBox(height: 24),
        PrimaryButton(label: 'Aktivér', onPressed: onActivate),
      ],
    );
  }
}
