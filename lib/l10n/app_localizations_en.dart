// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get welcomeTagline => 'Avoid parking fines';

  @override
  String get welcomeBody =>
      'Get a reminder when you leave one of your cars, and automatically save the spot so you can find the car again.';

  @override
  String get getStarted => 'Get started';

  @override
  String get carsTitle => 'Choose your cars';

  @override
  String get btOnlyMode => 'Use Bluetooth only, to reduce false alarms';

  @override
  String get carsBody =>
      'Choose your car\'s Bluetooth — the connection your phone makes to the car stereo when you get in. Don\'t choose headphones or a headset. We\'ve pre-selected the ones that look like cars.';

  @override
  String get carsWithBluetooth => 'Cars with Bluetooth';

  @override
  String get noPairedDevices => 'No paired Bluetooth devices found.';

  @override
  String get carsWithUsb => 'Car via USB cable';

  @override
  String get usbCarsBody =>
      'If you connect your phone to the car with a cable (e.g. Android Auto), plug it in now and register the car.';

  @override
  String get registerConnectedUsbCar => 'Register connected car';

  @override
  String get noUsbCarRegistered => 'No USB car registered yet.';

  @override
  String get usbCarCaptureFailed =>
      'No car connection found. Plug the cable into the car and try again.';

  @override
  String get activateParkingMonitoring => 'Activate parking monitoring';

  @override
  String get save => 'Save';

  @override
  String get systemBluetoothSettings => 'System Bluetooth settings';

  @override
  String get permissionsTitle => 'Permissions';

  @override
  String get permissionsBody =>
      'The app needs the following permissions to monitor your car in the background.';

  @override
  String get activateMonitoring => 'Activate monitoring';

  @override
  String get grantAllToContinue => 'Grant all permissions above to continue.';

  @override
  String get openSettings => 'Settings';

  @override
  String get grant => 'Grant';

  @override
  String get ok => 'OK';

  @override
  String get permBluetooth => 'Bluetooth';

  @override
  String get permBluetoothDesc => 'Detect when you leave your car';

  @override
  String get permLocation => 'Location';

  @override
  String get permLocationDesc =>
      'Save the parking spot — choose \"Allow all the time\" so it works in the background';

  @override
  String get permActivity => 'Physical activity';

  @override
  String get permActivityDesc => 'Detect driving and walking';

  @override
  String get permNotifications => 'Notifications';

  @override
  String get permNotificationsDesc => 'Send parking reminders';

  @override
  String get permBattery => 'Unrestricted background';

  @override
  String get permBatteryDesc => 'So battery saving doesn\'t stop monitoring';

  @override
  String get grantAllPermissions => 'Grant all permissions';

  @override
  String get permMicrophone => 'Microphone';

  @override
  String get permMicrophoneDesc => 'For voice commands on the reminder';

  @override
  String get voiceListening => 'Listening…';

  @override
  String get voicePrompt => 'Say e.g. \"30 minutes\" or \"Stop alarms here\"';

  @override
  String voiceTimerSet(String time) {
    return 'Parking time set to $time';
  }

  @override
  String get voiceNotUnderstood => 'Didn\'t catch that — try again';

  @override
  String get voiceIgnoreConfirm => 'Ignoring this location';

  @override
  String get setupDoneTitle => 'Parkingson is running';

  @override
  String get setupDoneBody =>
      'Parkingson is now waiting for your next parking. You\'ll get a reminder when you leave the car.';

  @override
  String get monitoringActive => 'Monitoring active';

  @override
  String lastParkedAt(String time) {
    return 'Last parked $time';
  }

  @override
  String get lastParkedNever => 'Last parked not measured yet';

  @override
  String parkingExpires(String time) {
    return 'Parking expires $time';
  }

  @override
  String get removeAdsButton =>
      'Remove ads and support a nice developer. Almost free!';

  @override
  String get testReminder => 'Test reminder';

  @override
  String get testReminderDesc => 'See notification, siren and voice';

  @override
  String get manageCars => 'Manage cars';

  @override
  String get manageCarsDesc => 'Add, remove or change cars';

  @override
  String get findCar => 'Find my car';

  @override
  String findCarRoute(String time) {
    return 'Route to last parked $time';
  }

  @override
  String get findCarNone => 'No parking location saved yet';

  @override
  String get ignoredLocationsAction => 'Ignored locations';

  @override
  String get ignoredLocationsActionDesc =>
      'Places that don\'t trigger an alarm';

  @override
  String get setReminderTitle => 'Reminder';

  @override
  String get setReminderDesc => 'Set a time to walk back to the car';

  @override
  String get retry => 'Try again';

  @override
  String get setupTitle => 'Setup';

  @override
  String get setupDesc => 'Customize the app';

  @override
  String get soundTitle => 'Sound';

  @override
  String get soundDesc => 'Alarm volume';

  @override
  String get soundUsePhone => 'Use the phone\'s volume';

  @override
  String get soundUseApp => 'Use the app\'s volume';

  @override
  String get soundVolume => 'App volume';

  @override
  String get soundAlarmSound => 'Alarm sound';

  @override
  String get soundVibrateDnd => 'Only vibrate in Do Not Disturb';

  @override
  String get soundVibrateSilent => 'Only vibrate when volume is 0';

  @override
  String get parkingAppsTitle => 'Parking apps';

  @override
  String get parkingAppsDesc => 'Choose the apps you use for parking';

  @override
  String get parkingAppsBody =>
      'Select the apps you use to pay for parking, e.g. EasyPark or Q-Park.';

  @override
  String get parkingAppsSearch => 'Search apps';

  @override
  String get parkingAppsKnown => 'Parking apps';

  @override
  String get parkingAppsOther => 'Other apps';

  @override
  String get parkingAppsNone => 'No apps found.';

  @override
  String get batteryCardTitle =>
      'Recommended: exempt from battery optimization';

  @override
  String get batteryCardBody =>
      'Optional. Without this, Android (especially Samsung) may stop background motion monitoring, so parking without Bluetooth isn\'t always detected.';

  @override
  String get batteryCardButton => 'Allow unrestricted background';

  @override
  String get exactAlarmCardTitle => 'Recommended: allow alarms & reminders';

  @override
  String get exactAlarmCardBody =>
      'Lets the app restart monitoring by itself after you close it from recents (\"Clear all\"). Without it, monitoring stays off until you reopen the app.';

  @override
  String get exactAlarmCardButton => 'Allow alarms & reminders';

  @override
  String get motionFetching => 'Motion: fetching status…';

  @override
  String get motionUnavailable => 'Motion: status unavailable';

  @override
  String get motionNoPermission => 'Motion: no physical activity permission';

  @override
  String motionError(String error) {
    return 'Motion error: $error';
  }

  @override
  String get motionRegistering => 'Motion: registering…';

  @override
  String get motionActive => 'Motion active';

  @override
  String get motionDormant => 'Motion dormant';

  @override
  String get motionWaitingData => 'waiting for data';

  @override
  String get motionVehicleTimer => 'vehicle timer running';

  @override
  String get motionWakesOnMovement => 'wakes on movement';

  @override
  String get activityInVehicle => 'In vehicle';

  @override
  String get activityOnBicycle => 'On bicycle';

  @override
  String get activityOnFoot => 'On foot';

  @override
  String get activityStill => 'Still';

  @override
  String get activityTilting => 'Tilting';

  @override
  String get activityWalking => 'Walking';

  @override
  String get activityRunning => 'Running';

  @override
  String get activityUnknown => 'Unknown';

  @override
  String get ignoredLocationsTitle => 'Ignored locations';

  @override
  String ignoredLocationsRadiusInfo(int meters) {
    return 'Alarms are not shown within $meters metres of these places.';
  }

  @override
  String get addCurrentLocation => 'Add current location';

  @override
  String get sortBy => 'Sort by';

  @override
  String get sortTime => 'Time';

  @override
  String get sortName => 'Name';

  @override
  String get sortDistance => 'Distance';

  @override
  String get noIgnoredLocations => 'No ignored locations';

  @override
  String get noIgnoredLocationsBody =>
      'You can add a location from a reminder.';

  @override
  String get ignoredLocationDefault => 'Ignored location';

  @override
  String addedAt(String time) {
    return 'Added $time';
  }

  @override
  String get tapToOpenMap => 'Tap to open in map';

  @override
  String get deleteAll => 'Delete all';

  @override
  String get backToOverview => 'Back to overview';

  @override
  String get finishSetup => 'Done';

  @override
  String get locationFetchError => 'Could not get location.';

  @override
  String get locationAdded => 'Location added.';

  @override
  String get reminderTitle => 'Remember to pay for parking!';

  @override
  String get reminderBody =>
      'We detected that you left your car. Remember to pay for parking!';

  @override
  String get coordinates => 'Coordinates';

  @override
  String get registeredLabel => 'Registered';

  @override
  String get ignoreThisLocation => 'Stop alarms here';

  @override
  String get timerCheckbox => 'Remind me to walk back in time';

  @override
  String get timerHelp => 'Set how long you may park here';

  @override
  String get pickTime => 'Pick time';

  @override
  String expiresAt(String time) {
    return 'Expires at $time';
  }

  @override
  String get pickExpiryTime => 'Choose expiry time';

  @override
  String get timerConfirmBody =>
      'You\'ll be notified in good time to walk back to the car.';

  @override
  String get close => 'Close';

  @override
  String ignoreHint(int meters) {
    return 'Tap \"Always ignore\" for places like home or work, where you rarely need to pay for parking. The alarm won\'t show again within $meters metres of here. Over time you\'ll experience fewer unnecessary alarms.';
  }

  @override
  String durationMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String durationHours(int hours) {
    return '$hours h';
  }

  @override
  String durationHoursMinutes(int hours, int minutes) {
    return '$hours h $minutes min';
  }

  @override
  String spokenMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count minutes',
      one: '1 minute',
    );
    return '$_temp0';
  }

  @override
  String spokenHours(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count hours',
      one: '1 hour',
    );
    return '$_temp0';
  }

  @override
  String spokenHoursAndMinutes(String hours, String minutes) {
    return '$hours and $minutes';
  }

  @override
  String get notifParkingTitle => 'Remember to pay for parking!';

  @override
  String get notifParkingBody => 'We detected that you left your car.';

  @override
  String get notifWalkBackTitle => 'Hurry back to the car!';

  @override
  String notifWalkBackBody(int minutes) {
    return 'You should walk now — walking time approx. $minutes min and parking expires soon.';
  }

  @override
  String get ttsRemember =>
      'Remember parking, or turn off the alarm for this place';

  @override
  String get monitoringTitle => 'Parkingson';

  @override
  String get monitoringBody => 'Monitoring your car...';
}
