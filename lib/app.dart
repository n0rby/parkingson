import 'package:flutter/material.dart';
import 'repositories/car_repository.dart';
import 'repositories/billing_repository.dart';
import 'repositories/ignored_location_repository.dart';
import 'screens/welcome_screen.dart';
import 'screens/cars_screen.dart';
import 'screens/permissions_screen.dart';
import 'screens/home_screen.dart';
import 'screens/ignored_locations_screen.dart';
import 'screens/reminder_screen.dart';
import 'models/car_device.dart';
import 'models/location_snapshot.dart';
import 'models/ignored_location.dart';
import 'theme.dart';

enum _Screen { welcome, cars, permissions, home, ignoredLocations, reminder }

class ParkingsonApp extends StatefulWidget {
  const ParkingsonApp({super.key});

  @override
  State<ParkingsonApp> createState() => _ParkingsonAppState();
}

class _ParkingsonAppState extends State<ParkingsonApp> {
  final _carRepo = CarRepository();
  final _billingRepo = BillingRepository();
  final _ignoredRepo = IgnoredLocationRepository();

  _Screen _screen = _Screen.welcome;

  List<CarDevice> _pairedDevices = [];
  Set<String> _selectedAddresses = {};
  bool _btOnlyMode = false;
  bool _isPremium = false;
  List<IgnoredLocation> _ignoredLocations = [];
  LocationSnapshot? _lastParkingLocation;
  LocationSnapshot? _reminderLocation;

  @override
  void initState() {
    super.initState();
    _loadState();
    _billingRepo.initialize().then((_) {
      _billingRepo.premiumStream.listen((v) {
        if (mounted) setState(() => _isPremium = v);
      });
    });
  }

  Future<void> _loadState() async {
    final btOnly = await _carRepo.getBtOnlyMode();
    final carAddresses = await _carRepo.getSelectedCarAddresses();
    final setupDone = await _carRepo.isSetupCompleted();
    final ignored = await _ignoredRepo.getIgnoredLocations();
    final lastLocation = await _ignoredRepo.getLastParkingLocation();
    if (mounted) {
      setState(() {
        _btOnlyMode = btOnly;
        _selectedAddresses = carAddresses;
        _ignoredLocations = ignored;
        _lastParkingLocation = lastLocation;
        _screen = setupDone ? _Screen.home : _Screen.welcome;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Parkingson',
      theme: buildTheme(),
      debugShowCheckedModeBanner: false,
      home: _buildScreen(),
    );
  }

  Widget _buildScreen() {
    switch (_screen) {
      case _Screen.welcome:
        return WelcomeScreen(onGetStarted: () => setState(() => _screen = _Screen.cars));

      case _Screen.cars:
        return CarsScreen(
          pairedDevices: _pairedDevices,
          selectedAddresses: _selectedAddresses,
          btOnlyMode: _btOnlyMode,
          onSelectionChange: (addresses) async {
            setState(() => _selectedAddresses = addresses);
            await _carRepo.saveSelectedCarAddresses(addresses);
          },
          onBtOnlyModeChange: (v) async {
            setState(() => _btOnlyMode = v);
            await _carRepo.saveBtOnlyMode(v);
          },
          onNext: () => setState(() => _screen = _Screen.permissions),
          onOpenBluetoothSettings: () {
            // TODO: open platform bluetooth settings via url_launcher
          },
        );

      case _Screen.permissions:
        return PermissionsScreen(
          onActivate: () async {
            await _carRepo.saveSetupCompleted(true);
            if (mounted) setState(() => _screen = _Screen.home);
          },
        );

      case _Screen.home:
        return HomeScreen(
          monitoredCars: _pairedDevices.where((d) => _selectedAddresses.contains(d.address)).toList(),
          lastParkingLocation: _lastParkingLocation,
          isPremium: _isPremium,
          onTestAlarm: () {
            // TODO: trigger test notification via notification_service
          },
          onManageCars: () => setState(() => _screen = _Screen.cars),
          onManageIgnoredLocations: () => setState(() => _screen = _Screen.ignoredLocations),
          onFindCar: () {
            // TODO: open maps with lastParkingLocation via url_launcher
          },
          onBuyApp: () => _billingRepo.launchPurchaseFlow(),
        );

      case _Screen.ignoredLocations:
        return IgnoredLocationsScreen(
          ignoredLocations: _ignoredLocations,
          currentLocation: _lastParkingLocation,
          onDelete: (loc) async {
            await _ignoredRepo.deleteIgnoredLocation(loc.id);
            setState(() => _ignoredLocations.removeWhere((l) => l.id == loc.id));
          },
          onAddCurrentLocation: (setStatus) async {
            if (_lastParkingLocation == null) {
              setStatus('Ingen nuværende placering tilgængelig.');
              return;
            }
            await _ignoredRepo.addIgnoredLocation(_lastParkingLocation!);
            final updated = await _ignoredRepo.getIgnoredLocations();
            setState(() => _ignoredLocations = updated);
            setStatus('Placering tilføjet.');
          },
          onClearAll: () async {
            await _ignoredRepo.clearIgnoredLocations();
            setState(() => _ignoredLocations.clear());
          },
          onOpenMap: (loc) {
            // TODO: open maps via url_launcher
          },
          onBack: () => setState(() => _screen = _Screen.home),
        );

      case _Screen.reminder:
        if (_reminderLocation == null) {
          return const SizedBox.shrink();
        }
        return ReminderScreen(
          parkingLocation: _reminderLocation!,
          onAddIgnoredLocation: () async {
            await _ignoredRepo.addIgnoredLocation(_reminderLocation!);
            final updated = await _ignoredRepo.getIgnoredLocations();
            setState(() {
              _ignoredLocations = updated;
              _screen = _Screen.home;
            });
          },
          onNavigateToCar: () {
            // TODO: open maps via url_launcher
            setState(() => _screen = _Screen.home);
          },
          onDismiss: () => setState(() => _screen = _Screen.home),
        );
    }
  }
}
