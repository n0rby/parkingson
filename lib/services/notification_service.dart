import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_tts/flutter_tts.dart';

const _alarmChannel = MethodChannel('dk.parkingson/alarm');

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

    // Create all notification channels up front so the background service
    // can post its foreground notification immediately on start.
    final android = _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await android?.createNotificationChannel(const AndroidNotificationChannel(
      _channelId,
      _channelName,
      importance: Importance.high,
    ));
    await android?.createNotificationChannel(const AndroidNotificationChannel(
      'parkingson_monitoring',
      'Parkeringsovervågning',
      description: 'Viser at appen overvåger din bil i baggrunden',
      importance: Importance.low,
    ));
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

  Future<void> playAlarm() async {
    await _alarmChannel.invokeMethod('playAlarm');
    await Future.delayed(const Duration(milliseconds: 300));
    final tts = FlutterTts();
    await tts.setLanguage('da-DK');
    await tts.setSpeechRate(0.5);
    await tts.speak('Husk parkering');
  }

  String? Function(NotificationResponse)? get onNotificationTap => null;
}

// Top-level helpers used by background service isolate — no class instance needed.

Future<void> showTimerAlarmFromBackground({required int walkMinutes}) async {
  await _plugin.initialize(
    const InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    ),
  );
  await _plugin.show(
    2,
    'Skynd dig tilbage til bilen!',
    'Du skal gå nu — gangtid ca. $walkMinutes min og parkering udløber snart.',
    const NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId, _channelName,
        importance: Importance.high,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
      ),
      iOS: DarwinNotificationDetails(presentAlert: true, presentSound: true),
    ),
  );
}

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
