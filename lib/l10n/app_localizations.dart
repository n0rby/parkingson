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
  /// In da, this message translates to:
  /// **'Undgå parkeringsbøder'**
  String get welcomeTagline;

  /// No description provided for @welcomeBody.
  ///
  /// In da, this message translates to:
  /// **'Få en påmindelse, når du forlader en af dine biler, og gem automatisk stedet, så du kan finde bilen igen.'**
  String get welcomeBody;

  /// No description provided for @getStarted.
  ///
  /// In da, this message translates to:
  /// **'Kom i gang'**
  String get getStarted;

  /// No description provided for @carsTitle.
  ///
  /// In da, this message translates to:
  /// **'Vælg dine biler'**
  String get carsTitle;

  /// No description provided for @btOnlyMode.
  ///
  /// In da, this message translates to:
  /// **'Brug kun BT, for at reducere antallet af falske alarmer'**
  String get btOnlyMode;

  /// No description provided for @carsBody.
  ///
  /// In da, this message translates to:
  /// **'Vælg din bils Bluetooth — den forbindelse telefonen laver til bilens stereo, når du sætter dig ind. Vælg ikke hovedtelefoner eller headset. Vi har forhåndsvalgt dem der ligner biler.'**
  String get carsBody;

  /// No description provided for @carsWithBluetooth.
  ///
  /// In da, this message translates to:
  /// **'Biler med Bluetooth'**
  String get carsWithBluetooth;

  /// No description provided for @noPairedDevices.
  ///
  /// In da, this message translates to:
  /// **'Ingen parrede Bluetooth-enheder fundet.'**
  String get noPairedDevices;

  /// No description provided for @activateParkingMonitoring.
  ///
  /// In da, this message translates to:
  /// **'Aktiver parkeringsovervågning'**
  String get activateParkingMonitoring;

  /// No description provided for @save.
  ///
  /// In da, this message translates to:
  /// **'Gem'**
  String get save;

  /// No description provided for @systemBluetoothSettings.
  ///
  /// In da, this message translates to:
  /// **'System Bluetooth-indstillinger'**
  String get systemBluetoothSettings;

  /// No description provided for @permissionsTitle.
  ///
  /// In da, this message translates to:
  /// **'Tilladelser'**
  String get permissionsTitle;

  /// No description provided for @permissionsBody.
  ///
  /// In da, this message translates to:
  /// **'Appen har brug for følgende tilladelser for at overvåge din bil i baggrunden.'**
  String get permissionsBody;

  /// No description provided for @activateMonitoring.
  ///
  /// In da, this message translates to:
  /// **'Aktiver overvågning'**
  String get activateMonitoring;

  /// No description provided for @grantAllToContinue.
  ///
  /// In da, this message translates to:
  /// **'Giv alle tilladelser ovenfor for at fortsætte.'**
  String get grantAllToContinue;

  /// No description provided for @openSettings.
  ///
  /// In da, this message translates to:
  /// **'Indstillinger'**
  String get openSettings;

  /// No description provided for @grant.
  ///
  /// In da, this message translates to:
  /// **'Giv'**
  String get grant;

  /// No description provided for @ok.
  ///
  /// In da, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @permBluetooth.
  ///
  /// In da, this message translates to:
  /// **'Bluetooth'**
  String get permBluetooth;

  /// No description provided for @permBluetoothDesc.
  ///
  /// In da, this message translates to:
  /// **'Registrér hvornår du forlader din bil'**
  String get permBluetoothDesc;

  /// No description provided for @permLocation.
  ///
  /// In da, this message translates to:
  /// **'Placering'**
  String get permLocation;

  /// No description provided for @permLocationDesc.
  ///
  /// In da, this message translates to:
  /// **'Gem parkeringsstedet — vælg \"Tillad hele tiden\" så det virker i baggrunden'**
  String get permLocationDesc;

  /// No description provided for @permActivity.
  ///
  /// In da, this message translates to:
  /// **'Fysisk aktivitet'**
  String get permActivity;

  /// No description provided for @permActivityDesc.
  ///
  /// In da, this message translates to:
  /// **'Detektér kørsel og gang'**
  String get permActivityDesc;

  /// No description provided for @permNotifications.
  ///
  /// In da, this message translates to:
  /// **'Notifikationer'**
  String get permNotifications;

  /// No description provided for @permNotificationsDesc.
  ///
  /// In da, this message translates to:
  /// **'Send påmindelser om parkering'**
  String get permNotificationsDesc;

  /// No description provided for @permBattery.
  ///
  /// In da, this message translates to:
  /// **'Ubegrænset baggrund'**
  String get permBattery;

  /// No description provided for @permBatteryDesc.
  ///
  /// In da, this message translates to:
  /// **'Så batterisparing ikke stopper overvågningen'**
  String get permBatteryDesc;

  /// No description provided for @grantAllPermissions.
  ///
  /// In da, this message translates to:
  /// **'Giv alle tilladelser'**
  String get grantAllPermissions;

  /// No description provided for @setupDoneTitle.
  ///
  /// In da, this message translates to:
  /// **'Parkingson kører'**
  String get setupDoneTitle;

  /// No description provided for @setupDoneBody.
  ///
  /// In da, this message translates to:
  /// **'Parkingson afventer nu din næste parkering. Du får en påmindelse, når du forlader bilen.'**
  String get setupDoneBody;

  /// No description provided for @monitoringActive.
  ///
  /// In da, this message translates to:
  /// **'Overvågning aktiv'**
  String get monitoringActive;

  /// No description provided for @lastParkedAt.
  ///
  /// In da, this message translates to:
  /// **'Sidst parkeret {time}'**
  String lastParkedAt(String time);

  /// No description provided for @lastParkedNever.
  ///
  /// In da, this message translates to:
  /// **'Sidst parkeret ikke målt endnu'**
  String get lastParkedNever;

  /// No description provided for @parkingExpires.
  ///
  /// In da, this message translates to:
  /// **'Parkering udløber {time}'**
  String parkingExpires(String time);

  /// No description provided for @removeAdsButton.
  ///
  /// In da, this message translates to:
  /// **'Slip for reklamer og støt en rar programmør. Næsten gratis!'**
  String get removeAdsButton;

  /// No description provided for @testReminder.
  ///
  /// In da, this message translates to:
  /// **'Test påmindelse'**
  String get testReminder;

  /// No description provided for @testReminderDesc.
  ///
  /// In da, this message translates to:
  /// **'Se notifikation, sirene og stemme'**
  String get testReminderDesc;

  /// No description provided for @manageCars.
  ///
  /// In da, this message translates to:
  /// **'Administrer biler'**
  String get manageCars;

  /// No description provided for @manageCarsDesc.
  ///
  /// In da, this message translates to:
  /// **'Tilføj, fjern eller skift biler'**
  String get manageCarsDesc;

  /// No description provided for @findCar.
  ///
  /// In da, this message translates to:
  /// **'Find min bil'**
  String get findCar;

  /// No description provided for @findCarRoute.
  ///
  /// In da, this message translates to:
  /// **'Rute til sidst parkeret {time}'**
  String findCarRoute(String time);

  /// No description provided for @findCarNone.
  ///
  /// In da, this message translates to:
  /// **'Ingen parkeringsplacering gemt endnu'**
  String get findCarNone;

  /// No description provided for @ignoredLocationsAction.
  ///
  /// In da, this message translates to:
  /// **'Ignorerede lokationer'**
  String get ignoredLocationsAction;

  /// No description provided for @ignoredLocationsActionDesc.
  ///
  /// In da, this message translates to:
  /// **'Steder der ikke udløser alarm'**
  String get ignoredLocationsActionDesc;

  /// No description provided for @setReminderTitle.
  ///
  /// In da, this message translates to:
  /// **'Påmindelse'**
  String get setReminderTitle;

  /// No description provided for @setReminderDesc.
  ///
  /// In da, this message translates to:
  /// **'Sæt tid til at gå tilbage til bilen'**
  String get setReminderDesc;

  /// No description provided for @retry.
  ///
  /// In da, this message translates to:
  /// **'Prøv igen'**
  String get retry;

  /// No description provided for @setupTitle.
  ///
  /// In da, this message translates to:
  /// **'Opsætning'**
  String get setupTitle;

  /// No description provided for @setupDesc.
  ///
  /// In da, this message translates to:
  /// **'Tilpas appen'**
  String get setupDesc;

  /// No description provided for @soundTitle.
  ///
  /// In da, this message translates to:
  /// **'Lyd'**
  String get soundTitle;

  /// No description provided for @soundDesc.
  ///
  /// In da, this message translates to:
  /// **'Lydstyrke for alarm'**
  String get soundDesc;

  /// No description provided for @soundUsePhone.
  ///
  /// In da, this message translates to:
  /// **'Brug telefonens lydstyrke'**
  String get soundUsePhone;

  /// No description provided for @soundUseApp.
  ///
  /// In da, this message translates to:
  /// **'Brug appens lydstyrke'**
  String get soundUseApp;

  /// No description provided for @soundVolume.
  ///
  /// In da, this message translates to:
  /// **'Appens lydstyrke'**
  String get soundVolume;

  /// No description provided for @soundAlarmSound.
  ///
  /// In da, this message translates to:
  /// **'Alarmlyd'**
  String get soundAlarmSound;

  /// No description provided for @soundVibrateDnd.
  ///
  /// In da, this message translates to:
  /// **'Brug kun vibration ved \"Forstyr ikke\"'**
  String get soundVibrateDnd;

  /// No description provided for @soundVibrateSilent.
  ///
  /// In da, this message translates to:
  /// **'Brug kun vibration ved lydstyrke 0'**
  String get soundVibrateSilent;

  /// No description provided for @parkingAppsTitle.
  ///
  /// In da, this message translates to:
  /// **'Parkeringsapps'**
  String get parkingAppsTitle;

  /// No description provided for @parkingAppsDesc.
  ///
  /// In da, this message translates to:
  /// **'Vælg de apps du bruger til parkering'**
  String get parkingAppsDesc;

  /// No description provided for @parkingAppsBody.
  ///
  /// In da, this message translates to:
  /// **'Markér de apps du bruger til at betale for parkering, fx EasyPark eller Q-Park.'**
  String get parkingAppsBody;

  /// No description provided for @parkingAppsSearch.
  ///
  /// In da, this message translates to:
  /// **'Søg apps'**
  String get parkingAppsSearch;

  /// No description provided for @parkingAppsKnown.
  ///
  /// In da, this message translates to:
  /// **'Parkeringsapps'**
  String get parkingAppsKnown;

  /// No description provided for @parkingAppsOther.
  ///
  /// In da, this message translates to:
  /// **'Andre apps'**
  String get parkingAppsOther;

  /// No description provided for @parkingAppsNone.
  ///
  /// In da, this message translates to:
  /// **'Ingen apps fundet.'**
  String get parkingAppsNone;

  /// No description provided for @batteryCardTitle.
  ///
  /// In da, this message translates to:
  /// **'Anbefalet: undtag fra batterioptimering'**
  String get batteryCardTitle;

  /// No description provided for @batteryCardBody.
  ///
  /// In da, this message translates to:
  /// **'Valgfrit. Uden dette kan Android (især Samsung) stoppe bevægelsesovervågningen i baggrunden, så parkering uden Bluetooth ikke altid opdages.'**
  String get batteryCardBody;

  /// No description provided for @batteryCardButton.
  ///
  /// In da, this message translates to:
  /// **'Tillad ubegrænset baggrund'**
  String get batteryCardButton;

  /// No description provided for @motionFetching.
  ///
  /// In da, this message translates to:
  /// **'Motion: henter status…'**
  String get motionFetching;

  /// No description provided for @motionUnavailable.
  ///
  /// In da, this message translates to:
  /// **'Motion: status utilgængelig'**
  String get motionUnavailable;

  /// No description provided for @motionNoPermission.
  ///
  /// In da, this message translates to:
  /// **'Motion: ingen tilladelse til fysisk aktivitet'**
  String get motionNoPermission;

  /// No description provided for @motionError.
  ///
  /// In da, this message translates to:
  /// **'Motion-fejl: {error}'**
  String motionError(String error);

  /// No description provided for @motionRegistering.
  ///
  /// In da, this message translates to:
  /// **'Motion: registrerer…'**
  String get motionRegistering;

  /// No description provided for @motionActive.
  ///
  /// In da, this message translates to:
  /// **'Motion aktiv'**
  String get motionActive;

  /// No description provided for @motionDormant.
  ///
  /// In da, this message translates to:
  /// **'Motion i dvale'**
  String get motionDormant;

  /// No description provided for @motionWaitingData.
  ///
  /// In da, this message translates to:
  /// **'afventer data'**
  String get motionWaitingData;

  /// No description provided for @motionVehicleTimer.
  ///
  /// In da, this message translates to:
  /// **'bil-timer kører'**
  String get motionVehicleTimer;

  /// No description provided for @motionWakesOnMovement.
  ///
  /// In da, this message translates to:
  /// **'vågner ved bevægelse'**
  String get motionWakesOnMovement;

  /// No description provided for @activityInVehicle.
  ///
  /// In da, this message translates to:
  /// **'I bil'**
  String get activityInVehicle;

  /// No description provided for @activityOnBicycle.
  ///
  /// In da, this message translates to:
  /// **'På cykel'**
  String get activityOnBicycle;

  /// No description provided for @activityOnFoot.
  ///
  /// In da, this message translates to:
  /// **'Til fods'**
  String get activityOnFoot;

  /// No description provided for @activityStill.
  ///
  /// In da, this message translates to:
  /// **'Stille'**
  String get activityStill;

  /// No description provided for @activityTilting.
  ///
  /// In da, this message translates to:
  /// **'Vipper'**
  String get activityTilting;

  /// No description provided for @activityWalking.
  ///
  /// In da, this message translates to:
  /// **'Går'**
  String get activityWalking;

  /// No description provided for @activityRunning.
  ///
  /// In da, this message translates to:
  /// **'Løber'**
  String get activityRunning;

  /// No description provided for @activityUnknown.
  ///
  /// In da, this message translates to:
  /// **'Ukendt'**
  String get activityUnknown;

  /// No description provided for @ignoredLocationsTitle.
  ///
  /// In da, this message translates to:
  /// **'Ignorerede placeringer'**
  String get ignoredLocationsTitle;

  /// No description provided for @ignoredLocationsRadiusInfo.
  ///
  /// In da, this message translates to:
  /// **'Alarmer vises ikke inden for {meters} meter fra disse steder.'**
  String ignoredLocationsRadiusInfo(int meters);

  /// No description provided for @addCurrentLocation.
  ///
  /// In da, this message translates to:
  /// **'Tilføj nuværende placering'**
  String get addCurrentLocation;

  /// No description provided for @sortBy.
  ///
  /// In da, this message translates to:
  /// **'Sortér efter'**
  String get sortBy;

  /// No description provided for @sortTime.
  ///
  /// In da, this message translates to:
  /// **'Tidspunkt'**
  String get sortTime;

  /// No description provided for @sortName.
  ///
  /// In da, this message translates to:
  /// **'Navn'**
  String get sortName;

  /// No description provided for @sortDistance.
  ///
  /// In da, this message translates to:
  /// **'Afstand'**
  String get sortDistance;

  /// No description provided for @noIgnoredLocations.
  ///
  /// In da, this message translates to:
  /// **'Ingen ignorerede placeringer'**
  String get noIgnoredLocations;

  /// No description provided for @noIgnoredLocationsBody.
  ///
  /// In da, this message translates to:
  /// **'Du kan tilføje en placering fra en påmindelse.'**
  String get noIgnoredLocationsBody;

  /// No description provided for @ignoredLocationDefault.
  ///
  /// In da, this message translates to:
  /// **'Ignoreret placering'**
  String get ignoredLocationDefault;

  /// No description provided for @addedAt.
  ///
  /// In da, this message translates to:
  /// **'Tilføjet {time}'**
  String addedAt(String time);

  /// No description provided for @tapToOpenMap.
  ///
  /// In da, this message translates to:
  /// **'Tryk for at åbne i kort'**
  String get tapToOpenMap;

  /// No description provided for @deleteAll.
  ///
  /// In da, this message translates to:
  /// **'Slet alle'**
  String get deleteAll;

  /// No description provided for @backToOverview.
  ///
  /// In da, this message translates to:
  /// **'Tilbage til oversigt'**
  String get backToOverview;

  /// No description provided for @finishSetup.
  ///
  /// In da, this message translates to:
  /// **'Færdig'**
  String get finishSetup;

  /// No description provided for @locationFetchError.
  ///
  /// In da, this message translates to:
  /// **'Kunne ikke hente placering.'**
  String get locationFetchError;

  /// No description provided for @locationAdded.
  ///
  /// In da, this message translates to:
  /// **'Placering tilføjet.'**
  String get locationAdded;

  /// No description provided for @reminderTitle.
  ///
  /// In da, this message translates to:
  /// **'Husk at betale for parkering!'**
  String get reminderTitle;

  /// No description provided for @reminderBody.
  ///
  /// In da, this message translates to:
  /// **'Vi har registreret at du har forladt din bil. Husk at betale for parkering!'**
  String get reminderBody;

  /// No description provided for @coordinates.
  ///
  /// In da, this message translates to:
  /// **'Koordinater'**
  String get coordinates;

  /// No description provided for @registeredLabel.
  ///
  /// In da, this message translates to:
  /// **'Registreret'**
  String get registeredLabel;

  /// No description provided for @ignoreThisLocation.
  ///
  /// In da, this message translates to:
  /// **'Ignorer altid denne placering'**
  String get ignoreThisLocation;

  /// No description provided for @timerCheckbox.
  ///
  /// In da, this message translates to:
  /// **'Påmind mig om at gå tilbage i tide'**
  String get timerCheckbox;

  /// No description provided for @timerHelp.
  ///
  /// In da, this message translates to:
  /// **'Angiv hvor længe du må parkere her'**
  String get timerHelp;

  /// No description provided for @pickTime.
  ///
  /// In da, this message translates to:
  /// **'Vælg tid'**
  String get pickTime;

  /// No description provided for @expiresAt.
  ///
  /// In da, this message translates to:
  /// **'Udløber kl. {time}'**
  String expiresAt(String time);

  /// No description provided for @pickExpiryTime.
  ///
  /// In da, this message translates to:
  /// **'Vælg udløbstidspunkt'**
  String get pickExpiryTime;

  /// No description provided for @timerConfirmBody.
  ///
  /// In da, this message translates to:
  /// **'Du får besked i god tid til at gå tilbage til bilen.'**
  String get timerConfirmBody;

  /// No description provided for @close.
  ///
  /// In da, this message translates to:
  /// **'Luk'**
  String get close;

  /// No description provided for @ignoreHint.
  ///
  /// In da, this message translates to:
  /// **'Tryk \"Ignorer altid\" for steder som hjemme eller arbejde, hvor du sjældent skal betale for parkering. Alarmen vises ikke igen inden for {meters} meter herfra. Med tiden vil du opleve færre unødvendige alarmer.'**
  String ignoreHint(int meters);

  /// No description provided for @durationMinutes.
  ///
  /// In da, this message translates to:
  /// **'{minutes} min'**
  String durationMinutes(int minutes);

  /// No description provided for @durationHours.
  ///
  /// In da, this message translates to:
  /// **'{hours} t'**
  String durationHours(int hours);

  /// No description provided for @durationHoursMinutes.
  ///
  /// In da, this message translates to:
  /// **'{hours} t {minutes} min'**
  String durationHoursMinutes(int hours, int minutes);

  /// No description provided for @notifParkingTitle.
  ///
  /// In da, this message translates to:
  /// **'Husk at betale for parkering!'**
  String get notifParkingTitle;

  /// No description provided for @notifParkingBody.
  ///
  /// In da, this message translates to:
  /// **'Vi registrerede at du har forladt din bil.'**
  String get notifParkingBody;

  /// No description provided for @notifWalkBackTitle.
  ///
  /// In da, this message translates to:
  /// **'Skynd dig tilbage til bilen!'**
  String get notifWalkBackTitle;

  /// No description provided for @notifWalkBackBody.
  ///
  /// In da, this message translates to:
  /// **'Du skal gå nu — gangtid ca. {minutes} min og parkering udløber snart.'**
  String notifWalkBackBody(int minutes);

  /// No description provided for @ttsRemember.
  ///
  /// In da, this message translates to:
  /// **'Husk parkering eller slå alarm for dette sted fra'**
  String get ttsRemember;

  /// No description provided for @monitoringTitle.
  ///
  /// In da, this message translates to:
  /// **'Parkingson'**
  String get monitoringTitle;

  /// No description provided for @monitoringBody.
  ///
  /// In da, this message translates to:
  /// **'Overvåger din bil...'**
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
