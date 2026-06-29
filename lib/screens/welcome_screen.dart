import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets/primary_button.dart';

class WelcomeScreen extends StatelessWidget {
  final VoidCallback onGetStarted;

  const WelcomeScreen({super.key, required this.onGetStarted});

  @override
  Widget build(BuildContext context) {
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
              const Text('Undgå parkeringsbøder',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: hpText)),
              const SizedBox(height: 8),
              const Text(
                'Få en påmindelse, når du forlader en af dine biler, og gem automatisk stedet, så du kan finde bilen igen.',
                style: TextStyle(color: hpMuted, fontSize: 15, height: 1.5),
              ),
              const Spacer(),
              PrimaryButton(label: 'Kom i gang', onPressed: onGetStarted),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
