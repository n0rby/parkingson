// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Danish (`da`).
class AppLocalizationsDa extends AppLocalizations {
  AppLocalizationsDa([String locale = 'da']) : super(locale);

  @override
  String get welcomeTagline => 'Undgå parkeringsbøder';

  @override
  String get welcomeBody =>
      'Få en påmindelse, når du forlader en af dine biler, og gem automatisk stedet, så du kan finde bilen igen.';

  @override
  String get getStarted => 'Kom i gang';

  @override
  String get carsTitle => 'Vælg dine biler';

  @override
  String get btOnlyMode =>
      'Brug kun BT, for at reducere antallet af falske alarmer';

  @override
  String get carsBody =>
      'Appen virker bedst, hvis du vælger dine bilers Bluetooth-forbindelser.';

  @override
  String get carsWithBluetooth => 'Biler med Bluetooth';

  @override
  String get noPairedDevices => 'Ingen parrede Bluetooth-enheder fundet.';

  @override
  String get activateParkingMonitoring => 'Aktiver parkeringsovervågning';

  @override
  String get save => 'Gem';

  @override
  String get systemBluetoothSettings => 'System Bluetooth-indstillinger';

  @override
  String get permissionsTitle => 'Tilladelser';

  @override
  String get permissionsBody =>
      'Appen har brug for følgende tilladelser for at overvåge din bil i baggrunden.';

  @override
  String get activateMonitoring => 'Aktiver overvågning';

  @override
  String get grantAllToContinue =>
      'Giv alle tilladelser ovenfor for at fortsætte.';

  @override
  String get openSettings => 'Indstillinger';

  @override
  String get grant => 'Giv';

  @override
  String get ok => 'OK';

  @override
  String get permBluetooth => 'Bluetooth';

  @override
  String get permBluetoothDesc => 'Registrér hvornår du forlader din bil';

  @override
  String get permLocation => 'Placering';

  @override
  String get permLocationDesc => 'Gem parkeringsstedet og overvåg i baggrunden';

  @override
  String get permActivity => 'Fysisk aktivitet';

  @override
  String get permActivityDesc => 'Detektér kørsel og gang';

  @override
  String get permNotifications => 'Notifikationer';

  @override
  String get permNotificationsDesc => 'Send påmindelser om parkering';

  @override
  String get permBattery => 'Ubegrænset baggrund';

  @override
  String get permBatteryDesc => 'Så batterisparing ikke stopper overvågningen';

  @override
  String get grantAllPermissions => 'Giv alle tilladelser';

  @override
  String get monitoringActive => 'Overvågning aktiv';

  @override
  String lastParkedAt(String time) {
    return 'Sidst parkeret $time';
  }

  @override
  String get lastParkedNever => 'Sidst parkeret ikke målt endnu';

  @override
  String parkingExpires(String time) {
    return 'Parkering udløber $time';
  }

  @override
  String get removeAdsButton =>
      'Slip for reklamer og støt en rar programmør. Næsten gratis!';

  @override
  String get testReminder => 'Test påmindelse';

  @override
  String get testReminderDesc => 'Se notifikation, sirene og stemme';

  @override
  String get manageCars => 'Administrer biler';

  @override
  String get manageCarsDesc => 'Tilføj, fjern eller skift biler';

  @override
  String get findCar => 'Find min bil';

  @override
  String findCarRoute(String time) {
    return 'Rute til sidst parkeret $time';
  }

  @override
  String get findCarNone => 'Ingen parkeringsplacering gemt endnu';

  @override
  String get ignoredLocationsAction => 'Ignorerede lokationer';

  @override
  String get ignoredLocationsActionDesc => 'Steder der ikke udløser alarm';

  @override
  String get setReminderTitle => 'Påmindelse';

  @override
  String get setReminderDesc => 'Sæt tid til at gå tilbage til bilen';

  @override
  String get retry => 'Prøv igen';

  @override
  String get setupTitle => 'Opsætning';

  @override
  String get setupDesc => 'Tilpas appen';

  @override
  String get soundTitle => 'Lyd';

  @override
  String get soundDesc => 'Lydstyrke for alarm';

  @override
  String get soundUsePhone => 'Brug telefonens lydstyrke';

  @override
  String get soundUseApp => 'Brug appens lydstyrke';

  @override
  String get soundVolume => 'Appens lydstyrke';

  @override
  String get soundAlarmSound => 'Alarmlyd';

  @override
  String get soundVibrateDnd => 'Brug kun vibration ved \"Forstyr ikke\"';

  @override
  String get soundVibrateSilent => 'Brug kun vibration ved lydstyrke 0';

  @override
  String get batteryCardTitle => 'Anbefalet: undtag fra batterioptimering';

  @override
  String get batteryCardBody =>
      'Valgfrit. Uden dette kan Android (især Samsung) stoppe bevægelsesovervågningen i baggrunden, så parkering uden Bluetooth ikke altid opdages.';

  @override
  String get batteryCardButton => 'Tillad ubegrænset baggrund';

  @override
  String get motionFetching => 'Motion: henter status…';

  @override
  String get motionUnavailable => 'Motion: status utilgængelig';

  @override
  String get motionNoPermission =>
      'Motion: ingen tilladelse til fysisk aktivitet';

  @override
  String motionError(String error) {
    return 'Motion-fejl: $error';
  }

  @override
  String get motionRegistering => 'Motion: registrerer…';

  @override
  String get motionActive => 'Motion aktiv';

  @override
  String get motionDormant => 'Motion i dvale';

  @override
  String get motionWaitingData => 'afventer data';

  @override
  String get motionVehicleTimer => 'bil-timer kører';

  @override
  String get motionWakesOnMovement => 'vågner ved bevægelse';

  @override
  String get activityInVehicle => 'I bil';

  @override
  String get activityOnBicycle => 'På cykel';

  @override
  String get activityOnFoot => 'Til fods';

  @override
  String get activityStill => 'Stille';

  @override
  String get activityTilting => 'Vipper';

  @override
  String get activityWalking => 'Går';

  @override
  String get activityRunning => 'Løber';

  @override
  String get activityUnknown => 'Ukendt';

  @override
  String get ignoredLocationsTitle => 'Ignorerede placeringer';

  @override
  String ignoredLocationsRadiusInfo(int meters) {
    return 'Alarmer vises ikke inden for $meters meter fra disse steder.';
  }

  @override
  String get addCurrentLocation => 'Tilføj nuværende placering';

  @override
  String get sortBy => 'Sortér efter';

  @override
  String get sortTime => 'Tidspunkt';

  @override
  String get sortName => 'Navn';

  @override
  String get sortDistance => 'Afstand';

  @override
  String get noIgnoredLocations => 'Ingen ignorerede placeringer';

  @override
  String get noIgnoredLocationsBody =>
      'Du kan tilføje en placering fra en påmindelse.';

  @override
  String get ignoredLocationDefault => 'Ignoreret placering';

  @override
  String addedAt(String time) {
    return 'Tilføjet $time';
  }

  @override
  String get tapToOpenMap => 'Tryk for at åbne i kort';

  @override
  String get deleteAll => 'Slet alle';

  @override
  String get backToOverview => 'Tilbage til oversigt';

  @override
  String get locationFetchError => 'Kunne ikke hente placering.';

  @override
  String get locationAdded => 'Placering tilføjet.';

  @override
  String get reminderTitle => 'Husk at betale for parkering!';

  @override
  String get reminderBody =>
      'Vi har registreret at du har forladt din bil. Husk at betale for parkering!';

  @override
  String get coordinates => 'Koordinater';

  @override
  String get registeredLabel => 'Registreret';

  @override
  String get ignoreThisLocation => 'Ignorer altid denne placering';

  @override
  String get timerCheckbox => 'Påmind mig om at gå tilbage i tide';

  @override
  String get timerHelp => 'Angiv hvor længe du må parkere her';

  @override
  String get pickTime => 'Vælg tid';

  @override
  String expiresAt(String time) {
    return 'Udløber kl. $time';
  }

  @override
  String get pickExpiryTime => 'Vælg udløbstidspunkt';

  @override
  String get timerConfirmBody =>
      'Du får besked i god tid til at gå tilbage til bilen.';

  @override
  String get close => 'Luk';

  @override
  String ignoreHint(int meters) {
    return 'Tryk \"Ignorer altid\" for steder som hjemme eller arbejde, hvor du sjældent skal betale for parkering. Alarmen vises ikke igen inden for $meters meter herfra. Med tiden vil du opleve færre unødvendige alarmer.';
  }

  @override
  String durationMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String durationHours(int hours) {
    return '$hours t';
  }

  @override
  String durationHoursMinutes(int hours, int minutes) {
    return '$hours t $minutes min';
  }

  @override
  String get notifParkingTitle => 'Husk at betale for parkering!';

  @override
  String get notifParkingBody => 'Vi registrerede at du har forladt din bil.';

  @override
  String get notifWalkBackTitle => 'Skynd dig tilbage til bilen!';

  @override
  String notifWalkBackBody(int minutes) {
    return 'Du skal gå nu — gangtid ca. $minutes min og parkering udløber snart.';
  }

  @override
  String get ttsRemember => 'Husk parkering eller slå alarm for dette sted fra';

  @override
  String get monitoringTitle => 'Parkingson';

  @override
  String get monitoringBody => 'Overvåger din bil...';
}
