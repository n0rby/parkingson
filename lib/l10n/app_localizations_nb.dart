// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Norwegian Bokmål (`nb`).
class AppLocalizationsNb extends AppLocalizations {
  AppLocalizationsNb([String locale = 'nb']) : super(locale);

  @override
  String get welcomeTagline => 'Unngå parkeringsbøter';

  @override
  String get welcomeBody =>
      'Få en påminnelse når du forlater en av bilene dine, og lagre stedet automatisk så du finner bilen igjen.';

  @override
  String get getStarted => 'Kom i gang';

  @override
  String get carsTitle => 'Velg bilene dine';

  @override
  String get btOnlyMode =>
      'Bruk kun Bluetooth for å redusere antallet falske alarmer';

  @override
  String get carsBody =>
      'Appen fungerer best hvis du velger bilenes Bluetooth-tilkoblinger.';

  @override
  String get carsWithBluetooth => 'Biler med Bluetooth';

  @override
  String get noPairedDevices => 'Ingen sammenkoblede Bluetooth-enheter funnet.';

  @override
  String get activateParkingMonitoring => 'Aktiver parkeringsovervåking';

  @override
  String get save => 'Lagre';

  @override
  String get systemBluetoothSettings => 'System-Bluetooth-innstillinger';

  @override
  String get permissionsTitle => 'Tillatelser';

  @override
  String get permissionsBody =>
      'Appen trenger følgende tillatelser for å overvåke bilen din i bakgrunnen.';

  @override
  String get activateMonitoring => 'Aktiver overvåking';

  @override
  String get grantAllToContinue =>
      'Gi alle tillatelsene ovenfor for å fortsette.';

  @override
  String get openSettings => 'Innstillinger';

  @override
  String get grant => 'Tillat';

  @override
  String get ok => 'OK';

  @override
  String get permBluetooth => 'Bluetooth';

  @override
  String get permBluetoothDesc => 'Oppdag når du forlater bilen';

  @override
  String get permLocation => 'Posisjon';

  @override
  String get permLocationDesc =>
      'Lagre parkeringsstedet og overvåk i bakgrunnen';

  @override
  String get permActivity => 'Fysisk aktivitet';

  @override
  String get permActivityDesc => 'Oppdag kjøring og gange';

  @override
  String get permNotifications => 'Varsler';

  @override
  String get permNotificationsDesc => 'Send parkeringspåminnelser';

  @override
  String get permBattery => 'Ubegrenset bakgrunn';

  @override
  String get permBatteryDesc => 'Så batterisparing ikke stopper overvåkingen';

  @override
  String get grantAllPermissions => 'Gi alle tillatelser';

  @override
  String get monitoringActive => 'Overvåking aktiv';

  @override
  String lastParkedAt(String time) {
    return 'Sist parkert $time';
  }

  @override
  String get lastParkedNever => 'Sist parkert ikke målt ennå';

  @override
  String parkingExpires(String time) {
    return 'Parkering utløper $time';
  }

  @override
  String get removeAdsButton =>
      'Fjern annonser og støtt en hyggelig utvikler. Nesten gratis!';

  @override
  String get testReminder => 'Testpåminnelse';

  @override
  String get testReminderDesc => 'Se varsel, sirene og stemme';

  @override
  String get manageCars => 'Administrer biler';

  @override
  String get manageCarsDesc => 'Legg til, fjern eller endre biler';

  @override
  String get findCar => 'Finn bilen min';

  @override
  String findCarRoute(String time) {
    return 'Rute til sist parkert $time';
  }

  @override
  String get findCarNone => 'Ingen parkeringsplass lagret ennå';

  @override
  String get ignoredLocationsAction => 'Ignorerte steder';

  @override
  String get ignoredLocationsActionDesc => 'Steder som ikke utløser alarm';

  @override
  String get setReminderTitle => 'Påminnelse';

  @override
  String get setReminderDesc => 'Angi tid for å gå tilbake til bilen';

  @override
  String get retry => 'Prøv igjen';

  @override
  String get setupTitle => 'Oppsett';

  @override
  String get setupDesc => 'Tilpass appen';

  @override
  String get soundTitle => 'Lyd';

  @override
  String get soundDesc => 'Alarmvolum';

  @override
  String get soundUsePhone => 'Bruk telefonens volum';

  @override
  String get soundUseApp => 'Bruk appens volum';

  @override
  String get soundVolume => 'Appens volum';

  @override
  String get soundAlarmSound => 'Alarmlyd';

  @override
  String get soundVibrateDnd => 'Bare vibrer ved \"Ikke forstyrr\"';

  @override
  String get soundVibrateSilent => 'Bare vibrer ved volum 0';

  @override
  String get batteryCardTitle => 'Anbefalt: unnta fra batterioptimalisering';

  @override
  String get batteryCardBody =>
      'Valgfritt. Uten dette kan Android (spesielt Samsung) stoppe bevegelsesovervåkingen i bakgrunnen, slik at parkering uten Bluetooth ikke alltid oppdages.';

  @override
  String get batteryCardButton => 'Tillat ubegrenset bakgrunn';

  @override
  String get motionFetching => 'Bevegelse: henter status…';

  @override
  String get motionUnavailable => 'Bevegelse: status utilgjengelig';

  @override
  String get motionNoPermission =>
      'Bevegelse: ingen tillatelse til fysisk aktivitet';

  @override
  String motionError(String error) {
    return 'Bevegelsesfeil: $error';
  }

  @override
  String get motionRegistering => 'Bevegelse: registrerer…';

  @override
  String get motionActive => 'Bevegelse aktiv';

  @override
  String get motionDormant => 'Bevegelse i dvale';

  @override
  String get motionWaitingData => 'venter på data';

  @override
  String get motionVehicleTimer => 'kjøretøytimer går';

  @override
  String get motionWakesOnMovement => 'våkner ved bevegelse';

  @override
  String get activityInVehicle => 'I kjøretøy';

  @override
  String get activityOnBicycle => 'På sykkel';

  @override
  String get activityOnFoot => 'Til fots';

  @override
  String get activityStill => 'Stille';

  @override
  String get activityTilting => 'Vipper';

  @override
  String get activityWalking => 'Går';

  @override
  String get activityRunning => 'Løper';

  @override
  String get activityUnknown => 'Ukjent';

  @override
  String get ignoredLocationsTitle => 'Ignorerte steder';

  @override
  String ignoredLocationsRadiusInfo(int meters) {
    return 'Alarmer vises ikke innenfor $meters meter fra disse stedene.';
  }

  @override
  String get addCurrentLocation => 'Legg til nåværende sted';

  @override
  String get sortBy => 'Sorter etter';

  @override
  String get sortTime => 'Tidspunkt';

  @override
  String get sortName => 'Navn';

  @override
  String get sortDistance => 'Avstand';

  @override
  String get noIgnoredLocations => 'Ingen ignorerte steder';

  @override
  String get noIgnoredLocationsBody =>
      'Du kan legge til et sted fra en påminnelse.';

  @override
  String get ignoredLocationDefault => 'Ignorert sted';

  @override
  String addedAt(String time) {
    return 'Lagt til $time';
  }

  @override
  String get tapToOpenMap => 'Trykk for å åpne i kart';

  @override
  String get deleteAll => 'Slett alle';

  @override
  String get backToOverview => 'Tilbake til oversikt';

  @override
  String get locationFetchError => 'Kunne ikke hente posisjon.';

  @override
  String get locationAdded => 'Sted lagt til.';

  @override
  String get reminderTitle => 'Husk å betale for parkering!';

  @override
  String get reminderBody =>
      'Vi oppdaget at du forlot bilen. Husk å betale for parkering!';

  @override
  String get coordinates => 'Koordinater';

  @override
  String get registeredLabel => 'Registrert';

  @override
  String get ignoreThisLocation => 'Ignorer alltid dette stedet';

  @override
  String get timerCheckbox => 'Minn meg på å gå tilbake i tide';

  @override
  String get timerHelp => 'Angi hvor lenge du kan parkere her';

  @override
  String get pickTime => 'Velg tid';

  @override
  String expiresAt(String time) {
    return 'Utløper kl. $time';
  }

  @override
  String get pickExpiryTime => 'Velg utløpstidspunkt';

  @override
  String get timerConfirmBody =>
      'Du får beskjed i god tid til å gå tilbake til bilen.';

  @override
  String get close => 'Lukk';

  @override
  String ignoreHint(int meters) {
    return 'Trykk \"Ignorer alltid\" for steder som hjemme eller jobb, der du sjelden må betale for parkering. Alarmen vises ikke igjen innenfor $meters meter herfra. Med tiden vil du oppleve færre unødvendige alarmer.';
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
  String get notifParkingTitle => 'Husk å betale for parkering!';

  @override
  String get notifParkingBody => 'Vi oppdaget at du forlot bilen.';

  @override
  String get notifWalkBackTitle => 'Skynd deg tilbake til bilen!';

  @override
  String notifWalkBackBody(int minutes) {
    return 'Du bør gå nå — gangtid ca. $minutes min og parkeringen utløper snart.';
  }

  @override
  String get ttsRemember =>
      'Husk parkering, eller slå av alarmen for dette stedet';

  @override
  String get monitoringTitle => 'Parkingson';

  @override
  String get monitoringBody => 'Overvåker bilen din...';
}
