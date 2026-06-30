import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import 'services/bluetooth_service.dart' as bt;
import 'services/location_service.dart';
import 'services/motion_service.dart';
import 'services/notification_service.dart';
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
  final _btService = bt.BluetoothService();
  final _locationService = LocationService();
  final _motionService = MotionService();

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
    _motionService.initialize();
  }

  @override
  void dispose() {
    _btService.stopMonitoring();
    _motionService.stopMonitoring();
    _billingRepo.dispose();
    super.dispose();
  }

  Future<void> _loadState() async {
    final btOnly = await _carRepo.getBtOnlyMode();
    final carAddresses = await _carRepo.getSelectedCarAddresses();
    final setupDone = await _carRepo.isSetupCompleted();
    final ignored = await _ignoredRepo.getIgnoredLocations();
    final lastLocation = await _ignoredRepo.getLastParkingLocation();
    final paired = await _btService.getPairedDevices();

    if (mounted) {
      setState(() {
        _btOnlyMode = btOnly;
        _selectedAddresses = carAddresses;
        _ignoredLocations = ignored;
        _lastParkingLocation = lastLocation;
        _pairedDevices = paired;
        _screen = setupDone ? _Screen.home : _Screen.welcome;
      });
      if (setupDone) _startMonitoring();
    }
  }

  Future<void> _goToCars() async {
    final paired = await _btService.getPairedDevices();
    if (mounted) setState(() { _pairedDevices = paired; _screen = _Screen.cars; });
  }

  void _startMonitoring() {
    _btService.startMonitoring(
      _selectedAddresses,
      onDisconnect: (_) => _onCarParked(),
    );
    _motionService.startMonitoring(
      onParkingDetected: (snapshot) {
        if (mounted) {
          setState(() {
            _reminderLocation = snapshot;
            _lastParkingLocation = snapshot;
            _screen = _Screen.reminder;
          });
        }
      },
    );
    _motionService.updateAddresses(_selectedAddresses);
  }

  Future<void> _onCarParked() async {
    final snapshot = await _locationService.getCurrentLocation();
    if (snapshot == null) return;
    if (await _ignoredRepo.isIgnored(snapshot)) return;
    await _ignoredRepo.saveLastParkingLocation(snapshot);
    await Future.wait([
      NotificationService().showParkingReminder(payload: snapshot.encode()),
      NotificationService().playAlarm(),
    ]);
    if (mounted) {
      setState(() {
        _reminderLocation = snapshot;
        _lastParkingLocation = snapshot;
        _screen = _Screen.reminder;
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
        return WelcomeScreen(
          onGetStarted: () => setState(() => _screen = _Screen.permissions),
        );

      case _Screen.cars:
        return CarsScreen(
          pairedDevices: _pairedDevices,
          selectedAddresses: _selectedAddresses,
          btOnlyMode: _btOnlyMode,
          onSelectionChange: (addresses) async {
            setState(() => _selectedAddresses = addresses);
            await _carRepo.saveSelectedCarAddresses(addresses);
            _btService.updateSelectedAddresses(addresses);
            _motionService.updateAddresses(addresses);
          },
          onBtOnlyModeChange: (v) async {
            setState(() => _btOnlyMode = v);
            await _carRepo.saveBtOnlyMode(v);
          },
          onNext: () async {
            await _carRepo.saveSetupCompleted(true);
            _startMonitoring();
            if (mounted) setState(() => _screen = _Screen.home);
          },
          onOpenBluetoothSettings: () async {
            const channel = MethodChannel('dk.parkingson/alarm');
            await channel.invokeMethod('openBluetoothSettings');
          },
        );

      case _Screen.permissions:
        return PermissionsScreen(
          onActivate: _goToCars,
        );

      case _Screen.home:
        return HomeScreen(
          monitoredCars: _pairedDevices
              .where((d) => _selectedAddresses.contains(d.address))
              .toList(),
          lastParkingLocation: _lastParkingLocation,
          isPremium: _isPremium,
          onTestAlarm: () async {
            final snapshot = await _locationService.getCurrentLocation() ??
                LocationSnapshot(
                  latitude: 0,
                  longitude: 0,
                  capturedAtMillis: DateTime.now().millisecondsSinceEpoch,
                );
            // Show notification + play alarm sound in foreground
            await Future.wait([
              NotificationService().showParkingReminder(payload: snapshot.encode()),
              NotificationService().playAlarm(),
            ]);
            if (mounted) {
              setState(() {
                _reminderLocation = snapshot;
                _screen = _Screen.reminder;
              });
            }
          },
          onManageCars: _goToCars,
          onManageIgnoredLocations: () =>
              setState(() => _screen = _Screen.ignoredLocations),
          onFindCar: () {
            if (_lastParkingLocation == null) return;
            _locationService.navigateTo(
              _lastParkingLocation!.latitude,
              _lastParkingLocation!.longitude,
            );
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
            final snapshot = await _locationService.getCurrentLocation();
            if (snapshot == null) {
              setStatus('Kunne ikke hente placering.');
              return;
            }
            final name = await _locationService.reverseGeocode(
                snapshot.latitude, snapshot.longitude);
            await _ignoredRepo.addIgnoredLocation(snapshot, name: name);
            final updated = await _ignoredRepo.getIgnoredLocations();
            setState(() => _ignoredLocations = updated);
            setStatus('Placering tilføjet.');
          },
          onClearAll: () async {
            await _ignoredRepo.clearIgnoredLocations();
            setState(() => _ignoredLocations.clear());
          },
          onOpenMap: (loc) => _locationService.openInMaps(
              loc.latitude, loc.longitude, loc.name ?? 'Parkering'),
          onBack: () => setState(() => _screen = _Screen.home),
        );

      case _Screen.reminder:
        if (_reminderLocation == null) {
          return const SizedBox.shrink();
        }
        return ReminderScreen(
          parkingLocation: _reminderLocation!,
          onAddIgnoredLocation: () async {
            final name = await _locationService.reverseGeocode(
                _reminderLocation!.latitude, _reminderLocation!.longitude);
            await _ignoredRepo.addIgnoredLocation(_reminderLocation!, name: name);
            final updated = await _ignoredRepo.getIgnoredLocations();
            setState(() {
              _ignoredLocations = updated;
              _screen = _Screen.home;
            });
          },
          onNavigateToCar: () {
            _locationService.navigateTo(
              _reminderLocation!.latitude,
              _reminderLocation!.longitude,
            );
            setState(() => _screen = _Screen.home);
          },
          onDismiss: () => setState(() => _screen = _Screen.home),
        );
    }
  }
}
