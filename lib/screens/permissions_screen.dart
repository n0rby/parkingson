import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import '../l10n/app_localizations.dart';
import '../theme.dart';
import '../widgets/primary_button.dart';
import '../widgets/screen_scaffold.dart';

class PermissionsScreen extends StatefulWidget {
  final VoidCallback onActivate;

  const PermissionsScreen({super.key, required this.onActivate});

  @override
  State<PermissionsScreen> createState() => _PermissionsScreenState();
}

class _PermissionsScreenState extends State<PermissionsScreen> {
  bool _requesting = false;

  Future<void> _requestAll() async {
    if (_requesting) return;
    setState(() => _requesting = true);

    // Request each permission individually and in sequence. Android drops the
    // later permissions if location is requested in the same batch as others,
    // so location must be its own request — hence one-by-one here.
    try {
      await Permission.bluetoothScan.request();
      await Permission.bluetoothConnect.request();
      await Permission.locationWhenInUse.request();
      if (Platform.isAndroid) await Permission.activityRecognition.request();
      await Permission.notification.request();
    } catch (_) {}

    // Then the battery-optimization exemption (native system dialog).
    if (Platform.isAndroid) {
      try {
        await const MethodChannel('dk.parkingson/alarm')
            .invokeMethod('requestIgnoreBatteryOptimizations');
      } catch (_) {}
    }

    if (mounted) {
      setState(() => _requesting = false);
      widget.onActivate();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final items = <(IconData, String, String)>[
      (Icons.bluetooth, l10n.permBluetooth, l10n.permBluetoothDesc),
      (Icons.location_on_outlined, l10n.permLocation, l10n.permLocationDesc),
      if (Platform.isAndroid)
        (Icons.directions_walk, l10n.permActivity, l10n.permActivityDesc),
      (Icons.notifications_outlined, l10n.permNotifications, l10n.permNotificationsDesc),
      if (Platform.isAndroid)
        (Icons.battery_saver_outlined, l10n.permBattery, l10n.permBatteryDesc),
    ];

    return ScreenScaffold(
      title: l10n.permissionsTitle,
      children: [
        Text(
          l10n.permissionsBody,
          style: const TextStyle(color: hpMuted, height: 1.5),
        ),
        const SizedBox(height: 20),
        ...items.map((it) => _Bullet(icon: it.$1, title: it.$2, description: it.$3)),
        const SizedBox(height: 24),
        PrimaryButton(
          label: l10n.grantAllPermissions,
          onPressed: _requesting ? null : _requestAll,
        ),
      ],
    );
  }
}

class _Bullet extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _Bullet({required this.icon, required this.title, required this.description});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: hpCard,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: hpTeal, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(fontWeight: FontWeight.w600, color: hpText)),
                Text(description,
                    style: const TextStyle(fontSize: 12, color: hpMuted, height: 1.3)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
