import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'car_brands.dart';
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
import 'screens/sound_settings_screen.dart';
import 'screens/other_settings_screen.dart';
import 'screens/parking_apps_screen.dart';
import 'models/car_device.dart';
import 'models/location_snapshot.dart';
import 'models/ignored_location.dart';
import 'services/bluetooth_service.dart' as bt;
import 'services/location_service.dart';
import 'services/motion_service.dart';
import 'services/notification_service.dart';
import 'theme.dart';

enum _Screen { welcome, cars, permissions, home, ignoredLocations, reminder, setReminder, setup, soundSettings, otherSettings, parkingApps }

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
  Set<String> _usbAccessories = {};
  bool _btOnlyMode = false;
  bool _btOnlyUserSet = false;
  bool _isPremium = false;
  List<IgnoredLocation> _ignoredLocations = [];
  LocationSnapshot? _lastParkingLocation;
  LocationSnapshot? _reminderLocation;
  bool _showSetupDone = false;
  // True while the parking-apps screen is shown as a step of the initial setup
  // flow (vs. opened from the Opsætning submenu).
  bool _parkingAppsSetupStep = false;

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
    _motionService.stopMonitoring();
    _billingRepo.dispose();
    super.dispose();
  }

  void _stopAlarmVibration() {
    const MethodChannel('dk.parkingson/alarm').invokeMethod('stopAlarmVibration');
  }

  void _showSetupDoneDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.setupDoneTitle),
        content: Text(l10n.setupDoneBody),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.ok),
          ),
        ],
      ),
    );
  }

  Future<void> _loadState() async {
    final btOnly = await _carRepo.getBtOnlyMode();
    final btOnlyUserSet = await _carRepo.getBtOnlyModeUserSet();
    final carAddresses = await _carRepo.getSelectedCarAddresses();
    final usbAccessories = await _carRepo.getSelectedUsbAccessories();
    final setupDone = await _carRepo.isSetupCompleted();
    final ignored = await _ignoredRepo.getIgnoredLocations();
    final lastLocation = await _ignoredRepo.getLastParkingLocation();
    final paired = await _btService.getPairedDevices();

    if (mounted) {
      setState(() {
        _btOnlyMode = btOnly;
        _btOnlyUserSet = btOnlyUserSet;
        _selectedAddresses = carAddresses;
        _usbAccessories = usbAccessories;
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
    // First time here: pre-select the devices that look like a car, so the user
    // doesn't have to figure out which paired device is their car.
    if (_selectedAddresses.isEmpty) {
      final likely = paired
          .where((d) => looksLikeCar(d.name))
          .map((d) => d.address)
          .toSet();
      if (likely.isNotEmpty) {
        _selectedAddresses = likely;
        await _carRepo.saveSelectedCarAddresses(likely);
        _motionService.updateAddresses(likely);
      }
    }
    // Pre-selected (or already-selected) BT/USB cars auto-enable "monitor BT/USB
    // only" as a smart default, unless the user has set it themselves.
    await _syncBtOnlyDefault();
    if (mounted) setState(() { _pairedDevices = paired; _screen = _Screen.cars; });
  }

  Future<void> _registerUsbAccessory(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    String? id;
    try {
      id = await const MethodChannel('dk.parkingson/alarm')
          .invokeMethod<String>('getUsbAccessory');
    } catch (_) {
      id = null;
    }
    if (id == null || id.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.usbCarCaptureFailed)),
        );
      }
      return;
    }
    final updated = Set<String>.from(_usbAccessories)..add(id);
    setState(() => _usbAccessories = updated);
    await _carRepo.saveSelectedUsbAccessories(updated);
    _motionService.updateUsbAccessories(updated);
    await _syncBtOnlyDefault();
  }

  Future<void> _removeUsbAccessory(String id) async {
    final updated = Set<String>.from(_usbAccessories)..remove(id);
    setState(() => _usbAccessories = updated);
    await _carRepo.saveSelectedUsbAccessories(updated);
    _motionService.updateUsbAccessories(updated);
    await _syncBtOnlyDefault();
  }

  /// Smart default for "monitor BT/USB cars only": as long as the user hasn't
  /// set the checkbox themselves, keep it in sync with whether any BT/USB car
  /// exists — on when there's at least one (fewer false alarms), off otherwise.
  /// Once the user toggles it (see onBtOnlyModeChange), we stop touching it.
  Future<void> _syncBtOnlyDefault() async {
    if (_btOnlyUserSet) return;
    final shouldEnable =
        _selectedAddresses.isNotEmpty || _usbAccessories.isNotEmpty;
    if (_btOnlyMode == shouldEnable) return;
    if (!mounted) return;
    setState(() => _btOnlyMode = shouldEnable);
    await _carRepo.saveBtOnlyMode(shouldEnable);
    const MethodChannel('dk.parkingson/alarm').invokeMethod(
        shouldEnable ? 'stopMotionDetection' : 'startMotionDetection');
  }

  void _startMonitoring() {
    _motionService.startMonitoring(
      onParkingDetected: (snapshot) {
        // The background isolate already fired the alarm (sound + voice are
        // handled natively); just open the reminder screen.
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
    _motionService.updateUsbAccessories(_usbAccessories);
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
      // Match the device language when we support it; otherwise fall back to
      // English (not the alphabetically-first locale, which would be Danish).
      localeResolutionCallback: (deviceLocale, supported) {
        if (deviceLocale != null) {
          for (final l in supported) {
            if (l.languageCode == deviceLocale.languageCode) return l;
          }
        }
        return const Locale('en');
      },
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
          usbAccessories: _usbAccessories,
          btOnlyMode: _btOnlyMode,
          onRegisterUsbAccessory: () => _registerUsbAccessory(context),
          onRemoveUsbAccessory: _removeUsbAccessory,
          onSelectionChange: (addresses) async {
            setState(() => _selectedAddresses = addresses);
            await _carRepo.saveSelectedCarAddresses(addresses);
            _motionService.updateAddresses(addresses);
            await _syncBtOnlyDefault();
          },
          onBtOnlyModeChange: (v) async {
            // The user set it themselves — stop auto-managing it from now on.
            setState(() {
              _btOnlyMode = v;
              _btOnlyUserSet = true;
            });
            await _carRepo.saveBtOnlyMode(v);
            await _carRepo.saveBtOnlyModeUserSet(true);
            const channel = MethodChannel('dk.parkingson/alarm');
            channel.invokeMethod(
                v ? 'stopMotionDetection' : 'startMotionDetection');
          },
          onNext: () {
            // Not the final step anymore — continue to the parking-apps step.
            setState(() {
              _parkingAppsSetupStep = true;
              _screen = _Screen.parkingApps;
            });
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
        if (_showSetupDone) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && _showSetupDone) {
              _showSetupDone = false;
              _showSetupDoneDialog(context);
            }
          });
        }
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
            // Short delay so you can lock the phone (or background the app) after
            // tapping, to test the full-screen-over-lock-screen behaviour and the
            // swipe-away-to-stop notification.
            await Future<void>.delayed(const Duration(seconds: 10));
            // Show the visual notification and fire the DND-aware alarm
            // (sound + voice, or vibration, are handled natively).
            await NotificationService().showParkingReminder(payload: snapshot.encode());
            await fireAlarm(
              l10n.ttsRemember,
              title: l10n.notifParkingTitle,
              body: l10n.notifParkingBody,
            );
            if (mounted) {
              setState(() {
                _reminderLocation = snapshot;
                _screen = _Screen.reminder;
              });
            }
          },
          onSound: () => setState(() => _screen = _Screen.soundSettings),
          onParkingApps: () => setState(() {
            _parkingAppsSetupStep = false;
            _screen = _Screen.parkingApps;
          }),
          onOther: () => setState(() => _screen = _Screen.otherSettings),
          onBack: () => setState(() => _screen = _Screen.home),
        );

      case _Screen.soundSettings:
        return SoundSettingsScreen(
          onBack: () => setState(() => _screen = _Screen.setup),
        );

      case _Screen.otherSettings:
        return OtherSettingsScreen(
          onBack: () => setState(() => _screen = _Screen.setup),
        );

      case _Screen.parkingApps:
        if (_parkingAppsSetupStep) {
          // Final step of the initial setup flow.
          return ParkingAppsScreen(
            onContinue: () async {
              await _carRepo.saveSetupCompleted(true);
              _startMonitoring();
              if (mounted) {
                setState(() {
                  _parkingAppsSetupStep = false;
                  _screen = _Screen.home;
                  _showSetupDone = true;
                });
              }
            },
          );
        }
        return ParkingAppsScreen(
          onBack: () => setState(() => _screen = _Screen.setup),
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
            _stopAlarmVibration();
            final name = await _locationService.reverseGeocode(
                _reminderLocation!.latitude, _reminderLocation!.longitude);
            await _ignoredRepo.addIgnoredLocation(_reminderLocation!, name: name);
            final updated = await _ignoredRepo.getIgnoredLocations();
            setState(() {
              _ignoredLocations = updated;
              _screen = _Screen.home;
            });
          },
          onDismiss: () {
            _stopAlarmVibration();
            setState(() => _screen = _Screen.home);
          },
        );
    }
  }
}
