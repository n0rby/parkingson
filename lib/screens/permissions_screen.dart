import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../theme.dart';
import '../widgets/primary_button.dart';
import '../widgets/screen_scaffold.dart';

class PermissionsScreen extends StatefulWidget {
  final VoidCallback onActivate;

  const PermissionsScreen({super.key, required this.onActivate});

  @override
  State<PermissionsScreen> createState() => _PermissionsScreenState();
}

class _PermissionsScreenState extends State<PermissionsScreen> with WidgetsBindingObserver {
  Map<_PermItem, PermissionStatus> _statuses = {};
  bool _checking = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkAll();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // Re-check after user returns from system settings — delayed to let Android propagate the change
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      Future.delayed(const Duration(milliseconds: 600), _checkAll);
    }
  }

  List<_PermItem> get _items => [
        _PermItem.bluetooth,
        _PermItem.locationAlways,
        if (Platform.isAndroid) _PermItem.activityRecognition,
        _PermItem.notifications,
      ];

  bool get _canActivate =>
      _items.every((p) => _statuses[p]?.isGranted == true);

  Future<PermissionStatus> _checkItem(_PermItem item) async {
    if (item == _PermItem.bluetooth) {
      final results = await [
        Permission.bluetoothScan.status,
        Permission.bluetoothConnect.status,
      ].wait;
      if (results.every((s) => s.isGranted)) return PermissionStatus.granted;
      if (results.any((s) => s.isPermanentlyDenied)) return PermissionStatus.permanentlyDenied;
      return PermissionStatus.denied;
    }
    return item.permission.status;
  }

  Future<void> _checkAll() async {
    setState(() => _checking = true);
    final map = <_PermItem, PermissionStatus>{};
    for (final item in _items) {
      map[item] = await _checkItem(item);
    }
    if (mounted) setState(() { _statuses = map; _checking = false; });
  }

  Future<void> _request(_PermItem item) async {
    PermissionStatus status;

    if (item == _PermItem.bluetooth) {
      final results = await [
        Permission.bluetoothScan,
        Permission.bluetoothConnect,
      ].request();
      if (results.values.every((s) => s.isGranted)) {
        status = PermissionStatus.granted;
      } else if (results.values.any((s) => s.isPermanentlyDenied)) {
        status = PermissionStatus.permanentlyDenied;
      } else {
        status = PermissionStatus.denied;
      }
    } else if (item == _PermItem.locationAlways) {
      // Must request locationWhenInUse first, then locationAlways
      final whenInUse = await Permission.locationWhenInUse.status;
      if (!whenInUse.isGranted) {
        await Permission.locationWhenInUse.request();
      }
      status = await Permission.locationAlways.request();
    } else {
      status = await item.permission.request();
    }

    if (status.isPermanentlyDenied) {
      await openAppSettings();
      // Don't update status here — didChangeAppLifecycleState re-checks after returning
      return;
    }

    if (mounted) setState(() => _statuses[item] = status);
  }

  @override
  Widget build(BuildContext context) {
    return ScreenScaffold(
      title: 'Tilladelser',
      children: [
        const Text(
          'Appen har brug for følgende tilladelser for at overvåge din bil i baggrunden.',
          style: TextStyle(color: hpMuted, height: 1.5),
        ),
        const SizedBox(height: 24),
        if (_checking)
          const Center(child: CircularProgressIndicator())
        else
          ..._items.map((item) => _PermissionRow(
                item: item,
                status: _statuses[item],
                onRequest: () => _request(item),
              )),
        const SizedBox(height: 24),
        PrimaryButton(
          label: 'Aktiver overvågning',
          onPressed: _canActivate ? widget.onActivate : null,
        ),
        if (!_canActivate) ...[
          const SizedBox(height: 8),
          const Text(
            'Giv alle tilladelser ovenfor for at fortsætte.',
            textAlign: TextAlign.center,
            style: TextStyle(color: hpMuted, fontSize: 13),
          ),
        ],
      ],
    );
  }
}

class _PermissionRow extends StatelessWidget {
  final _PermItem item;
  final PermissionStatus? status;
  final VoidCallback onRequest;

  const _PermissionRow({
    required this.item,
    required this.status,
    required this.onRequest,
  });

  @override
  Widget build(BuildContext context) {
    final granted = status?.isGranted == true;
    final denied = status?.isPermanentlyDenied == true;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: granted
                  ? Colors.green.withValues(alpha: 0.12)
                  : hpCard,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              granted ? Icons.check_circle : item.icon,
              color: granted ? Colors.green : hpTeal,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title,
                    style: const TextStyle(fontWeight: FontWeight.w600, color: hpText)),
                Text(item.description,
                    style: const TextStyle(fontSize: 12, color: hpMuted)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (!granted)
            TextButton(
              onPressed: onRequest,
              child: Text(denied ? 'Indstillinger' : 'Giv'),
            )
          else
            const Text('OK', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

enum _PermItem {
  bluetooth,
  locationAlways,
  activityRecognition,
  notifications;

  Permission get permission => switch (this) {
        bluetooth => Permission.bluetoothConnect,
        locationAlways => Permission.locationAlways,
        activityRecognition => Permission.activityRecognition,
        notifications => Permission.notification,
      };

  String get title => switch (this) {
        bluetooth => 'Bluetooth',
        locationAlways => 'Placering (altid)',
        activityRecognition => 'Fysisk aktivitet',
        notifications => 'Notifikationer',
      };

  String get description => switch (this) {
        bluetooth => 'Registrér hvornår du forlader din bil',
        locationAlways => 'Gem parkeringsstedet i baggrunden',
        activityRecognition => 'Detektér kørsel og gang',
        notifications => 'Send påmindelser om parkering',
      };

  IconData get icon => switch (this) {
        bluetooth => Icons.bluetooth,
        locationAlways => Icons.location_on_outlined,
        activityRecognition => Icons.directions_walk,
        notifications => Icons.notifications_outlined,
      };
}
