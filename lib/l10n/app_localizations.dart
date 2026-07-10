import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_da.dart';
import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fi.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_is.dart';
import 'app_localizations_nb.dart';
import 'app_localizations_sv.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('da'),
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fi'),
    Locale('fr'),
    Locale('is'),
    Locale('nb'),
    Locale('sv'),
  ];

  /// No description provided for @welcomeTagline.
  ///
  /// In en, this message translates to:
  /// **'Avoid parking fines'**
  String get welcomeTagline;

  /// No description provided for @welcomeBody.
  ///
  /// In en, this message translates to:
  /// **'Get a reminder when you leave one of your cars, and automatically save the spot so you can find the car again.'**
  String get welcomeBody;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get getStarted;

  /// No description provided for @carsTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose your cars'**
  String get carsTitle;

  /// No description provided for @btOnlyMode.
  ///
  /// In en, this message translates to:
  /// **'Use Bluetooth only, to reduce false alarms'**
  String get btOnlyMode;

  /// No description provided for @carsBody.
  ///
  /// In en, this message translates to:
  /// **'Choose your car\'s Bluetooth — the connection your phone makes to the car stereo when you get in. Don\'t choose headphones or a headset. We\'ve pre-selected the ones that look like cars.'**
  String get carsBody;

  /// No description provided for @carsWithBluetooth.
  ///
  /// In en, this message translates to:
  /// **'Cars with Bluetooth'**
  String get carsWithBluetooth;

  /// No description provided for @noPairedDevices.
  ///
  /// In en, this message translates to:
  /// **'No paired Bluetooth devices found.'**
  String get noPairedDevices;

  /// No description provided for @carsWithUsb.
  ///
  /// In en, this message translates to:
  /// **'Car via USB cable'**
  String get carsWithUsb;

  /// No description provided for @usbCarsBody.
  ///
  /// In en, this message translates to:
  /// **'If you connect your phone to the car with a cable (e.g. Android Auto), plug it in now and register the car.'**
  String get usbCarsBody;

  /// No description provided for @registerConnectedUsbCar.
  ///
  /// In en, this message translates to:
  /// **'Register connected car'**
  String get registerConnectedUsbCar;

  /// No description provided for @noUsbCarRegistered.
  ///
  /// In en, this message translates to:
  /// **'No USB car registered yet.'**
  String get noUsbCarRegistered;

  /// No description provided for @usbCarCaptureFailed.
  ///
  /// In en, this message translates to:
  /// **'No car connection found. Plug the cable into the car and try again.'**
  String get usbCarCaptureFailed;

  /// No description provided for @activateParkingMonitoring.
  ///
  /// In en, this message translates to:
  /// **'Activate parking monitoring'**
  String get activateParkingMonitoring;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @systemBluetoothSettings.
  ///
  /// In en, this message translates to:
  /// **'System Bluetooth settings'**
  String get systemBluetoothSettings;

  /// No description provided for @permissionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Permissions'**
  String get permissionsTitle;

  /// No description provided for @permissionsBody.
  ///
  /// In en, this message translates to:
  /// **'The app needs the following permissions to monitor your car in the background.'**
  String get permissionsBody;

  /// No description provided for @activateMonitoring.
  ///
  /// In en, this message translates to:
  /// **'Activate monitoring'**
  String get activateMonitoring;

  /// No description provided for @grantAllToContinue.
  ///
  /// In en, this message translates to:
  /// **'Grant all permissions above to continue.'**
  String get grantAllToContinue;

  /// No description provided for @openSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get openSettings;

  /// No description provided for @grant.
  ///
  /// In en, this message translates to:
  /// **'Grant'**
  String get grant;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @permBluetooth.
  ///
  /// In en, this message translates to:
  /// **'Bluetooth'**
  String get permBluetooth;

  /// No description provided for @permBluetoothDesc.
  ///
  /// In en, this message translates to:
  /// **'Detect when you leave your car'**
  String get permBluetoothDesc;

  /// No description provided for @permLocation.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get permLocation;

  /// No description provided for @permLocationDesc.
  ///
  /// In en, this message translates to:
  /// **'Save the parking spot — choose \"Allow all the time\" so it works in the background'**
  String get permLocationDesc;

  /// No description provided for @permActivity.
  ///
  /// In en, this message translates to:
  /// **'Physical activity'**
  String get permActivity;

  /// No description provided for @permActivityDesc.
  ///
  /// In en, this message translates to:
  /// **'Detect driving and walking'**
  String get permActivityDesc;

  /// No description provided for @permNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get permNotifications;

  /// No description provided for @permNotificationsDesc.
  ///
  /// In en, this message translates to:
  /// **'Send parking reminders'**
  String get permNotificationsDesc;

  /// No description provided for @permBattery.
  ///
  /// In en, this message translates to:
  /// **'Unrestricted background'**
  String get permBattery;

  /// No description provided for @permBatteryDesc.
  ///
  /// In en, this message translates to:
  /// **'So battery saving doesn\'t stop monitoring'**
  String get permBatteryDesc;

  /// No description provided for @grantAllPermissions.
  ///
  /// In en, this message translates to:
  /// **'Grant all permissions'**
  String get grantAllPermissions;

  /// No description provided for @permMicrophone.
  ///
  /// In en, this message translates to:
  /// **'Microphone'**
  String get permMicrophone;

  /// No description provided for @permMicrophoneDesc.
  ///
  /// In en, this message translates to:
  /// **'For voice commands on the reminder'**
  String get permMicrophoneDesc;

  /// No description provided for @voiceListening.
  ///
  /// In en, this message translates to:
  /// **'Listening…'**
  String get voiceListening;

  /// No description provided for @voicePrompt.
  ///
  /// In en, this message translates to:
  /// **'Say \"ignore\" or \"parking time 30 minutes\"'**
  String get voicePrompt;

  /// No description provided for @voiceTimerSet.
  ///
  /// In en, this message translates to:
  /// **'Parking time set to {time}'**
  String voiceTimerSet(String time);

  /// No description provided for @voiceNotUnderstood.
  ///
  /// In en, this message translates to:
  /// **'Didn\'t catch that — try again'**
  String get voiceNotUnderstood;

  /// No description provided for @voiceIgnoreConfirm.
  ///
  /// In en, this message translates to:
  /// **'Ignoring this location'**
  String get voiceIgnoreConfirm;

  /// No description provided for @setupDoneTitle.
  ///
  /// In en, this message translates to:
  /// **'Parkingson is running'**
  String get setupDoneTitle;

  /// No description provided for @setupDoneBody.
  ///
  /// In en, this message translates to:
  /// **'Parkingson is now waiting for your next parking. You\'ll get a reminder when you leave the car.'**
  String get setupDoneBody;

  /// No description provided for @monitoringActive.
  ///
  /// In en, this message translates to:
  /// **'Monitoring active'**
  String get monitoringActive;

  /// No description provided for @lastParkedAt.
  ///
  /// In en, this message translates to:
  /// **'Last parked {time}'**
  String lastParkedAt(String time);

  /// No description provided for @lastParkedNever.
  ///
  /// In en, this message translates to:
  /// **'Last parked not measured yet'**
  String get lastParkedNever;

  /// No description provided for @parkingExpires.
  ///
  /// In en, this message translates to:
  /// **'Parking expires {time}'**
  String parkingExpires(String time);

  /// No description provided for @removeAdsButton.
  ///
  /// In en, this message translates to:
  /// **'Remove ads and support a nice developer. Almost free!'**
  String get removeAdsButton;

  /// No description provided for @testReminder.
  ///
  /// In en, this message translates to:
  /// **'Test reminder'**
  String get testReminder;

  /// No description provided for @testReminderDesc.
  ///
  /// In en, this message translates to:
  /// **'See notification, siren and voice'**
  String get testReminderDesc;

  /// No description provided for @manageCars.
  ///
  /// In en, this message translates to:
  /// **'Manage cars'**
  String get manageCars;

  /// No description provided for @manageCarsDesc.
  ///
  /// In en, this message translates to:
  /// **'Add, remove or change cars'**
  String get manageCarsDesc;

  /// No description provided for @findCar.
  ///
  /// In en, this message translates to:
  /// **'Find my car'**
  String get findCar;

  /// No description provided for @findCarRoute.
  ///
  /// In en, this message translates to:
  /// **'Route to last parked {time}'**
  String findCarRoute(String time);

  /// No description provided for @findCarNone.
  ///
  /// In en, this message translates to:
  /// **'No parking location saved yet'**
  String get findCarNone;

  /// No description provided for @ignoredLocationsAction.
  ///
  /// In en, this message translates to:
  /// **'Ignored locations'**
  String get ignoredLocationsAction;

  /// No description provided for @ignoredLocationsActionDesc.
  ///
  /// In en, this message translates to:
  /// **'Places that don\'t trigger an alarm'**
  String get ignoredLocationsActionDesc;

  /// No description provided for @setReminderTitle.
  ///
  /// In en, this message translates to:
  /// **'Reminder'**
  String get setReminderTitle;

  /// No description provided for @setReminderDesc.
  ///
  /// In en, this message translates to:
  /// **'Set a time to walk back to the car'**
  String get setReminderDesc;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get retry;

  /// No description provided for @setupTitle.
  ///
  /// In en, this message translates to:
  /// **'Setup'**
  String get setupTitle;

  /// No description provided for @setupDesc.
  ///
  /// In en, this message translates to:
  /// **'Customize the app'**
  String get setupDesc;

  /// No description provided for @soundTitle.
  ///
  /// In en, this message translates to:
  /// **'Sound'**
  String get soundTitle;

  /// No description provided for @soundDesc.
  ///
  /// In en, this message translates to:
  /// **'Alarm volume'**
  String get soundDesc;

  /// No description provided for @soundUsePhone.
  ///
  /// In en, this message translates to:
  /// **'Use the phone\'s volume'**
  String get soundUsePhone;

  /// No description provided for @soundUseApp.
  ///
  /// In en, this message translates to:
  /// **'Use the app\'s volume'**
  String get soundUseApp;

  /// No description provided for @soundVolume.
  ///
  /// In en, this message translates to:
  /// **'App volume'**
  String get soundVolume;

  /// No description provided for @soundAlarmSound.
  ///
  /// In en, this message translates to:
  /// **'Alarm sound'**
  String get soundAlarmSound;

  /// No description provided for @soundVibrateDnd.
  ///
  /// In en, this message translates to:
  /// **'Only vibrate in Do Not Disturb'**
  String get soundVibrateDnd;

  /// No description provided for @soundVibrateSilent.
  ///
  /// In en, this message translates to:
  /// **'Only vibrate when volume is 0'**
  String get soundVibrateSilent;

  /// No description provided for @parkingAppsTitle.
  ///
  /// In en, this message translates to:
  /// **'Parking apps'**
  String get parkingAppsTitle;

  /// No description provided for @parkingAppsDesc.
  ///
  /// In en, this message translates to:
  /// **'Choose the apps you use for parking'**
  String get parkingAppsDesc;

  /// No description provided for @parkingAppsBody.
  ///
  /// In en, this message translates to:
  /// **'Select the apps you use to pay for parking, e.g. EasyPark or Q-Park.'**
  String get parkingAppsBody;

  /// No description provided for @parkingAppsSearch.
  ///
  /// In en, this message translates to:
  /// **'Search apps'**
  String get parkingAppsSearch;

  /// No description provided for @parkingAppsKnown.
  ///
  /// In en, this message translates to:
  /// **'Parking apps'**
  String get parkingAppsKnown;

  /// No description provided for @parkingAppsOther.
  ///
  /// In en, this message translates to:
  /// **'Other apps'**
  String get parkingAppsOther;

  /// No description provided for @parkingAppsNone.
  ///
  /// In en, this message translates to:
  /// **'No apps found.'**
  String get parkingAppsNone;

  /// No description provided for @batteryCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Recommended: exempt from battery optimization'**
  String get batteryCardTitle;

  /// No description provided for @batteryCardBody.
  ///
  /// In en, this message translates to:
  /// **'Optional. Without this, Android (especially Samsung) may stop background motion monitoring, so parking without Bluetooth isn\'t always detected.'**
  String get batteryCardBody;

  /// No description provided for @batteryCardButton.
  ///
  /// In en, this message translates to:
  /// **'Allow unrestricted background'**
  String get batteryCardButton;

  /// No description provided for @exactAlarmCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Recommended: allow alarms & reminders'**
  String get exactAlarmCardTitle;

  /// No description provided for @exactAlarmCardBody.
  ///
  /// In en, this message translates to:
  /// **'Lets the app restart monitoring by itself after you close it from recents (\"Clear all\"). Without it, monitoring stays off until you reopen the app.'**
  String get exactAlarmCardBody;

  /// No description provided for @exactAlarmCardButton.
  ///
  /// In en, this message translates to:
  /// **'Allow alarms & reminders'**
  String get exactAlarmCardButton;

  /// No description provided for @motionFetching.
  ///
  /// In en, this message translates to:
  /// **'Motion: fetching status…'**
  String get motionFetching;

  /// No description provided for @motionUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Motion: status unavailable'**
  String get motionUnavailable;

  /// No description provided for @motionNoPermission.
  ///
  /// In en, this message translates to:
  /// **'Motion: no physical activity permission'**
  String get motionNoPermission;

  /// No description provided for @motionError.
  ///
  /// In en, this message translates to:
  /// **'Motion error: {error}'**
  String motionError(String error);

  /// No description provided for @motionRegistering.
  ///
  /// In en, this message translates to:
  /// **'Motion: registering…'**
  String get motionRegistering;

  /// No description provided for @motionActive.
  ///
  /// In en, this message translates to:
  /// **'Motion active'**
  String get motionActive;

  /// No description provided for @motionDormant.
  ///
  /// In en, this message translates to:
  /// **'Motion dormant'**
  String get motionDormant;

  /// No description provided for @motionWaitingData.
  ///
  /// In en, this message translates to:
  /// **'waiting for data'**
  String get motionWaitingData;

  /// No description provided for @motionVehicleTimer.
  ///
  /// In en, this message translates to:
  /// **'vehicle timer running'**
  String get motionVehicleTimer;

  /// No description provided for @motionWakesOnMovement.
  ///
  /// In en, this message translates to:
  /// **'wakes on movement'**
  String get motionWakesOnMovement;

  /// No description provided for @activityInVehicle.
  ///
  /// In en, this message translates to:
  /// **'In vehicle'**
  String get activityInVehicle;

  /// No description provided for @activityOnBicycle.
  ///
  /// In en, this message translates to:
  /// **'On bicycle'**
  String get activityOnBicycle;

  /// No description provided for @activityOnFoot.
  ///
  /// In en, this message translates to:
  /// **'On foot'**
  String get activityOnFoot;

  /// No description provided for @activityStill.
  ///
  /// In en, this message translates to:
  /// **'Still'**
  String get activityStill;

  /// No description provided for @activityTilting.
  ///
  /// In en, this message translates to:
  /// **'Tilting'**
  String get activityTilting;

  /// No description provided for @activityWalking.
  ///
  /// In en, this message translates to:
  /// **'Walking'**
  String get activityWalking;

  /// No description provided for @activityRunning.
  ///
  /// In en, this message translates to:
  /// **'Running'**
  String get activityRunning;

  /// No description provided for @activityUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get activityUnknown;

  /// No description provided for @ignoredLocationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Ignored locations'**
  String get ignoredLocationsTitle;

  /// No description provided for @ignoredLocationsRadiusInfo.
  ///
  /// In en, this message translates to:
  /// **'Alarms are not shown within {meters} metres of these places.'**
  String ignoredLocationsRadiusInfo(int meters);

  /// No description provided for @addCurrentLocation.
  ///
  /// In en, this message translates to:
  /// **'Add current location'**
  String get addCurrentLocation;

  /// No description provided for @sortBy.
  ///
  /// In en, this message translates to:
  /// **'Sort by'**
  String get sortBy;

  /// No description provided for @sortTime.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get sortTime;

  /// No description provided for @sortName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get sortName;

  /// No description provided for @sortDistance.
  ///
  /// In en, this message translates to:
  /// **'Distance'**
  String get sortDistance;

  /// No description provided for @noIgnoredLocations.
  ///
  /// In en, this message translates to:
  /// **'No ignored locations'**
  String get noIgnoredLocations;

  /// No description provided for @noIgnoredLocationsBody.
  ///
  /// In en, this message translates to:
  /// **'You can add a location from a reminder.'**
  String get noIgnoredLocationsBody;

  /// No description provided for @ignoredLocationDefault.
  ///
  /// In en, this message translates to:
  /// **'Ignored location'**
  String get ignoredLocationDefault;

  /// No description provided for @addedAt.
  ///
  /// In en, this message translates to:
  /// **'Added {time}'**
  String addedAt(String time);

  /// No description provided for @tapToOpenMap.
  ///
  /// In en, this message translates to:
  /// **'Tap to open in map'**
  String get tapToOpenMap;

  /// No description provided for @deleteAll.
  ///
  /// In en, this message translates to:
  /// **'Delete all'**
  String get deleteAll;

  /// No description provided for @backToOverview.
  ///
  /// In en, this message translates to:
  /// **'Back to overview'**
  String get backToOverview;

  /// No description provided for @finishSetup.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get finishSetup;

  /// No description provided for @locationFetchError.
  ///
  /// In en, this message translates to:
  /// **'Could not get location.'**
  String get locationFetchError;

  /// No description provided for @locationAdded.
  ///
  /// In en, this message translates to:
  /// **'Location added.'**
  String get locationAdded;

  /// No description provided for @reminderTitle.
  ///
  /// In en, this message translates to:
  /// **'Remember to pay for parking!'**
  String get reminderTitle;

  /// No description provided for @reminderBody.
  ///
  /// In en, this message translates to:
  /// **'We detected that you left your car. Remember to pay for parking!'**
  String get reminderBody;

  /// No description provided for @coordinates.
  ///
  /// In en, this message translates to:
  /// **'Coordinates'**
  String get coordinates;

  /// No description provided for @registeredLabel.
  ///
  /// In en, this message translates to:
  /// **'Registered'**
  String get registeredLabel;

  /// No description provided for @ignoreThisLocation.
  ///
  /// In en, this message translates to:
  /// **'Always ignore this location'**
  String get ignoreThisLocation;

  /// No description provided for @timerCheckbox.
  ///
  /// In en, this message translates to:
  /// **'Remind me to walk back in time'**
  String get timerCheckbox;

  /// No description provided for @timerHelp.
  ///
  /// In en, this message translates to:
  /// **'Set how long you may park here'**
  String get timerHelp;

  /// No description provided for @pickTime.
  ///
  /// In en, this message translates to:
  /// **'Pick time'**
  String get pickTime;

  /// No description provided for @expiresAt.
  ///
  /// In en, this message translates to:
  /// **'Expires at {time}'**
  String expiresAt(String time);

  /// No description provided for @pickExpiryTime.
  ///
  /// In en, this message translates to:
  /// **'Choose expiry time'**
  String get pickExpiryTime;

  /// No description provided for @timerConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'You\'ll be notified in good time to walk back to the car.'**
  String get timerConfirmBody;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @ignoreHint.
  ///
  /// In en, this message translates to:
  /// **'Tap \"Always ignore\" for places like home or work, where you rarely need to pay for parking. The alarm won\'t show again within {meters} metres of here. Over time you\'ll experience fewer unnecessary alarms.'**
  String ignoreHint(int meters);

  /// No description provided for @durationMinutes.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min'**
  String durationMinutes(int minutes);

  /// No description provided for @durationHours.
  ///
  /// In en, this message translates to:
  /// **'{hours} h'**
  String durationHours(int hours);

  /// No description provided for @durationHoursMinutes.
  ///
  /// In en, this message translates to:
  /// **'{hours} h {minutes} min'**
  String durationHoursMinutes(int hours, int minutes);

  /// No description provided for @notifParkingTitle.
  ///
  /// In en, this message translates to:
  /// **'Remember to pay for parking!'**
  String get notifParkingTitle;

  /// No description provided for @notifParkingBody.
  ///
  /// In en, this message translates to:
  /// **'We detected that you left your car.'**
  String get notifParkingBody;

  /// No description provided for @notifWalkBackTitle.
  ///
  /// In en, this message translates to:
  /// **'Hurry back to the car!'**
  String get notifWalkBackTitle;

  /// No description provided for @notifWalkBackBody.
  ///
  /// In en, this message translates to:
  /// **'You should walk now — walking time approx. {minutes} min and parking expires soon.'**
  String notifWalkBackBody(int minutes);

  /// No description provided for @ttsRemember.
  ///
  /// In en, this message translates to:
  /// **'Remember parking, or turn off the alarm for this place'**
  String get ttsRemember;

  /// No description provided for @monitoringTitle.
  ///
  /// In en, this message translates to:
  /// **'Parkingson'**
  String get monitoringTitle;

  /// No description provided for @monitoringBody.
  ///
  /// In en, this message translates to:
  /// **'Monitoring your car...'**
  String get monitoringBody;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'da',
    'de',
    'en',
    'es',
    'fi',
    'fr',
    'is',
    'nb',
    'sv',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'da':
      return AppLocalizationsDa();
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fi':
      return AppLocalizationsFi();
    case 'fr':
      return AppLocalizationsFr();
    case 'is':
      return AppLocalizationsIs();
    case 'nb':
      return AppLocalizationsNb();
    case 'sv':
      return AppLocalizationsSv();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
