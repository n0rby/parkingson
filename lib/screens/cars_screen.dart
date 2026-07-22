import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../models/car_device.dart';
import '../theme.dart';
import '../widgets/list_card.dart';
import '../widgets/primary_button.dart';

class CarsScreen extends StatelessWidget {
  final List<CarDevice> pairedDevices;
  final Set<String> selectedAddresses;
  final Set<String> usbAccessories;
  final bool btOnlyMode;
  final ValueChanged<Set<String>> onSelectionChange;
  final ValueChanged<bool> onBtOnlyModeChange;
  final VoidCallback onRegisterUsbAccessory;
  final ValueChanged<String> onRemoveUsbAccessory;
  final VoidCallback onNext;
  final VoidCallback onOpenBluetoothSettings;

  const CarsScreen({
    super.key,
    required this.pairedDevices,
    required this.selectedAddresses,
    required this.usbAccessories,
    required this.btOnlyMode,
    required this.onSelectionChange,
    required this.onBtOnlyModeChange,
    required this.onRegisterUsbAccessory,
    required this.onRemoveUsbAccessory,
    required this.onNext,
    required this.onOpenBluetoothSettings,
  });

  void _toggle(String address, bool checked) {
    final updated = Set<String>.from(selectedAddresses);
    if (checked) {
      updated.add(address);
    } else {
      updated.remove(address);
    }
    onSelectionChange(updated);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Fixed header ────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.carsTitle,
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(color: hpText, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  ListCard(children: [
                    Expanded(child: Text(l10n.btOnlyMode)),
                    Checkbox(
                      value: btOnlyMode,
                      onChanged: (v) => onBtOnlyModeChange(v ?? false),
                    ),
                  ]),
                  const SizedBox(height: 16),
                  Text(l10n.carsBody),
                  const SizedBox(height: 16),
                  // ── USB car (cable / Android Auto) ──────────────────────────
                  Text(l10n.carsWithUsb,
                      style: const TextStyle(fontWeight: FontWeight.bold, color: hpText)),
                  const SizedBox(height: 4),
                  Text(l10n.usbCarsBody),
                  const SizedBox(height: 8),
                  if (usbAccessories.isEmpty)
                    Text(l10n.noUsbCarRegistered,
                        style: const TextStyle(color: hpMuted))
                  else
                    ...usbAccessories.map((id) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: ListCard(children: [
                            Expanded(
                              child: Text(id,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600)),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () => onRemoveUsbAccessory(id),
                            ),
                          ]),
                        )),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: onRegisterUsbAccessory,
                    icon: const Icon(Icons.usb),
                    label: Text(l10n.registerConnectedUsbCar),
                  ),
                  const SizedBox(height: 16),
                  Text(l10n.carsWithBluetooth,
                      style: const TextStyle(fontWeight: FontWeight.bold, color: hpText)),
                  const SizedBox(height: 8),
                ],
              ),
            ),

            // ── Scrollable device list ──────────────────────────────────────
            Expanded(
              child: pairedDevices.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: ListCard(children: [
                        Expanded(child: Text(l10n.noPairedDevices)),
                      ]),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                      itemCount: pairedDevices.length,
                      itemBuilder: (context, index) {
                        final car = pairedDevices[index];
                        final selected = selectedAddresses.contains(car.address);
                        return Padding(
                          // Halved top/bottom spacing so more cars fit the list.
                          padding: const EdgeInsets.only(bottom: 4),
                          child: ListCard(verticalPadding: 7, children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(car.name,
                                      style: const TextStyle(fontWeight: FontWeight.w600)),
                                  Text(car.address,
                                      style: const TextStyle(color: hpMuted, fontSize: 12)),
                                ],
                              ),
                            ),
                            Checkbox(
                              value: selected,
                              onChanged: (checked) => _toggle(car.address, checked == true),
                            ),
                          ]),
                        );
                      },
                    ),
            ),

            // ── Fixed footer ────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
              child: Column(
                children: [
                  PrimaryButton(label: l10n.save, onPressed: onNext),
                  TextButton(
                    onPressed: onOpenBluetoothSettings,
                    child: Text(l10n.systemBluetoothSettings),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
