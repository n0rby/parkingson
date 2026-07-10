// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Finnish (`fi`).
class AppLocalizationsFi extends AppLocalizations {
  AppLocalizationsFi([String locale = 'fi']) : super(locale);

  @override
  String get welcomeTagline => 'Vältä pysäköintisakot';

  @override
  String get welcomeBody =>
      'Saat muistutuksen, kun poistut jostakin autostasi, ja paikka tallennetaan automaattisesti, jotta löydät auton uudelleen.';

  @override
  String get getStarted => 'Aloita';

  @override
  String get carsTitle => 'Valitse autosi';

  @override
  String get btOnlyMode =>
      'Käytä vain Bluetoothia vähentääksesi vääriä hälytyksiä';

  @override
  String get carsBody =>
      'Valitse autosi Bluetooth — yhteys, jonka puhelin muodostaa auton stereoihin, kun nouset autoon. Älä valitse kuulokkeita tai kuulokemikrofonia. Olemme esivalinneet ne, jotka näyttävät autoilta.';

  @override
  String get carsWithBluetooth => 'Autot, joissa on Bluetooth';

  @override
  String get noPairedDevices =>
      'Pariliitettyjä Bluetooth-laitteita ei löytynyt.';

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
  String get activateParkingMonitoring => 'Ota pysäköinnin valvonta käyttöön';

  @override
  String get save => 'Tallenna';

  @override
  String get systemBluetoothSettings => 'Järjestelmän Bluetooth-asetukset';

  @override
  String get permissionsTitle => 'Käyttöoikeudet';

  @override
  String get permissionsBody =>
      'Sovellus tarvitsee seuraavat käyttöoikeudet valvoakseen autoasi taustalla.';

  @override
  String get activateMonitoring => 'Ota valvonta käyttöön';

  @override
  String get grantAllToContinue =>
      'Myönnä kaikki yllä olevat käyttöoikeudet jatkaaksesi.';

  @override
  String get openSettings => 'Asetukset';

  @override
  String get grant => 'Salli';

  @override
  String get ok => 'OK';

  @override
  String get permBluetooth => 'Bluetooth';

  @override
  String get permBluetoothDesc => 'Tunnista, kun poistut autostasi';

  @override
  String get permLocation => 'Sijainti';

  @override
  String get permLocationDesc =>
      'Tallenna pysäköintipaikka — valitse \"Salli aina\", jotta se toimii taustalla';

  @override
  String get permActivity => 'Fyysinen aktiivisuus';

  @override
  String get permActivityDesc => 'Tunnista ajaminen ja käveleminen';

  @override
  String get permNotifications => 'Ilmoitukset';

  @override
  String get permNotificationsDesc => 'Lähetä pysäköintimuistutuksia';

  @override
  String get permBattery => 'Rajoittamaton taustakäyttö';

  @override
  String get permBatteryDesc => 'Jotta virransäästö ei pysäytä valvontaa';

  @override
  String get grantAllPermissions => 'Myönnä kaikki käyttöoikeudet';

  @override
  String get permMicrophone => 'Mikrofoni';

  @override
  String get permMicrophoneDesc => 'Muistutuksen äänikomentoja varten';

  @override
  String get voiceListening => 'Kuuntelee…';

  @override
  String get voicePrompt =>
      'Sano \"ohita\" tai \"pysäköintiaika 30 minuuttia\"';

  @override
  String voiceTimerSet(String time) {
    return 'Pysäköintiaika asetettu: $time';
  }

  @override
  String get voiceNotUnderstood => 'En ymmärtänyt — yritä uudelleen';

  @override
  String get voiceIgnoreConfirm => 'Ohitetaan tämä sijainti';

  @override
  String get setupDoneTitle => 'Parkingson on käynnissä';

  @override
  String get setupDoneBody =>
      'Parkingson odottaa nyt seuraavaa pysäköintiäsi. Saat muistutuksen, kun poistut autosta.';

  @override
  String get monitoringActive => 'Valvonta käytössä';

  @override
  String lastParkedAt(String time) {
    return 'Viimeksi pysäköity $time';
  }

  @override
  String get lastParkedNever => 'Viimeksi pysäköityä ei ole vielä mitattu';

  @override
  String parkingExpires(String time) {
    return 'Pysäköinti päättyy $time';
  }

  @override
  String get removeAdsButton =>
      'Poista mainokset ja tue mukavaa kehittäjää. Lähes ilmaista!';

  @override
  String get testReminder => 'Testimuistutus';

  @override
  String get testReminderDesc => 'Katso ilmoitus, sireeni ja ääni';

  @override
  String get manageCars => 'Hallitse autoja';

  @override
  String get manageCarsDesc => 'Lisää, poista tai vaihda autoja';

  @override
  String get findCar => 'Etsi autoni';

  @override
  String findCarRoute(String time) {
    return 'Reitti viimeksi pysäköityyn $time';
  }

  @override
  String get findCarNone => 'Pysäköintipaikkaa ei ole vielä tallennettu';

  @override
  String get ignoredLocationsAction => 'Ohitetut paikat';

  @override
  String get ignoredLocationsActionDesc =>
      'Paikat, jotka eivät laukaise hälytystä';

  @override
  String get setReminderTitle => 'Muistutus';

  @override
  String get setReminderDesc => 'Aseta aika kävellä takaisin autolle';

  @override
  String get retry => 'Yritä uudelleen';

  @override
  String get setupTitle => 'Asetukset';

  @override
  String get setupDesc => 'Mukauta sovellusta';

  @override
  String get soundTitle => 'Ääni';

  @override
  String get soundDesc => 'Hälytyksen äänenvoimakkuus';

  @override
  String get soundUsePhone => 'Käytä puhelimen äänenvoimakkuutta';

  @override
  String get soundUseApp => 'Käytä sovelluksen äänenvoimakkuutta';

  @override
  String get soundVolume => 'Sovelluksen äänenvoimakkuus';

  @override
  String get soundAlarmSound => 'Hälytysääni';

  @override
  String get soundVibrateDnd => 'Vain värinä \"Älä häiritse\" -tilassa';

  @override
  String get soundVibrateSilent => 'Vain värinä, kun äänenvoimakkuus on 0';

  @override
  String get parkingAppsTitle => 'Pysäköintisovellukset';

  @override
  String get parkingAppsDesc =>
      'Valitse sovellukset, joita käytät pysäköintiin';

  @override
  String get parkingAppsBody =>
      'Merkitse sovellukset, joilla maksat pysäköinnistä, esim. EasyPark tai Q-Park.';

  @override
  String get parkingAppsSearch => 'Hae sovelluksia';

  @override
  String get parkingAppsKnown => 'Pysäköintisovellukset';

  @override
  String get parkingAppsOther => 'Muut sovellukset';

  @override
  String get parkingAppsNone => 'Sovelluksia ei löytynyt.';

  @override
  String get batteryCardTitle => 'Suositus: vapauta akun optimoinnista';

  @override
  String get batteryCardBody =>
      'Valinnainen. Ilman tätä Android (erityisesti Samsung) voi pysäyttää liikkeen valvonnan taustalla, jolloin pysäköintiä ilman Bluetoothia ei aina havaita.';

  @override
  String get batteryCardButton => 'Salli rajoittamaton taustakäyttö';

  @override
  String get motionFetching => 'Liike: haetaan tilaa…';

  @override
  String get motionUnavailable => 'Liike: tila ei saatavilla';

  @override
  String get motionNoPermission =>
      'Liike: ei fyysisen aktiivisuuden käyttöoikeutta';

  @override
  String motionError(String error) {
    return 'Liikevirhe: $error';
  }

  @override
  String get motionRegistering => 'Liike: rekisteröidään…';

  @override
  String get motionActive => 'Liike aktiivinen';

  @override
  String get motionDormant => 'Liike lepotilassa';

  @override
  String get motionWaitingData => 'odotetaan tietoja';

  @override
  String get motionVehicleTimer => 'ajoneuvon ajastin käynnissä';

  @override
  String get motionWakesOnMovement => 'herää liikkeestä';

  @override
  String get activityInVehicle => 'Ajoneuvossa';

  @override
  String get activityOnBicycle => 'Pyörällä';

  @override
  String get activityOnFoot => 'Jalan';

  @override
  String get activityStill => 'Paikallaan';

  @override
  String get activityTilting => 'Kallistuu';

  @override
  String get activityWalking => 'Kävelee';

  @override
  String get activityRunning => 'Juoksee';

  @override
  String get activityUnknown => 'Tuntematon';

  @override
  String get ignoredLocationsTitle => 'Ohitetut paikat';

  @override
  String ignoredLocationsRadiusInfo(int meters) {
    return 'Hälytyksiä ei näytetä $meters metrin sisällä näistä paikoista.';
  }

  @override
  String get addCurrentLocation => 'Lisää nykyinen sijainti';

  @override
  String get sortBy => 'Lajitteluperuste';

  @override
  String get sortTime => 'Aika';

  @override
  String get sortName => 'Nimi';

  @override
  String get sortDistance => 'Etäisyys';

  @override
  String get noIgnoredLocations => 'Ei ohitettuja paikkoja';

  @override
  String get noIgnoredLocationsBody => 'Voit lisätä paikan muistutuksesta.';

  @override
  String get ignoredLocationDefault => 'Ohitettu paikka';

  @override
  String addedAt(String time) {
    return 'Lisätty $time';
  }

  @override
  String get tapToOpenMap => 'Avaa kartalla napauttamalla';

  @override
  String get deleteAll => 'Poista kaikki';

  @override
  String get backToOverview => 'Takaisin yleisnäkymään';

  @override
  String get finishSetup => 'Valmis';

  @override
  String get locationFetchError => 'Sijaintia ei voitu hakea.';

  @override
  String get locationAdded => 'Sijainti lisätty.';

  @override
  String get reminderTitle => 'Muista maksaa pysäköinnistä!';

  @override
  String get reminderBody =>
      'Havaitsimme, että poistuit autostasi. Muista maksaa pysäköinnistä!';

  @override
  String get coordinates => 'Koordinaatit';

  @override
  String get registeredLabel => 'Rekisteröity';

  @override
  String get ignoreThisLocation => 'Ohita tämä paikka aina';

  @override
  String get timerCheckbox => 'Muistuta minua palaamaan ajoissa';

  @override
  String get timerHelp => 'Määritä, kuinka kauan saat pysäköidä tähän';

  @override
  String get pickTime => 'Valitse aika';

  @override
  String expiresAt(String time) {
    return 'Päättyy klo $time';
  }

  @override
  String get pickExpiryTime => 'Valitse päättymisaika';

  @override
  String get timerConfirmBody =>
      'Saat ilmoituksen hyvissä ajoin, jotta ehdit takaisin autolle.';

  @override
  String get close => 'Sulje';

  @override
  String ignoreHint(int meters) {
    return 'Napauta \"Ohita aina\" paikoissa kuten koti tai työ, joissa sinun ei tarvitse usein maksaa pysäköinnistä. Hälytystä ei näytetä uudelleen $meters metrin sisällä tästä. Ajan myötä saat vähemmän tarpeettomia hälytyksiä.';
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
  String get notifParkingTitle => 'Muista maksaa pysäköinnistä!';

  @override
  String get notifParkingBody => 'Havaitsimme, että poistuit autostasi.';

  @override
  String get notifWalkBackTitle => 'Kiiruhda takaisin autolle!';

  @override
  String notifWalkBackBody(int minutes) {
    return 'Sinun pitäisi lähteä nyt — kävelyaika noin $minutes min ja pysäköinti päättyy pian.';
  }

  @override
  String get ttsRemember =>
      'Muista pysäköinti, tai poista hälytys tästä paikasta käytöstä';

  @override
  String get monitoringTitle => 'Parkingson';

  @override
  String get monitoringBody => 'Valvotaan autoasi...';
}
