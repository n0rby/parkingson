// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get welcomeTagline => 'Vermeide Parkstrafen';

  @override
  String get welcomeBody =>
      'Erhalte eine Erinnerung, wenn du eines deiner Autos verlässt, und speichere den Ort automatisch, um das Auto wiederzufinden.';

  @override
  String get getStarted => 'Loslegen';

  @override
  String get carsTitle => 'Wähle deine Autos';

  @override
  String get btOnlyMode =>
      'Nur Bluetooth verwenden, um Fehlalarme zu reduzieren';

  @override
  String get carsBody =>
      'Die App funktioniert am besten, wenn du die Bluetooth-Verbindungen deiner Autos auswählst.';

  @override
  String get carsWithBluetooth => 'Autos mit Bluetooth';

  @override
  String get noPairedDevices => 'Keine gekoppelten Bluetooth-Geräte gefunden.';

  @override
  String get activateParkingMonitoring => 'Parküberwachung aktivieren';

  @override
  String get systemBluetoothSettings => 'System-Bluetooth-Einstellungen';

  @override
  String get permissionsTitle => 'Berechtigungen';

  @override
  String get permissionsBody =>
      'Die App benötigt die folgenden Berechtigungen, um dein Auto im Hintergrund zu überwachen.';

  @override
  String get activateMonitoring => 'Überwachung aktivieren';

  @override
  String get grantAllToContinue =>
      'Erteile alle Berechtigungen oben, um fortzufahren.';

  @override
  String get openSettings => 'Einstellungen';

  @override
  String get grant => 'Erlauben';

  @override
  String get ok => 'OK';

  @override
  String get permBluetooth => 'Bluetooth';

  @override
  String get permBluetoothDesc => 'Erkennen, wann du dein Auto verlässt';

  @override
  String get permLocation => 'Standort';

  @override
  String get permLocationDesc =>
      'Parkplatz speichern und im Hintergrund überwachen';

  @override
  String get permActivity => 'Körperliche Aktivität';

  @override
  String get permActivityDesc => 'Fahren und Gehen erkennen';

  @override
  String get permNotifications => 'Benachrichtigungen';

  @override
  String get permNotificationsDesc => 'Parkerinnerungen senden';

  @override
  String get monitoringActive => 'Überwachung aktiv';

  @override
  String lastParkedAt(String time) {
    return 'Zuletzt geparkt $time';
  }

  @override
  String get lastParkedNever => 'Zuletzt geparkt noch nicht erfasst';

  @override
  String parkingExpires(String time) {
    return 'Parkzeit endet $time';
  }

  @override
  String get removeAdsButton =>
      'Werbung entfernen und einen netten Entwickler unterstützen. Fast kostenlos!';

  @override
  String get testReminder => 'Erinnerung testen';

  @override
  String get testReminderDesc => 'Benachrichtigung, Sirene und Stimme ansehen';

  @override
  String get manageCars => 'Autos verwalten';

  @override
  String get manageCarsDesc => 'Autos hinzufügen, entfernen oder ändern';

  @override
  String get findCar => 'Mein Auto finden';

  @override
  String findCarRoute(String time) {
    return 'Route zum zuletzt geparkten $time';
  }

  @override
  String get findCarNone => 'Noch kein Parkplatz gespeichert';

  @override
  String get ignoredLocationsAction => 'Ignorierte Orte';

  @override
  String get ignoredLocationsActionDesc => 'Orte, die keinen Alarm auslösen';

  @override
  String get batteryCardTitle =>
      'Empfohlen: von der Akku-Optimierung ausnehmen';

  @override
  String get batteryCardBody =>
      'Optional. Ohne dies kann Android (besonders Samsung) die Bewegungsüberwachung im Hintergrund stoppen, sodass Parken ohne Bluetooth nicht immer erkannt wird.';

  @override
  String get batteryCardButton => 'Uneingeschränkten Hintergrund erlauben';

  @override
  String get motionFetching => 'Bewegung: Status wird geladen…';

  @override
  String get motionUnavailable => 'Bewegung: Status nicht verfügbar';

  @override
  String get motionNoPermission =>
      'Bewegung: keine Berechtigung für körperliche Aktivität';

  @override
  String motionError(String error) {
    return 'Bewegungsfehler: $error';
  }

  @override
  String get motionRegistering => 'Bewegung: wird registriert…';

  @override
  String get motionActive => 'Bewegung aktiv';

  @override
  String get motionDormant => 'Bewegung im Ruhezustand';

  @override
  String get motionWaitingData => 'warte auf Daten';

  @override
  String get motionVehicleTimer => 'Fahrzeug-Timer läuft';

  @override
  String get motionWakesOnMovement => 'erwacht bei Bewegung';

  @override
  String get activityInVehicle => 'Im Fahrzeug';

  @override
  String get activityOnBicycle => 'Auf dem Fahrrad';

  @override
  String get activityOnFoot => 'Zu Fuß';

  @override
  String get activityStill => 'Ruhig';

  @override
  String get activityTilting => 'Neigen';

  @override
  String get activityWalking => 'Gehen';

  @override
  String get activityRunning => 'Laufen';

  @override
  String get activityUnknown => 'Unbekannt';

  @override
  String get ignoredLocationsTitle => 'Ignorierte Orte';

  @override
  String ignoredLocationsRadiusInfo(int meters) {
    return 'Alarme werden innerhalb von $meters Metern dieser Orte nicht angezeigt.';
  }

  @override
  String get addCurrentLocation => 'Aktuellen Standort hinzufügen';

  @override
  String get sortBy => 'Sortieren nach';

  @override
  String get sortTime => 'Zeit';

  @override
  String get sortName => 'Name';

  @override
  String get sortDistance => 'Entfernung';

  @override
  String get noIgnoredLocations => 'Keine ignorierten Orte';

  @override
  String get noIgnoredLocationsBody =>
      'Du kannst einen Ort aus einer Erinnerung hinzufügen.';

  @override
  String get ignoredLocationDefault => 'Ignorierter Ort';

  @override
  String addedAt(String time) {
    return 'Hinzugefügt $time';
  }

  @override
  String get tapToOpenMap => 'Tippen, um in der Karte zu öffnen';

  @override
  String get deleteAll => 'Alle löschen';

  @override
  String get backToOverview => 'Zurück zur Übersicht';

  @override
  String get locationFetchError => 'Standort konnte nicht abgerufen werden.';

  @override
  String get locationAdded => 'Ort hinzugefügt.';

  @override
  String get reminderTitle => 'Denk daran, fürs Parken zu bezahlen!';

  @override
  String get reminderBody =>
      'Wir haben erkannt, dass du dein Auto verlassen hast. Denk daran, fürs Parken zu bezahlen!';

  @override
  String get coordinates => 'Koordinaten';

  @override
  String get registeredLabel => 'Erfasst';

  @override
  String get ignoreThisLocation => 'Diesen Ort immer ignorieren';

  @override
  String get timerCheckbox => 'Erinnere mich, rechtzeitig zurückzugehen';

  @override
  String get timerHelp => 'Lege fest, wie lange du hier parken darfst';

  @override
  String get pickTime => 'Zeit wählen';

  @override
  String expiresAt(String time) {
    return 'Läuft ab um $time';
  }

  @override
  String get pickExpiryTime => 'Ablaufzeit wählen';

  @override
  String get timerConfirmBody =>
      'Du wirst rechtzeitig benachrichtigt, um zum Auto zurückzugehen.';

  @override
  String get close => 'Schließen';

  @override
  String ignoreHint(int meters) {
    return 'Tippe auf \"Immer ignorieren\" für Orte wie Zuhause oder Arbeit, wo du selten fürs Parken bezahlen musst. Der Alarm wird innerhalb von $meters Metern von hier nicht erneut angezeigt. Mit der Zeit wirst du weniger unnötige Alarme erleben.';
  }

  @override
  String durationMinutes(int minutes) {
    return '$minutes Min';
  }

  @override
  String durationHours(int hours) {
    return '$hours Std';
  }

  @override
  String durationHoursMinutes(int hours, int minutes) {
    return '$hours Std $minutes Min';
  }

  @override
  String get notifParkingTitle => 'Denk daran, fürs Parken zu bezahlen!';

  @override
  String get notifParkingBody =>
      'Wir haben erkannt, dass du dein Auto verlassen hast.';

  @override
  String get notifWalkBackTitle => 'Beeil dich zurück zum Auto!';

  @override
  String notifWalkBackBody(int minutes) {
    return 'Du solltest jetzt losgehen — Gehzeit ca. $minutes Min und das Parken läuft bald ab.';
  }

  @override
  String get ttsRemember => 'Denk ans Parken';

  @override
  String get monitoringTitle => 'Parkingson';

  @override
  String get monitoringBody => 'Überwacht dein Auto...';
}
