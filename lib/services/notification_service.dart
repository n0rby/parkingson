import 'dart:io';
import 'dart:ui';
import 'package:android_intent_plus/android_intent.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_tts/flutter_tts.dart';
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

/// BCP-47 language tag for TTS, matching the device locale.
String _ttsTag() => PlatformDispatcher.instance.locale.toLanguageTag();

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

// How long the reminder notification stays before Android auto-dismisses it.
const _reminderTimeoutMs = 60000;

const _pendingVoiceKey = 'pending_alarm_voice';

final _plugin = FlutterLocalNotificationsPlugin();

/// Triggers the native, DND-aware alarm (loud sound, or pulse vibration in Do
/// Not Disturb) and remembers the phrase to speak when the app is opened.
/// Works from both the foreground and the background isolate.
Future<void> fireAlarm(String voiceText) async {
  if (!Platform.isAndroid) return;
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(
    _pendingVoiceKey,
    '${DateTime.now().millisecondsSinceEpoch}|$voiceText',
  );
  final intent = AndroidIntent(
    action: 'dk.parkingson.parkingson.PLAY_ALARM',
    package: 'dk.parkingson.parkingson',
  );
  try {
    await intent.sendBroadcast();
  } catch (_) {}
}

/// Speaks (and clears) a pending alarm voice reminder, if one was set recently.
/// Called when the app is opened, and immediately for foreground alarms.
Future<void> speakPendingVoice({Duration delay = Duration.zero}) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.reload();
  final raw = prefs.getString(_pendingVoiceKey);
  if (raw == null) return;
  await prefs.remove(_pendingVoiceKey);
  final sep = raw.indexOf('|');
  if (sep < 0) return;
  final ts = int.tryParse(raw.substring(0, sep)) ?? 0;
  final text = raw.substring(sep + 1);
  // Ignore stale reminders (older than 5 minutes).
  if (DateTime.now().millisecondsSinceEpoch - ts > 5 * 60 * 1000) return;
  // Let the alarm sound finish first so the voice doesn't play over it.
  if (delay > Duration.zero) await Future.delayed(delay);
  if (Platform.isAndroid) {
    // Native TTS plays on the alarm stream (full alarm volume), matching the
    // alarm sound — flutter_tts can only use the quieter media stream.
    try {
      await const MethodChannel('dk.parkingson/alarm')
          .invokeMethod('speak', {'text': text, 'lang': _ttsTag()});
    } catch (_) {}
  } else {
    try {
      final tts = FlutterTts();
      await tts.setLanguage(_ttsTag());
      await tts.setVolume(1.0);
      await tts.setSpeechRate(0.5);
      await tts.speak(text);
    } catch (_) {}
  }
}

// Alarm sound lasts ~3s; wait a bit longer before speaking so they don't overlap.
const voiceAfterAlarmDelay = Duration(milliseconds: 3300);

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
    final l10n = _bgL10n();
    const androidDetails = AndroidNotificationDetails(
      _visualChannelId,
      _visualChannelName,
      importance: Importance.high,
      priority: Priority.high,
      playSound: false,
      enableVibration: false,
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
  final android = _plugin
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
  await android?.createNotificationChannel(_visualChannel);

  await _plugin.show(
    2,
    l10n.notifWalkBackTitle,
    l10n.notifWalkBackBody(walkMinutes),
    const NotificationDetails(
      android: AndroidNotificationDetails(
        _visualChannelId, _visualChannelName,
        importance: Importance.high,
        priority: Priority.high,
        category: AndroidNotificationCategory.alarm,
        playSound: false,
        enableVibration: false,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentSound: true,
        interruptionLevel: InterruptionLevel.timeSensitive,
      ),
    ),
  );

  // Native, DND-aware alarm (loud sound, or pulse vibration in Do Not Disturb).
  await fireAlarm(l10n.notifWalkBackTitle);
}

Future<void> showParkingReminderFromBackground({String? payload}) async {
  final l10n = _bgL10n();
  await _plugin.initialize(
    const InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    ),
  );
  final android = _plugin
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
  await android?.createNotificationChannel(_visualChannel);

  await _plugin.show(
    _reminderNotificationId,
    l10n.notifParkingTitle,
    l10n.notifParkingBody,
    const NotificationDetails(
      android: AndroidNotificationDetails(
        _visualChannelId, _visualChannelName,
        importance: Importance.high,
        priority: Priority.high,
        playSound: false,
        enableVibration: false,
        timeoutAfter: _reminderTimeoutMs,
      ),
      iOS: DarwinNotificationDetails(presentAlert: true, presentSound: true),
    ),
    payload: payload,
  );

  // Native, DND-aware alarm (loud sound, or pulse vibration in Do Not Disturb).
  await fireAlarm(l10n.ttsRemember);
}
