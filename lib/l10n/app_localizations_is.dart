// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Icelandic (`is`).
class AppLocalizationsIs extends AppLocalizations {
  AppLocalizationsIs([String locale = 'is']) : super(locale);

  @override
  String get welcomeTagline => 'Forðastu stöðumælasektir';

  @override
  String get welcomeBody =>
      'Fáðu áminningu þegar þú yfirgefur einn af bílunum þínum og staðsetningin er vistuð sjálfkrafa svo þú finnir bílinn aftur.';

  @override
  String get getStarted => 'Byrja';

  @override
  String get carsTitle => 'Veldu bílana þína';

  @override
  String get btOnlyMode =>
      'Nota aðeins Bluetooth til að fækka fölskum viðvörunum';

  @override
  String get carsBody =>
      'Forritið virkar best ef þú velur Bluetooth-tengingar bílanna þinna.';

  @override
  String get carsWithBluetooth => 'Bílar með Bluetooth';

  @override
  String get noPairedDevices => 'Engin pöruð Bluetooth-tæki fundust.';

  @override
  String get activateParkingMonitoring => 'Virkja bílastæðavöktun';

  @override
  String get systemBluetoothSettings => 'Bluetooth-stillingar kerfisins';

  @override
  String get permissionsTitle => 'Heimildir';

  @override
  String get permissionsBody =>
      'Forritið þarf eftirfarandi heimildir til að fylgjast með bílnum þínum í bakgrunni.';

  @override
  String get activateMonitoring => 'Virkja vöktun';

  @override
  String get grantAllToContinue =>
      'Veittu allar heimildir hér að ofan til að halda áfram.';

  @override
  String get openSettings => 'Stillingar';

  @override
  String get grant => 'Leyfa';

  @override
  String get ok => 'Í lagi';

  @override
  String get permBluetooth => 'Bluetooth';

  @override
  String get permBluetoothDesc => 'Greina þegar þú yfirgefur bílinn';

  @override
  String get permLocation => 'Staðsetning';

  @override
  String get permLocationDesc => 'Vista bílastæðið og fylgjast með í bakgrunni';

  @override
  String get permActivity => 'Líkamleg hreyfing';

  @override
  String get permActivityDesc => 'Greina akstur og göngu';

  @override
  String get permNotifications => 'Tilkynningar';

  @override
  String get permNotificationsDesc => 'Senda bílastæðaáminningar';

  @override
  String get monitoringActive => 'Vöktun virk';

  @override
  String lastParkedAt(String time) {
    return 'Síðast lagt $time';
  }

  @override
  String get lastParkedNever => 'Síðasta bílastæði ekki mælt enn';

  @override
  String parkingExpires(String time) {
    return 'Bílastæði rennur út $time';
  }

  @override
  String get removeAdsButton =>
      'Fjarlægðu auglýsingar og styrktu almennilegan forritara. Næstum ókeypis!';

  @override
  String get testReminder => 'Prófunaráminning';

  @override
  String get testReminderDesc => 'Sjá tilkynningu, sírenu og rödd';

  @override
  String get manageCars => 'Sýsla með bíla';

  @override
  String get manageCarsDesc => 'Bæta við, fjarlægja eða skipta um bíla';

  @override
  String get findCar => 'Finna bílinn minn';

  @override
  String findCarRoute(String time) {
    return 'Leið að síðasta bílastæði $time';
  }

  @override
  String get findCarNone => 'Ekkert bílastæði vistað enn';

  @override
  String get ignoredLocationsAction => 'Hunsaðir staðir';

  @override
  String get ignoredLocationsActionDesc => 'Staðir sem kveikja ekki viðvörun';

  @override
  String get batteryCardTitle => 'Mælt með: undanþiggja frá rafhlöðuhagræðingu';

  @override
  String get batteryCardBody =>
      'Valfrjálst. Án þessa getur Android (sérstaklega Samsung) stöðvað hreyfivöktun í bakgrunni, þannig að bílastæði án Bluetooth greinist ekki alltaf.';

  @override
  String get batteryCardButton => 'Leyfa ótakmarkaðan bakgrunn';

  @override
  String get motionFetching => 'Hreyfing: sæki stöðu…';

  @override
  String get motionUnavailable => 'Hreyfing: staða ekki tiltæk';

  @override
  String get motionNoPermission =>
      'Hreyfing: engin heimild fyrir líkamlega hreyfingu';

  @override
  String motionError(String error) {
    return 'Hreyfivilla: $error';
  }

  @override
  String get motionRegistering => 'Hreyfing: skrái…';

  @override
  String get motionActive => 'Hreyfing virk';

  @override
  String get motionDormant => 'Hreyfing í dvala';

  @override
  String get motionWaitingData => 'bíð eftir gögnum';

  @override
  String get motionVehicleTimer => 'ökutækjateljari í gangi';

  @override
  String get motionWakesOnMovement => 'vaknar við hreyfingu';

  @override
  String get activityInVehicle => 'Í ökutæki';

  @override
  String get activityOnBicycle => 'Á hjóli';

  @override
  String get activityOnFoot => 'Gangandi';

  @override
  String get activityStill => 'Kyrr';

  @override
  String get activityTilting => 'Hallast';

  @override
  String get activityWalking => 'Geng';

  @override
  String get activityRunning => 'Hleyp';

  @override
  String get activityUnknown => 'Óþekkt';

  @override
  String get ignoredLocationsTitle => 'Hunsaðir staðir';

  @override
  String ignoredLocationsRadiusInfo(int meters) {
    return 'Viðvaranir birtast ekki innan $meters metra frá þessum stöðum.';
  }

  @override
  String get addCurrentLocation => 'Bæta við núverandi staðsetningu';

  @override
  String get sortBy => 'Raða eftir';

  @override
  String get sortTime => 'Tími';

  @override
  String get sortName => 'Nafn';

  @override
  String get sortDistance => 'Fjarlægð';

  @override
  String get noIgnoredLocations => 'Engir hunsaðir staðir';

  @override
  String get noIgnoredLocationsBody => 'Þú getur bætt við stað úr áminningu.';

  @override
  String get ignoredLocationDefault => 'Hunsaður staður';

  @override
  String addedAt(String time) {
    return 'Bætt við $time';
  }

  @override
  String get tapToOpenMap => 'Ýttu til að opna í korti';

  @override
  String get deleteAll => 'Eyða öllu';

  @override
  String get backToOverview => 'Til baka í yfirlit';

  @override
  String get locationFetchError => 'Ekki tókst að sækja staðsetningu.';

  @override
  String get locationAdded => 'Staðsetningu bætt við.';

  @override
  String get reminderTitle => 'Mundu að borga fyrir bílastæðið!';

  @override
  String get reminderBody =>
      'Við greindum að þú yfirgafst bílinn. Mundu að borga fyrir bílastæðið!';

  @override
  String get coordinates => 'Hnit';

  @override
  String get registeredLabel => 'Skráð';

  @override
  String get ignoreThisLocation => 'Hunsa alltaf þennan stað';

  @override
  String get timerCheckbox => 'Minna mig á að ganga til baka í tíma';

  @override
  String get timerHelp => 'Tilgreindu hversu lengi þú mátt leggja hér';

  @override
  String get pickTime => 'Velja tíma';

  @override
  String expiresAt(String time) {
    return 'Rennur út kl. $time';
  }

  @override
  String get pickExpiryTime => 'Veldu lokatíma';

  @override
  String get timerConfirmBody =>
      'Þú færð tilkynningu í tæka tíð til að ganga til baka að bílnum.';

  @override
  String get close => 'Loka';

  @override
  String ignoreHint(int meters) {
    return 'Ýttu á „Hunsa alltaf“ fyrir staði eins og heima eða vinnu, þar sem þú þarft sjaldan að borga fyrir bílastæði. Viðvörunin birtist ekki aftur innan $meters metra héðan. Með tímanum færðu færri óþarfa viðvaranir.';
  }

  @override
  String durationMinutes(int minutes) {
    return '$minutes mín';
  }

  @override
  String durationHours(int hours) {
    return '$hours klst';
  }

  @override
  String durationHoursMinutes(int hours, int minutes) {
    return '$hours klst $minutes mín';
  }

  @override
  String get notifParkingTitle => 'Mundu að borga fyrir bílastæðið!';

  @override
  String get notifParkingBody => 'Við greindum að þú yfirgafst bílinn.';

  @override
  String get notifWalkBackTitle => 'Flýttu þér til baka að bílnum!';

  @override
  String notifWalkBackBody(int minutes) {
    return 'Þú ættir að ganga núna — göngutími u.þ.b. $minutes mín og bílastæðið rennur brátt út.';
  }

  @override
  String get ttsRemember => 'Mundu bílastæðið';

  @override
  String get monitoringTitle => 'Parkingson';

  @override
  String get monitoringBody => 'Fylgist með bílnum þínum...';
}
