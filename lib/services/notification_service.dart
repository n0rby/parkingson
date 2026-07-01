import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../l10n/app_localizations.dart';

const _alarmChannel = MethodChannel('dk.parkingson/alarm');

/// Localizations for background/isolate use, based on the device locale.
AppLocalizations _bgL10n() {
  final device = PlatformDispatcher.instance.locale;
  final match = AppLocalizations.supportedLocales.firstWhere(
    (l) => l.languageCode == device.languageCode,
    orElse: () => const Locale('en'),
  );
  return lookupAppLocalizations(match);
}

/// BCP-47 language tag for TTS, matching the device locale.
String _ttsTag() => PlatformDispatcher.instance.locale.toLanguageTag();

const _channelId = 'parking_reminder';
const _channelName = 'Parkeringspåmindelser';
const _reminderNotificationId = 1;

// How long the reminder notification stays before Android auto-dismisses it.
const _reminderTimeoutMs = 60000;

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
    final l10n = _bgL10n();
    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      timeoutAfter: _reminderTimeoutMs,
    );
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentSound: true,
    );
    await _plugin.show(
      _reminderNotificationId,
      l10n.notifParkingTitle,
      l10n.notifParkingBody,
      const NotificationDetails(android: androidDetails, iOS: iosDetails),
      payload: payload,
    );
  }

  Future<void> playAlarm() async {
    await _alarmChannel.invokeMethod('playAlarm');
    await Future.delayed(const Duration(milliseconds: 300));
    final tts = FlutterTts();
    await tts.setLanguage(_ttsTag());
    await tts.setSpeechRate(0.5);
    await tts.speak(_bgL10n().ttsRemember);
  }

  String? Function(NotificationResponse)? get onNotificationTap => null;
}

// Top-level helpers used by background service isolate — no class instance needed.

Future<void> showTimerAlarmFromBackground({required int walkMinutes}) async {
  final l10n = _bgL10n();
  await _plugin.initialize(
    const InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    ),
  );
  await _plugin.show(
    2,
    l10n.notifWalkBackTitle,
    l10n.notifWalkBackBody(walkMinutes),
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
  final l10n = _bgL10n();
  await _plugin.initialize(
    const InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    ),
  );
  await _plugin.show(
    _reminderNotificationId,
    l10n.notifParkingTitle,
    l10n.notifParkingBody,
    const NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId, _channelName,
        importance: Importance.high,
        priority: Priority.high,
        timeoutAfter: _reminderTimeoutMs,
      ),
      iOS: DarwinNotificationDetails(presentAlert: true, presentSound: true),
    ),
    payload: payload,
  );
}
