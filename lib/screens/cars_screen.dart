import 'package:flutter/material.dart';
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
    return ScreenScaffold(
      title: 'Vælg dine biler',
      children: [
        ListCard(children: [
          const Expanded(
            child: Text('Brug kun BT, for at reducere antallet af falske alarmer'),
          ),
          Checkbox(value: btOnlyMode, onChanged: (v) => onBtOnlyModeChange(v ?? false)),
        ]),
        const SizedBox(height: 16),
        const Text('Appen virker bedst, hvis du vælger dine bilers Bluetooth-forbindelser.'),
        const SizedBox(height: 16),
        const Text('Biler med Bluetooth', style: TextStyle(fontWeight: FontWeight.bold, color: hpText)),
        const SizedBox(height: 8),
        if (pairedDevices.isEmpty)
          ListCard(children: const [
            Expanded(child: Text('Ingen parrede Bluetooth-enheder fundet.')),
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
                    if (checked == true) updated.add(car.address);
                    else updated.remove(car.address);
                    onSelectionChange(updated);
                  },
                ),
              ]),
            );
          }),
        const SizedBox(height: 16),
        PrimaryButton(label: 'Aktiver parkeringsovervågning', onPressed: onNext),
        TextButton(
          onPressed: onOpenBluetoothSettings,
          child: const Text('System Bluetooth-indstillinger'),
        ),
      ],
    );
  }
}
