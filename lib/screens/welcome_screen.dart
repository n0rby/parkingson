import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../theme.dart';
import '../widgets/primary_button.dart';

class WelcomeScreen extends StatelessWidget {
  final VoidCallback onGetStarted;

  const WelcomeScreen({super.key, required this.onGetStarted});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: hpBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),
              Text('Parkingson',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: hpTeal, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Text(l10n.welcomeTagline,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: hpText)),
              const SizedBox(height: 8),
              Text(
                l10n.welcomeBody,
                style: const TextStyle(color: hpMuted, fontSize: 15, height: 1.5),
              ),
              const Spacer(),
              PrimaryButton(label: l10n.getStarted, onPressed: onGetStarted),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
