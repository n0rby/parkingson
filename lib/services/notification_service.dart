import 'dart:io';
import 'dart:ui';
import 'package:android_intent_plus/android_intent.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../l10n/app_localizations.dart';

/// Localizations for background/isolate use, based on the device locale.
AppLocalizations _bgL10n() {
  final device = PlatformDispatcher.instance.locale;
  final match = AppLocalizations.supportedLocales.firstWhere(
    (l) => l.languageCode == device.languageCode,
    orElse: () => const Locale('en'),
  );
  return lookupAppLocalizations(match);
}

const _channelId = 'parking_reminder';
const _channelName = 'Parkeringspåmindelser';
const _reminderNotificationId = 1;

// The reminder notifications are silent/visual only — audio and vibration are
// handled natively by AlarmPlayer (which is Do-Not-Disturb aware), so nothing
// doubles up.
const _visualChannelId = 'parking_visual';
const _visualChannelName = 'Parkeringspåmindelser';
const _visualChannel = AndroidNotificationChannel(
  _visualChannelId,
  _visualChannelName,
  description: 'Viser parkeringspåmindelser',
  importance: Importance.high,
  playSound: false,
  enableVibration: false,
);

const _pendingVoiceKey = 'pending_alarm_voice';

final _plugin = FlutterLocalNotificationsPlugin();

/// Triggers the native, DND-aware alarm (loud sound, or pulse vibration in Do
/// Not Disturb) and remembers the phrase to speak when the app is opened.
/// Works from both the foreground and the background isolate.
///
/// On Android the reminder notification is also posted natively (from
/// [title]/[body]) so a swipe-away can stop the alarm — see
/// `ReminderNotification` / `AlarmReceiver` on the Kotlin side. iOS posts its
/// notification via flutter_local_notifications instead (this is a no-op there).
Future<void> fireAlarm(String voiceText, {String? title, String? body}) async {
  if (!Platform.isAndroid) return;
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(
    _pendingVoiceKey,
    '${DateTime.now().millisecondsSinceEpoch}|$voiceText',
  );
  final intent = AndroidIntent(
    // `action` is an arbitrary shared string (matches the receiver in the
    // manifest); `package` must be the app's applicationId to deliver the
    // explicit broadcast to our (non-exported) AlarmReceiver.
    action: 'dk.parkingson.parkingson.PLAY_ALARM',
    package: 'henrock.n0rby.parkingson',
    arguments: <String, dynamic>{
      'title': ?title,
      'body': ?body,
    },
  );
  try {
    await intent.sendBroadcast();
  } catch (_) {}
}

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
    await android?.createNotificationChannel(_visualChannel);
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
    // Android posts the reminder notification natively (see [fireAlarm] →
    // ReminderNotification) so swiping it away can stop the alarm. iOS still
    // uses the local-notifications plugin.
    if (!Platform.isIOS) return;
    final l10n = _bgL10n();
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentSound: true,
    );
    await _plugin.show(
      _reminderNotificationId,
      l10n.notifParkingTitle,
      l10n.notifParkingBody,
      const NotificationDetails(iOS: iosDetails),
      payload: payload,
    );
  }

  String? Function(NotificationResponse)? get onNotificationTap => null;
}

// Top-level helpers used by background service isolate — no class instance needed.

Future<void> showTimerAlarmFromBackground({required int walkMinutes}) async {
  final l10n = _bgL10n();
  // Android posts this notification natively (see [fireAlarm]) so a swipe-away
  // can stop the alarm; iOS uses the local-notifications plugin.
  if (Platform.isIOS) {
    await _plugin.initialize(
      const InitializationSettings(iOS: DarwinInitializationSettings()),
    );
    await _plugin.show(
      2,
      l10n.notifWalkBackTitle,
      l10n.notifWalkBackBody(walkMinutes),
      const NotificationDetails(
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentSound: true,
          interruptionLevel: InterruptionLevel.timeSensitive,
        ),
      ),
    );
  }

  // Native, DND-aware alarm (loud sound, or pulse vibration in Do Not Disturb),
  // plus the native reminder notification on Android.
  await fireAlarm(
    l10n.notifWalkBackTitle,
    title: l10n.notifWalkBackTitle,
    body: l10n.notifWalkBackBody(walkMinutes),
  );
}

Future<void> showParkingReminderFromBackground({String? payload}) async {
  final l10n = _bgL10n();
  // Android posts this notification natively (see [fireAlarm]) so a swipe-away
  // can stop the alarm; iOS uses the local-notifications plugin.
  if (Platform.isIOS) {
    await _plugin.initialize(
      const InitializationSettings(iOS: DarwinInitializationSettings()),
    );
    await _plugin.show(
      _reminderNotificationId,
      l10n.notifParkingTitle,
      l10n.notifParkingBody,
      const NotificationDetails(
        iOS: DarwinNotificationDetails(presentAlert: true, presentSound: true),
      ),
      payload: payload,
    );
  }

  // Native, DND-aware alarm (loud sound, or pulse vibration in Do Not Disturb),
  // plus the native reminder notification on Android.
  await fireAlarm(
    l10n.ttsRemember,
    title: l10n.notifParkingTitle,
    body: l10n.notifParkingBody,
  );
}
