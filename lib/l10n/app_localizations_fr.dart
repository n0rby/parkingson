// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get welcomeTagline => 'Évitez les amendes de stationnement';

  @override
  String get welcomeBody =>
      'Recevez un rappel lorsque vous quittez l\'une de vos voitures, et enregistrez automatiquement l\'endroit pour la retrouver.';

  @override
  String get getStarted => 'Commencer';

  @override
  String get carsTitle => 'Choisissez vos voitures';

  @override
  String get btOnlyMode =>
      'Utiliser uniquement le Bluetooth pour réduire les fausses alertes';

  @override
  String get carsBody =>
      'Choisissez le Bluetooth de votre voiture — la connexion que votre téléphone établit avec l\'autoradio quand vous montez. Ne choisissez pas d\'écouteurs ni de casque. Nous avons présélectionné ceux qui ressemblent à des voitures.';

  @override
  String get carsWithBluetooth => 'Voitures avec Bluetooth';

  @override
  String get noPairedDevices => 'Aucun appareil Bluetooth appairé trouvé.';

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
  String get activateParkingMonitoring =>
      'Activer la surveillance du stationnement';

  @override
  String get save => 'Enregistrer';

  @override
  String get systemBluetoothSettings => 'Paramètres Bluetooth du système';

  @override
  String get permissionsTitle => 'Autorisations';

  @override
  String get permissionsBody =>
      'L\'application a besoin des autorisations suivantes pour surveiller votre voiture en arrière-plan.';

  @override
  String get activateMonitoring => 'Activer la surveillance';

  @override
  String get grantAllToContinue =>
      'Accordez toutes les autorisations ci-dessus pour continuer.';

  @override
  String get openSettings => 'Paramètres';

  @override
  String get grant => 'Accorder';

  @override
  String get ok => 'OK';

  @override
  String get permBluetooth => 'Bluetooth';

  @override
  String get permBluetoothDesc => 'Détecter quand vous quittez votre voiture';

  @override
  String get permLocation => 'Localisation';

  @override
  String get permLocationDesc =>
      'Enregistrer le lieu — choisissez \"Toujours autoriser\" pour l\'arrière-plan';

  @override
  String get permActivity => 'Activité physique';

  @override
  String get permActivityDesc => 'Détecter la conduite et la marche';

  @override
  String get permNotifications => 'Notifications';

  @override
  String get permNotificationsDesc => 'Envoyer des rappels de stationnement';

  @override
  String get permBattery => 'Arrière-plan sans restriction';

  @override
  String get permBatteryDesc =>
      'Pour que l\'économie de batterie n\'arrête pas la surveillance';

  @override
  String get grantAllPermissions => 'Accorder toutes les autorisations';

  @override
  String get permMicrophone => 'Microphone';

  @override
  String get permMicrophoneDesc => 'Pour les commandes vocales du rappel';

  @override
  String get voiceListening => 'Écoute…';

  @override
  String get voicePrompt =>
      'Dites \"ignorer\" ou \"temps de stationnement 30 minutes\"';

  @override
  String voiceTimerSet(String time) {
    return 'Temps de stationnement réglé sur $time';
  }

  @override
  String get voiceNotUnderstood => 'Je n\'ai pas compris — réessayez';

  @override
  String get voiceIgnoreConfirm => 'Ce lieu est ignoré';

  @override
  String get setupDoneTitle => 'Parkingson est actif';

  @override
  String get setupDoneBody =>
      'Parkingson attend maintenant votre prochain stationnement. Vous recevrez un rappel lorsque vous quitterez la voiture.';

  @override
  String get monitoringActive => 'Surveillance active';

  @override
  String lastParkedAt(String time) {
    return 'Dernier stationnement $time';
  }

  @override
  String get lastParkedNever => 'Dernier stationnement pas encore mesuré';

  @override
  String parkingExpires(String time) {
    return 'Le stationnement expire $time';
  }

  @override
  String get removeAdsButton =>
      'Supprimez les publicités et soutenez un développeur sympa. Presque gratuit !';

  @override
  String get testReminder => 'Rappel de test';

  @override
  String get testReminderDesc => 'Voir la notification, la sirène et la voix';

  @override
  String get manageCars => 'Gérer les voitures';

  @override
  String get manageCarsDesc => 'Ajouter, supprimer ou changer de voitures';

  @override
  String get findCar => 'Trouver ma voiture';

  @override
  String findCarRoute(String time) {
    return 'Itinéraire vers le dernier stationnement $time';
  }

  @override
  String get findCarNone => 'Aucun lieu de stationnement enregistré';

  @override
  String get ignoredLocationsAction => 'Lieux ignorés';

  @override
  String get ignoredLocationsActionDesc =>
      'Endroits qui ne déclenchent pas d\'alarme';

  @override
  String get setReminderTitle => 'Rappel';

  @override
  String get setReminderDesc => 'Définir une heure pour retourner à la voiture';

  @override
  String get retry => 'Réessayer';

  @override
  String get setupTitle => 'Configuration';

  @override
  String get setupDesc => 'Personnaliser l\'application';

  @override
  String get soundTitle => 'Son';

  @override
  String get soundDesc => 'Volume de l\'alarme';

  @override
  String get soundUsePhone => 'Utiliser le volume du téléphone';

  @override
  String get soundUseApp => 'Utiliser le volume de l\'application';

  @override
  String get soundVolume => 'Volume de l\'application';

  @override
  String get soundAlarmSound => 'Sonnerie d\'alarme';

  @override
  String get soundVibrateDnd => 'Vibrer uniquement en \"Ne pas déranger\"';

  @override
  String get soundVibrateSilent => 'Vibrer uniquement quand le volume est à 0';

  @override
  String get parkingAppsTitle => 'Applis de stationnement';

  @override
  String get parkingAppsDesc =>
      'Choisissez les applis que vous utilisez pour le stationnement';

  @override
  String get parkingAppsBody =>
      'Sélectionnez les applis que vous utilisez pour payer le stationnement, par ex. EasyPark ou Q-Park.';

  @override
  String get parkingAppsSearch => 'Rechercher des applis';

  @override
  String get parkingAppsKnown => 'Applis de stationnement';

  @override
  String get parkingAppsOther => 'Autres applis';

  @override
  String get parkingAppsNone => 'Aucune appli trouvée.';

  @override
  String get batteryCardTitle =>
      'Recommandé : exclure de l\'optimisation de la batterie';

  @override
  String get batteryCardBody =>
      'Facultatif. Sans cela, Android (surtout Samsung) peut arrêter la surveillance du mouvement en arrière-plan, de sorte que le stationnement sans Bluetooth n\'est pas toujours détecté.';

  @override
  String get batteryCardButton => 'Autoriser l\'arrière-plan sans restriction';

  @override
  String get exactAlarmCardTitle => 'Recommended: allow alarms & reminders';

  @override
  String get exactAlarmCardBody =>
      'Lets the app restart monitoring by itself after you close it from recents (\"Clear all\"). Without it, monitoring stays off until you reopen the app.';

  @override
  String get exactAlarmCardButton => 'Allow alarms & reminders';

  @override
  String get motionFetching => 'Mouvement : récupération du statut…';

  @override
  String get motionUnavailable => 'Mouvement : statut indisponible';

  @override
  String get motionNoPermission =>
      'Mouvement : aucune autorisation d\'activité physique';

  @override
  String motionError(String error) {
    return 'Erreur de mouvement : $error';
  }

  @override
  String get motionRegistering => 'Mouvement : enregistrement…';

  @override
  String get motionActive => 'Mouvement actif';

  @override
  String get motionDormant => 'Mouvement en veille';

  @override
  String get motionWaitingData => 'en attente de données';

  @override
  String get motionVehicleTimer => 'minuteur véhicule en cours';

  @override
  String get motionWakesOnMovement => 'se réveille au mouvement';

  @override
  String get activityInVehicle => 'En véhicule';

  @override
  String get activityOnBicycle => 'À vélo';

  @override
  String get activityOnFoot => 'À pied';

  @override
  String get activityStill => 'Immobile';

  @override
  String get activityTilting => 'Inclinaison';

  @override
  String get activityWalking => 'Marche';

  @override
  String get activityRunning => 'Course';

  @override
  String get activityUnknown => 'Inconnu';

  @override
  String get ignoredLocationsTitle => 'Lieux ignorés';

  @override
  String ignoredLocationsRadiusInfo(int meters) {
    return 'Les alarmes ne s\'affichent pas à moins de $meters mètres de ces lieux.';
  }

  @override
  String get addCurrentLocation => 'Ajouter le lieu actuel';

  @override
  String get sortBy => 'Trier par';

  @override
  String get sortTime => 'Heure';

  @override
  String get sortName => 'Nom';

  @override
  String get sortDistance => 'Distance';

  @override
  String get noIgnoredLocations => 'Aucun lieu ignoré';

  @override
  String get noIgnoredLocationsBody =>
      'Vous pouvez ajouter un lieu depuis un rappel.';

  @override
  String get ignoredLocationDefault => 'Lieu ignoré';

  @override
  String addedAt(String time) {
    return 'Ajouté $time';
  }

  @override
  String get tapToOpenMap => 'Appuyez pour ouvrir dans la carte';

  @override
  String get deleteAll => 'Tout supprimer';

  @override
  String get backToOverview => 'Retour à l\'aperçu';

  @override
  String get finishSetup => 'Terminé';

  @override
  String get locationFetchError => 'Impossible d\'obtenir la localisation.';

  @override
  String get locationAdded => 'Lieu ajouté.';

  @override
  String get reminderTitle => 'N\'oubliez pas de payer le stationnement !';

  @override
  String get reminderBody =>
      'Nous avons détecté que vous avez quitté votre voiture. N\'oubliez pas de payer le stationnement !';

  @override
  String get coordinates => 'Coordonnées';

  @override
  String get registeredLabel => 'Enregistré';

  @override
  String get ignoreThisLocation => 'Toujours ignorer ce lieu';

  @override
  String get timerCheckbox => 'Me rappeler de revenir à temps';

  @override
  String get timerHelp =>
      'Indiquez combien de temps vous pouvez stationner ici';

  @override
  String get pickTime => 'Choisir l\'heure';

  @override
  String expiresAt(String time) {
    return 'Expire à $time';
  }

  @override
  String get pickExpiryTime => 'Choisir l\'heure d\'expiration';

  @override
  String get timerConfirmBody =>
      'Vous serez averti à temps pour retourner à la voiture.';

  @override
  String get close => 'Fermer';

  @override
  String ignoreHint(int meters) {
    return 'Appuyez sur « Toujours ignorer » pour des lieux comme la maison ou le travail, où vous payez rarement le stationnement. L\'alarme ne réapparaîtra pas dans un rayon de $meters mètres. Avec le temps, vous aurez moins d\'alarmes inutiles.';
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
  String get notifParkingTitle => 'N\'oubliez pas de payer le stationnement !';

  @override
  String get notifParkingBody =>
      'Nous avons détecté que vous avez quitté votre voiture.';

  @override
  String get notifWalkBackTitle => 'Dépêchez-vous de retourner à la voiture !';

  @override
  String notifWalkBackBody(int minutes) {
    return 'Vous devez partir maintenant — temps de marche env. $minutes min et le stationnement expire bientôt.';
  }

  @override
  String get ttsRemember =>
      'Pensez au stationnement, ou désactivez l\'alarme pour ce lieu';

  @override
  String get monitoringTitle => 'Parkingson';

  @override
  String get monitoringBody => 'Surveillance de votre voiture...';
}
