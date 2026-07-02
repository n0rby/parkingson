// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get welcomeTagline => 'Evita multas de estacionamiento';

  @override
  String get welcomeBody =>
      'Recibe un recordatorio cuando dejes uno de tus coches y guarda el lugar automáticamente para volver a encontrarlo.';

  @override
  String get getStarted => 'Empezar';

  @override
  String get carsTitle => 'Elige tus coches';

  @override
  String get btOnlyMode =>
      'Usar solo Bluetooth para reducir las falsas alarmas';

  @override
  String get carsBody =>
      'La aplicación funciona mejor si seleccionas las conexiones Bluetooth de tus coches.';

  @override
  String get carsWithBluetooth => 'Coches con Bluetooth';

  @override
  String get noPairedDevices =>
      'No se encontraron dispositivos Bluetooth emparejados.';

  @override
  String get activateParkingMonitoring =>
      'Activar la supervisión de estacionamiento';

  @override
  String get systemBluetoothSettings => 'Ajustes de Bluetooth del sistema';

  @override
  String get permissionsTitle => 'Permisos';

  @override
  String get permissionsBody =>
      'La aplicación necesita los siguientes permisos para supervisar tu coche en segundo plano.';

  @override
  String get activateMonitoring => 'Activar la supervisión';

  @override
  String get grantAllToContinue =>
      'Concede todos los permisos anteriores para continuar.';

  @override
  String get openSettings => 'Ajustes';

  @override
  String get grant => 'Conceder';

  @override
  String get ok => 'OK';

  @override
  String get permBluetooth => 'Bluetooth';

  @override
  String get permBluetoothDesc => 'Detectar cuándo dejas tu coche';

  @override
  String get permLocation => 'Ubicación';

  @override
  String get permLocationDesc =>
      'Guardar el lugar de estacionamiento y supervisar en segundo plano';

  @override
  String get permActivity => 'Actividad física';

  @override
  String get permActivityDesc => 'Detectar conducción y caminata';

  @override
  String get permNotifications => 'Notificaciones';

  @override
  String get permNotificationsDesc => 'Enviar recordatorios de estacionamiento';

  @override
  String get monitoringActive => 'Supervisión activa';

  @override
  String lastParkedAt(String time) {
    return 'Último estacionamiento $time';
  }

  @override
  String get lastParkedNever => 'Último estacionamiento aún no medido';

  @override
  String parkingExpires(String time) {
    return 'El estacionamiento vence $time';
  }

  @override
  String get removeAdsButton =>
      'Quita los anuncios y apoya a un desarrollador simpático. ¡Casi gratis!';

  @override
  String get testReminder => 'Recordatorio de prueba';

  @override
  String get testReminderDesc => 'Ver notificación, sirena y voz';

  @override
  String get manageCars => 'Gestionar coches';

  @override
  String get manageCarsDesc => 'Añadir, quitar o cambiar coches';

  @override
  String get findCar => 'Encontrar mi coche';

  @override
  String findCarRoute(String time) {
    return 'Ruta al último estacionamiento $time';
  }

  @override
  String get findCarNone =>
      'Aún no se ha guardado ningún lugar de estacionamiento';

  @override
  String get ignoredLocationsAction => 'Lugares ignorados';

  @override
  String get ignoredLocationsActionDesc => 'Lugares que no activan la alarma';

  @override
  String get batteryCardTitle =>
      'Recomendado: excluir de la optimización de batería';

  @override
  String get batteryCardBody =>
      'Opcional. Sin esto, Android (especialmente Samsung) puede detener la supervisión de movimiento en segundo plano, por lo que el estacionamiento sin Bluetooth no siempre se detecta.';

  @override
  String get batteryCardButton => 'Permitir segundo plano sin restricciones';

  @override
  String get motionFetching => 'Movimiento: obteniendo estado…';

  @override
  String get motionUnavailable => 'Movimiento: estado no disponible';

  @override
  String get motionNoPermission =>
      'Movimiento: sin permiso de actividad física';

  @override
  String motionError(String error) {
    return 'Error de movimiento: $error';
  }

  @override
  String get motionRegistering => 'Movimiento: registrando…';

  @override
  String get motionActive => 'Movimiento activo';

  @override
  String get motionDormant => 'Movimiento en reposo';

  @override
  String get motionWaitingData => 'esperando datos';

  @override
  String get motionVehicleTimer => 'temporizador de vehículo en marcha';

  @override
  String get motionWakesOnMovement => 'se activa con el movimiento';

  @override
  String get activityInVehicle => 'En vehículo';

  @override
  String get activityOnBicycle => 'En bicicleta';

  @override
  String get activityOnFoot => 'A pie';

  @override
  String get activityStill => 'Quieto';

  @override
  String get activityTilting => 'Inclinando';

  @override
  String get activityWalking => 'Caminando';

  @override
  String get activityRunning => 'Corriendo';

  @override
  String get activityUnknown => 'Desconocido';

  @override
  String get ignoredLocationsTitle => 'Lugares ignorados';

  @override
  String ignoredLocationsRadiusInfo(int meters) {
    return 'Las alarmas no se muestran a menos de $meters metros de estos lugares.';
  }

  @override
  String get addCurrentLocation => 'Añadir ubicación actual';

  @override
  String get sortBy => 'Ordenar por';

  @override
  String get sortTime => 'Hora';

  @override
  String get sortName => 'Nombre';

  @override
  String get sortDistance => 'Distancia';

  @override
  String get noIgnoredLocations => 'No hay lugares ignorados';

  @override
  String get noIgnoredLocationsBody =>
      'Puedes añadir un lugar desde un recordatorio.';

  @override
  String get ignoredLocationDefault => 'Lugar ignorado';

  @override
  String addedAt(String time) {
    return 'Añadido $time';
  }

  @override
  String get tapToOpenMap => 'Toca para abrir en el mapa';

  @override
  String get deleteAll => 'Eliminar todo';

  @override
  String get backToOverview => 'Volver al resumen';

  @override
  String get locationFetchError => 'No se pudo obtener la ubicación.';

  @override
  String get locationAdded => 'Ubicación añadida.';

  @override
  String get reminderTitle => '¡Recuerda pagar el estacionamiento!';

  @override
  String get reminderBody =>
      'Detectamos que dejaste tu coche. ¡Recuerda pagar el estacionamiento!';

  @override
  String get coordinates => 'Coordenadas';

  @override
  String get registeredLabel => 'Registrado';

  @override
  String get ignoreThisLocation => 'Ignorar siempre este lugar';

  @override
  String get timerCheckbox => 'Recuérdame volver a tiempo';

  @override
  String get timerHelp => 'Indica cuánto tiempo puedes estacionar aquí';

  @override
  String get pickTime => 'Elegir hora';

  @override
  String expiresAt(String time) {
    return 'Vence a las $time';
  }

  @override
  String get pickExpiryTime => 'Elegir hora de vencimiento';

  @override
  String get timerConfirmBody =>
      'Recibirás un aviso con tiempo para volver al coche.';

  @override
  String get close => 'Cerrar';

  @override
  String ignoreHint(int meters) {
    return 'Toca «Ignorar siempre» para lugares como casa o el trabajo, donde raramente pagas el estacionamiento. La alarma no volverá a aparecer dentro de $meters metros de aquí. Con el tiempo tendrás menos alarmas innecesarias.';
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
  String get notifParkingTitle => '¡Recuerda pagar el estacionamiento!';

  @override
  String get notifParkingBody => 'Detectamos que dejaste tu coche.';

  @override
  String get notifWalkBackTitle => '¡Date prisa en volver al coche!';

  @override
  String notifWalkBackBody(int minutes) {
    return 'Debes salir ahora: tiempo a pie aprox. $minutes min y el estacionamiento vence pronto.';
  }

  @override
  String get ttsRemember =>
      'Recuerda el estacionamiento, o desactiva la alarma para este lugar';

  @override
  String get monitoringTitle => 'Parkingson';

  @override
  String get monitoringBody => 'Supervisando tu coche...';
}
