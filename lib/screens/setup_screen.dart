import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../theme.dart';
import '../widgets/action_row.dart';
import '../widgets/screen_scaffold.dart';

/// Setup screen — holds the less-frequently-used actions (manage cars, test
/// reminder) so the home screen stays clean.
class SetupScreen extends StatelessWidget {
  final VoidCallback onManageCars;
  final VoidCallback onTestAlarm;
  final VoidCallback onSound;
  final VoidCallback onParkingApps;
  final VoidCallback onBack;

  const SetupScreen({
    super.key,
    required this.onManageCars,
    required this.onTestAlarm,
    required this.onSound,
    required this.onParkingApps,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ScreenScaffold(
      title: l10n.setupTitle,
      children: [
        ActionRow(
          title: l10n.manageCars,
          subtitle: l10n.manageCarsDesc,
          onTap: onManageCars,
          accent: hpTeal,
        ),
        ActionRow(
          title: l10n.soundTitle,
          subtitle: l10n.soundDesc,
          onTap: onSound,
          accent: hpTeal,
        ),
        ActionRow(
          title: l10n.parkingAppsTitle,
          subtitle: l10n.parkingAppsDesc,
          onTap: onParkingApps,
          accent: hpTeal,
        ),
        ActionRow(
          title: l10n.testReminder,
          subtitle: l10n.testReminderDesc,
          onTap: onTestAlarm,
          accent: hpOrange,
        ),
        const SizedBox(height: 16),
        TextButton(onPressed: onBack, child: Text(l10n.backToOverview)),
      ],
    );
  }
}
