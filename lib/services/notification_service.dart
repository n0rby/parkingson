// TODO: Implement using flutter_local_notifications
class NotificationService {
  Future<void> initialize() async {
    // TODO: Initialize FlutterLocalNotificationsPlugin
    // Configure Android + iOS notification channels
  }

  Future<void> showParkingReminder({
    required String carName,
    required String? parkingAppName,
  }) async {
    // TODO: Show notification with car name and deep-link to parking app
  }

  Future<void> playAlarm() async {
    // TODO: Play siren/alarm sound
  }
}
