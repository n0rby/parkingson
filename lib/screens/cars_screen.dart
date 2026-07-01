import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../models/car_device.dart';
import '../theme.dart';
import '../widgets/list_card.dart';
import '../widgets/primary_button.dart';
import '../widgets/screen_scaffold.dart';

class CarsScreen extends StatelessWidget {
  final List<CarDevice> pairedDevices;
  final Set<String> selectedAddresses;
  final bool btOnlyMode;
  final ValueChanged<Set<String>> onSelectionChange;
  final ValueChanged<bool> onBtOnlyModeChange;
  final VoidCallback onNext;
  final VoidCallback onOpenBluetoothSettings;

  const CarsScreen({
    super.key,
    required this.pairedDevices,
    required this.selectedAddresses,
    required this.btOnlyMode,
    required this.onSelectionChange,
    required this.onBtOnlyModeChange,
    required this.onNext,
    required this.onOpenBluetoothSettings,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ScreenScaffold(
      title: l10n.carsTitle,
      children: [
        ListCard(children: [
          Expanded(
            child: Text(l10n.btOnlyMode),
          ),
          Checkbox(value: btOnlyMode, onChanged: (v) => onBtOnlyModeChange(v ?? false)),
        ]),
        const SizedBox(height: 16),
        Text(l10n.carsBody),
        const SizedBox(height: 16),
        Text(l10n.carsWithBluetooth, style: const TextStyle(fontWeight: FontWeight.bold, color: hpText)),
        const SizedBox(height: 8),
        if (pairedDevices.isEmpty)
          ListCard(children: [
            Expanded(child: Text(l10n.noPairedDevices)),
          ])
        else
          ...pairedDevices.map((car) {
            final selected = selectedAddresses.contains(car.address);
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: ListCard(children: [
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(car.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                    Text(car.address, style: const TextStyle(color: hpMuted, fontSize: 12)),
                  ],
                )),
                Checkbox(
                  value: selected,
                  onChanged: (checked) {
                    final updated = Set<String>.from(selectedAddresses);
                    if (checked == true) {
                      updated.add(car.address);
                    } else {
                      updated.remove(car.address);
                    }
                    onSelectionChange(updated);
                  },
                ),
              ]),
            );
          }),
        const SizedBox(height: 16),
        PrimaryButton(label: l10n.activateParkingMonitoring, onPressed: onNext),
        TextButton(
          onPressed: onOpenBluetoothSettings,
          child: Text(l10n.systemBluetoothSettings),
        ),
      ],
    );
  }
}
