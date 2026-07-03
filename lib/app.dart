import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'l10n/app_localizations.dart';
import 'repositories/car_repository.dart';
import 'repositories/billing_repository.dart';
import 'repositories/ignored_location_repository.dart';
import 'screens/welcome_screen.dart';
import 'screens/cars_screen.dart';
import 'screens/permissions_screen.dart';
import 'screens/home_screen.dart';
import 'screens/ignored_locations_screen.dart';
import 'screens/reminder_screen.dart';
import 'screens/set_reminder_screen.dart';
import 'screens/setup_screen.dart';
import 'models/car_device.dart';
import 'models/location_snapshot.dart';
import 'models/ignored_location.dart';
import 'services/bluetooth_service.dart' as bt;
import 'services/location_service.dart';
import 'services/motion_service.dart';
import 'services/notification_service.dart';
import 'theme.dart';

enum _Screen { welcome, cars, permissions, home, ignoredLocations, reminder, setReminder, setup }

class ParkingsonApp extends StatefulWidget {
  const ParkingsonApp({super.key});

  @override
  State<ParkingsonApp> createState() => _ParkingsonAppState();
}

class _ParkingsonAppState extends State<ParkingsonApp> with WidgetsBindingObserver {
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
    WidgetsBinding.instance.addObserver(this);
    _loadState();
    _billingRepo.initialize().then((_) {
      _billingRepo.premiumStream.listen((v) {
        if (mounted) setState(() => _isPremium = v);
      });
    });
    _motionService.initialize();
    // Speak any pending alarm voice reminder left while the app was closed.
    speakPendingVoice();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _motionService.stopMonitoring();
    _billingRepo.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Opening the app (any way) stops the Do Not Disturb alarm vibration and
    // plays the deferred voice reminder.
    if (state == AppLifecycleState.resumed) {
      const MethodChannel('dk.parkingson/alarm').invokeMethod('stopAlarmVibration');
      speakPendingVoice();
    }
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
    _motionService.startMonitoring(
      onParkingDetected: (snapshot) {
        // The background isolate already fired the alarm; when the UI is alive,
        // speak the deferred voice reminder (after the alarm) and open the
        // reminder screen.
        speakPendingVoice(delay: voiceAfterAlarmDelay);
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
    // Motion detection (cars without Bluetooth) runs natively via Activity
    // Recognition. Enable it unless the user chose Bluetooth-only mode.
    const channel = MethodChannel('dk.parkingson/alarm');
    channel.invokeMethod(
        _btOnlyMode ? 'stopMotionDetection' : 'startMotionDetection');
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Parkingson',
      theme: buildTheme(),
      debugShowCheckedModeBanner: false,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Builder(builder: (context) => _buildScreen(context)),
    );
  }

  Widget _buildScreen(BuildContext context) {
    final l10n = AppLocalizations.of(context);
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
            _motionService.updateAddresses(addresses);
          },
          onBtOnlyModeChange: (v) async {
            setState(() => _btOnlyMode = v);
            await _carRepo.saveBtOnlyMode(v);
            const channel = MethodChannel('dk.parkingson/alarm');
            channel.invokeMethod(
                v ? 'stopMotionDetection' : 'startMotionDetection');
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
          onSetReminder: () => setState(() => _screen = _Screen.setReminder),
          onSetup: () => setState(() => _screen = _Screen.setup),
        );

      case _Screen.setup:
        return SetupScreen(
          onManageCars: _goToCars,
          onTestAlarm: () async {
            final snapshot = await _locationService.getCurrentLocation() ??
                LocationSnapshot(
                  latitude: 0,
                  longitude: 0,
                  capturedAtMillis: DateTime.now().millisecondsSinceEpoch,
                );
            // Show the visual notification, fire the DND-aware alarm, and speak
            // the voice reminder (we're in the foreground here).
            await NotificationService().showParkingReminder(payload: snapshot.encode());
            await fireAlarm(l10n.ttsRemember);
            await speakPendingVoice(delay: voiceAfterAlarmDelay);
            if (mounted) {
              setState(() {
                _reminderLocation = snapshot;
                _screen = _Screen.reminder;
              });
            }
          },
          onBack: () => setState(() => _screen = _Screen.home),
        );

      case _Screen.setReminder:
        return SetReminderScreen(
          getLocation: _locationService.getCurrentLocation,
          fallbackLocation: _lastParkingLocation,
          onDone: () => setState(() => _screen = _Screen.home),
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
              setStatus(l10n.locationFetchError);
              return;
            }
            final name = await _locationService.reverseGeocode(
                snapshot.latitude, snapshot.longitude);
            await _ignoredRepo.addIgnoredLocation(snapshot, name: name);
            final updated = await _ignoredRepo.getIgnoredLocations();
            setState(() => _ignoredLocations = updated);
            setStatus(l10n.locationAdded);
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
