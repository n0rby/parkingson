import 'package:flutter_local_notifications/flutter_local_notifications.dart';

const _channelId = 'parking_reminder';
const _channelName = 'Parkeringspåmindelser';
const _reminderNotificationId = 1;

final _plugin = FlutterLocalNotificationsPlugin();

class NotificationService {
  Future<void> initialize() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    await _plugin.initialize(
      const InitializationSettings(android: androidSettings, iOS: iosSettings),
    );
  }

  Future<void> requestPermissions() async {
    await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    await _plugin
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, sound: true, badge: false);
  }

  Future<void> showParkingReminder({String? payload}) async {
    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
    );
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentSound: true,
    );
    await _plugin.show(
      _reminderNotificationId,
      'Husk at betale for parkering!',
      'Vi registrerede at du har forladt din bil.',
      const NotificationDetails(android: androidDetails, iOS: iosDetails),
      payload: payload,
    );
  }

  String? Function(NotificationResponse)? get onNotificationTap => null;
}

// Top-level helper used by background service isolate — no class instance needed.
Future<void> showParkingReminderFromBackground({String? payload}) async {
  await _plugin.initialize(
    const InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    ),
  );
  await _plugin.show(
    _reminderNotificationId,
    'Husk at betale for parkering!',
    'Vi registrerede at du har forladt din bil.',
    const NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId, _channelName,
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(presentAlert: true, presentSound: true),
    ),
    payload: payload,
  );
}
