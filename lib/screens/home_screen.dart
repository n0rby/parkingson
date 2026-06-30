import 'package:flutter/material.dart';
import '../models/car_device.dart';
import '../models/location_snapshot.dart';
import '../theme.dart';
import '../widgets/action_row.dart';
import '../widgets/status_pill.dart';

class HomeScreen extends StatelessWidget {
  final List<CarDevice> monitoredCars;
  final LocationSnapshot? lastParkingLocation;
  final bool isPremium;
  final VoidCallback onTestAlarm;
  final VoidCallback onManageCars;
  final VoidCallback onManageIgnoredLocations;
  final VoidCallback onFindCar;
  final VoidCallback onBuyApp;

  const HomeScreen({
    super.key,
    required this.monitoredCars,
    required this.lastParkingLocation,
    required this.isPremium,
    required this.onTestAlarm,
    required this.onManageCars,
    required this.onManageIgnoredLocations,
    required this.onFindCar,
    required this.onBuyApp,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: hpBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Parkingson',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: hpText)),
              const SizedBox(height: 12),
              const StatusPill(label: 'Overvågning aktiv'),
              const SizedBox(height: 16),
              // Monitor card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lastParkingLocation != null
                            ? 'Sidst parkeret ${lastParkingLocation!.displayCapturedAt}'
                            : 'Sidst parkeret ikke målt endnu',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: hpText),
                      ),
                      if (!isPremium) ...[
                        const SizedBox(height: 16),
                        // TODO: Replace with real AdMob banner
                        Container(
                          height: 60,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(color: hpCard, borderRadius: BorderRadius.circular(12)),
                          child: const Text('REKLAME', style: TextStyle(color: hpSubtle, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: onBuyApp,
                            style: FilledButton.styleFrom(backgroundColor: hpOrange),
                            child: const Text('Slip for reklamer og støt en rar programmør. Næsten gratis!',
                                textAlign: TextAlign.center),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Divider(),
              ActionRow(
                title: 'Test påmindelse',
                subtitle: 'Se notifikation, sirene og stemme',
                onTap: onTestAlarm,
                accent: hpOrange,
              ),
              ActionRow(
                title: 'Administrer biler',
                subtitle: 'Tilføj, fjern eller skift biler',
                onTap: onManageCars,
                accent: hpTeal,
              ),
              ActionRow(
                title: 'Find min bil',
                subtitle: lastParkingLocation != null
                    ? 'Rute til sidst parkeret ${lastParkingLocation!.displayCapturedAt}'
                    : 'Ingen parkeringsplacering gemt endnu',
                onTap: onFindCar,
              ),
              ActionRow(
                title: 'Ignorerede lokationer',
                subtitle: 'Steder der ikke udløser alarm',
                onTap: onManageIgnoredLocations,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
