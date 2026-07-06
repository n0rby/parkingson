// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Swedish (`sv`).
class AppLocalizationsSv extends AppLocalizations {
  AppLocalizationsSv([String locale = 'sv']) : super(locale);

  @override
  String get welcomeTagline => 'Undvik parkeringsböter';

  @override
  String get welcomeBody =>
      'Få en påminnelse när du lämnar en av dina bilar, och spara platsen automatiskt så att du kan hitta bilen igen.';

  @override
  String get getStarted => 'Kom igång';

  @override
  String get carsTitle => 'Välj dina bilar';

  @override
  String get btOnlyMode =>
      'Använd endast Bluetooth för att minska antalet falsklarm';

  @override
  String get carsBody =>
      'Välj din bils Bluetooth — anslutningen som telefonen gör till bilstereon när du sätter dig i bilen. Välj inte hörlurar eller headset. Vi har förvalt de som ser ut som bilar.';

  @override
  String get carsWithBluetooth => 'Bilar med Bluetooth';

  @override
  String get noPairedDevices => 'Inga parkopplade Bluetooth-enheter hittades.';

  @override
  String get activateParkingMonitoring => 'Aktivera parkeringsövervakning';

  @override
  String get save => 'Spara';

  @override
  String get systemBluetoothSettings => 'System-Bluetooth-inställningar';

  @override
  String get permissionsTitle => 'Behörigheter';

  @override
  String get permissionsBody =>
      'Appen behöver följande behörigheter för att övervaka din bil i bakgrunden.';

  @override
  String get activateMonitoring => 'Aktivera övervakning';

  @override
  String get grantAllToContinue =>
      'Ge alla behörigheter ovan för att fortsätta.';

  @override
  String get openSettings => 'Inställningar';

  @override
  String get grant => 'Tillåt';

  @override
  String get ok => 'OK';

  @override
  String get permBluetooth => 'Bluetooth';

  @override
  String get permBluetoothDesc => 'Upptäck när du lämnar din bil';

  @override
  String get permLocation => 'Plats';

  @override
  String get permLocationDesc =>
      'Spara parkeringsplatsen — välj \"Tillåt alltid\" så det fungerar i bakgrunden';

  @override
  String get permActivity => 'Fysisk aktivitet';

  @override
  String get permActivityDesc => 'Upptäck körning och gång';

  @override
  String get permNotifications => 'Aviseringar';

  @override
  String get permNotificationsDesc => 'Skicka parkeringspåminnelser';

  @override
  String get permBattery => 'Obegränsad bakgrund';

  @override
  String get permBatteryDesc =>
      'Så att batterisparläge inte stoppar övervakningen';

  @override
  String get grantAllPermissions => 'Ge alla behörigheter';

  @override
  String get permMicrophone => 'Mikrofon';

  @override
  String get permMicrophoneDesc => 'För röstkommandon på påminnelsen';

  @override
  String get voiceListening => 'Lyssnar…';

  @override
  String get voicePrompt =>
      'Säg \"ignorera\" eller \"parkeringstid 30 minuter\"';

  @override
  String voiceTimerSet(String time) {
    return 'Parkeringstid satt till $time';
  }

  @override
  String get voiceNotUnderstood => 'Uppfattade inte — försök igen';

  @override
  String get voiceIgnoreConfirm => 'Ignorerar denna plats';

  @override
  String get setupDoneTitle => 'Parkingson körs';

  @override
  String get setupDoneBody =>
      'Parkingson väntar nu på din nästa parkering. Du får en påminnelse när du lämnar bilen.';

  @override
  String get monitoringActive => 'Övervakning aktiv';

  @override
  String lastParkedAt(String time) {
    return 'Senast parkerad $time';
  }

  @override
  String get lastParkedNever => 'Senast parkerad ännu inte uppmätt';

  @override
  String parkingExpires(String time) {
    return 'Parkering går ut $time';
  }

  @override
  String get removeAdsButton =>
      'Ta bort annonser och stöd en trevlig utvecklare. Nästan gratis!';

  @override
  String get testReminder => 'Testpåminnelse';

  @override
  String get testReminderDesc => 'Se avisering, siren och röst';

  @override
  String get manageCars => 'Hantera bilar';

  @override
  String get manageCarsDesc => 'Lägg till, ta bort eller ändra bilar';

  @override
  String get findCar => 'Hitta min bil';

  @override
  String findCarRoute(String time) {
    return 'Rutt till senast parkerad $time';
  }

  @override
  String get findCarNone => 'Ingen parkeringsplats sparad ännu';

  @override
  String get ignoredLocationsAction => 'Ignorerade platser';

  @override
  String get ignoredLocationsActionDesc => 'Platser som inte utlöser larm';

  @override
  String get setReminderTitle => 'Påminnelse';

  @override
  String get setReminderDesc => 'Ange en tid för att gå tillbaka till bilen';

  @override
  String get retry => 'Försök igen';

  @override
  String get setupTitle => 'Inställningar';

  @override
  String get setupDesc => 'Anpassa appen';

  @override
  String get soundTitle => 'Ljud';

  @override
  String get soundDesc => 'Larmvolym';

  @override
  String get soundUsePhone => 'Använd telefonens volym';

  @override
  String get soundUseApp => 'Använd appens volym';

  @override
  String get soundVolume => 'Appens volym';

  @override
  String get soundAlarmSound => 'Larmljud';

  @override
  String get soundVibrateDnd => 'Vibrera endast vid \"Stör ej\"';

  @override
  String get soundVibrateSilent => 'Vibrera endast vid volym 0';

  @override
  String get parkingAppsTitle => 'Parkeringsappar';

  @override
  String get parkingAppsDesc => 'Välj apparna du använder för parkering';

  @override
  String get parkingAppsBody =>
      'Markera apparna du använder för att betala för parkering, t.ex. EasyPark eller Q-Park.';

  @override
  String get parkingAppsSearch => 'Sök appar';

  @override
  String get parkingAppsKnown => 'Parkeringsappar';

  @override
  String get parkingAppsOther => 'Andra appar';

  @override
  String get parkingAppsNone => 'Inga appar hittades.';

  @override
  String get batteryCardTitle =>
      'Rekommenderas: undanta från batterioptimering';

  @override
  String get batteryCardBody =>
      'Valfritt. Utan detta kan Android (särskilt Samsung) stoppa rörelseövervakningen i bakgrunden, så att parkering utan Bluetooth inte alltid upptäcks.';

  @override
  String get batteryCardButton => 'Tillåt obegränsad bakgrund';

  @override
  String get motionFetching => 'Rörelse: hämtar status…';

  @override
  String get motionUnavailable => 'Rörelse: status otillgänglig';

  @override
  String get motionNoPermission =>
      'Rörelse: ingen behörighet för fysisk aktivitet';

  @override
  String motionError(String error) {
    return 'Rörelsefel: $error';
  }

  @override
  String get motionRegistering => 'Rörelse: registrerar…';

  @override
  String get motionActive => 'Rörelse aktiv';

  @override
  String get motionDormant => 'Rörelse i viloläge';

  @override
  String get motionWaitingData => 'väntar på data';

  @override
  String get motionVehicleTimer => 'fordonstimer körs';

  @override
  String get motionWakesOnMovement => 'vaknar vid rörelse';

  @override
  String get activityInVehicle => 'I fordon';

  @override
  String get activityOnBicycle => 'På cykel';

  @override
  String get activityOnFoot => 'Till fots';

  @override
  String get activityStill => 'Stilla';

  @override
  String get activityTilting => 'Lutar';

  @override
  String get activityWalking => 'Går';

  @override
  String get activityRunning => 'Springer';

  @override
  String get activityUnknown => 'Okänd';

  @override
  String get ignoredLocationsTitle => 'Ignorerade platser';

  @override
  String ignoredLocationsRadiusInfo(int meters) {
    return 'Larm visas inte inom $meters meter från dessa platser.';
  }

  @override
  String get addCurrentLocation => 'Lägg till nuvarande plats';

  @override
  String get sortBy => 'Sortera efter';

  @override
  String get sortTime => 'Tidpunkt';

  @override
  String get sortName => 'Namn';

  @override
  String get sortDistance => 'Avstånd';

  @override
  String get noIgnoredLocations => 'Inga ignorerade platser';

  @override
  String get noIgnoredLocationsBody =>
      'Du kan lägga till en plats från en påminnelse.';

  @override
  String get ignoredLocationDefault => 'Ignorerad plats';

  @override
  String addedAt(String time) {
    return 'Tillagd $time';
  }

  @override
  String get tapToOpenMap => 'Tryck för att öppna i karta';

  @override
  String get deleteAll => 'Radera alla';

  @override
  String get backToOverview => 'Tillbaka till översikt';

  @override
  String get finishSetup => 'Klar';

  @override
  String get locationFetchError => 'Kunde inte hämta plats.';

  @override
  String get locationAdded => 'Plats tillagd.';

  @override
  String get reminderTitle => 'Kom ihåg att betala för parkering!';

  @override
  String get reminderBody =>
      'Vi upptäckte att du lämnade din bil. Kom ihåg att betala för parkering!';

  @override
  String get coordinates => 'Koordinater';

  @override
  String get registeredLabel => 'Registrerad';

  @override
  String get ignoreThisLocation => 'Ignorera alltid denna plats';

  @override
  String get timerCheckbox => 'Påminn mig att gå tillbaka i tid';

  @override
  String get timerHelp => 'Ange hur länge du får parkera här';

  @override
  String get pickTime => 'Välj tid';

  @override
  String expiresAt(String time) {
    return 'Går ut kl. $time';
  }

  @override
  String get pickExpiryTime => 'Välj sluttid';

  @override
  String get timerConfirmBody =>
      'Du får ett meddelande i god tid för att gå tillbaka till bilen.';

  @override
  String get close => 'Stäng';

  @override
  String ignoreHint(int meters) {
    return 'Tryck på \"Ignorera alltid\" för platser som hemma eller arbetet, där du sällan behöver betala för parkering. Larmet visas inte igen inom $meters meter härifrån. Med tiden kommer du att uppleva färre onödiga larm.';
  }

  @override
  String durationMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String durationHours(int hours) {
    return '$hours tim';
  }

  @override
  String durationHoursMinutes(int hours, int minutes) {
    return '$hours tim $minutes min';
  }

  @override
  String get notifParkingTitle => 'Kom ihåg att betala för parkering!';

  @override
  String get notifParkingBody => 'Vi upptäckte att du lämnade din bil.';

  @override
  String get notifWalkBackTitle => 'Skynda tillbaka till bilen!';

  @override
  String notifWalkBackBody(int minutes) {
    return 'Du bör gå nu — gångtid ca $minutes min och parkeringen går snart ut.';
  }

  @override
  String get ttsRemember =>
      'Kom ihåg parkering, eller stäng av larmet för denna plats';

  @override
  String get monitoringTitle => 'Parkingson';

  @override
  String get monitoringBody => 'Övervakar din bil...';
}
