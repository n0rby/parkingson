package dk.parkingson.parkingson

import android.app.NotificationManager
import android.content.Context
import android.media.AudioAttributes
import android.media.AudioFocusRequest
import android.media.AudioManager
import android.media.MediaPlayer
import android.media.RingtoneManager
import android.net.Uri
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.os.VibrationAttributes
import android.os.VibrationEffect
import android.os.Vibrator
import java.util.Locale

/**
 * Central alarm behaviour, callable from both the foreground (MethodChannel)
 * and the background (AlarmReceiver broadcast).
 *
 * - Not in Do Not Disturb: play a short, loud alarm sound on the alarm stream.
 * - In Do Not Disturb: pulse-vibrate for 30 seconds instead (until the user
 *   opens the app, which cancels it). The spoken reminder is handled in Dart
 *   when the app is opened.
 */
object AlarmPlayer {
    private var vibrator: Vibrator? = null
    private var savedAlarmVolume: Int? = null
    private val handler = Handler(Looper.getMainLooper())
    private var pendingSpeak: Runnable? = null
    private var currentPlayer: MediaPlayer? = null

    fun isDndActive(context: Context): Boolean {
        val nm = context.getSystemService(NotificationManager::class.java) ?: return false
        return when (nm.currentInterruptionFilter) {
            NotificationManager.INTERRUPTION_FILTER_PRIORITY,
            NotificationManager.INTERRUPTION_FILTER_NONE,
            NotificationManager.INTERRUPTION_FILTER_ALARMS -> true
            else -> false
        }
    }

    fun trigger(context: Context) {
        // Do Not Disturb: vibrate only (if enabled), no sound, no voice.
        if (isDndActive(context)) {
            takePendingVoice(context)
            if (prefBool(context, "flutter.vibrate_in_dnd", true)) {
                startPulseVibration(context)
            }
            return
        }

        // Effectively muted (app volume 0, or phone alarm volume 0): vibrate only
        // (if enabled), no sound, no voice.
        val am = context.getSystemService(AudioManager::class.java)
        if (isAlarmMuted(context, am)) {
            takePendingVoice(context)
            if (prefBool(context, "flutter.vibrate_when_silent", true)) {
                startPulseVibration(context)
            }
            return
        }

        // Normal: apply the chosen volume, play the loud alarm, then speak.
        val appContext = context.applicationContext
        applyAlarmVolume(context)
        val voice = takePendingVoice(context)
        playAlarmSound(context)
        if (voice != null) {
            val r = Runnable {
                Speaker.speak(appContext, voice, Locale.getDefault().toLanguageTag())
                pendingSpeak = null
            }
            pendingSpeak = r
            handler.postDelayed(r, 3300)
        }
        // Restore the original system alarm volume after the alarm + voice.
        handler.postDelayed({ restoreAlarmVolume(appContext) }, 12000)
    }

    /**
     * Stops everything the alarm started — the sound, the queued/ongoing spoken
     * reminder, and vibration. Called when the app opens the reminder screen so
     * the announcement isn't captured by the voice recognizer.
     */
    fun stop(context: Context) {
        pendingSpeak?.let { handler.removeCallbacks(it) }
        pendingSpeak = null
        Speaker.stop()
        try {
            currentPlayer?.let {
                if (it.isPlaying) it.stop()
                it.release()
            }
        } catch (_: Exception) {
        }
        currentPlayer = null
        stopVibration(context)
    }

    /**
     * In app-volume mode, "muted" means the chosen app volume is 0 (checked
     * directly, since some devices clamp the alarm stream above 0). In
     * phone-volume mode, it means the phone's alarm volume is 0.
     */
    private fun isAlarmMuted(context: Context, am: AudioManager?): Boolean {
        val prefs = context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
        if (prefs.getString("flutter.sound_mode", "phone") == "app") {
            return prefs.getLong("flutter.app_volume", 100L).toInt() <= 0
        }
        if (am == null) return true
        // Phone mode: respect the phone being silenced (silent or vibrate ringer
        // mode), or the alarm volume being 0.
        if (am.ringerMode != AudioManager.RINGER_MODE_NORMAL) return true
        return am.getStreamVolume(AudioManager.STREAM_ALARM) == 0
    }

    private fun prefBool(context: Context, key: String, default: Boolean): Boolean {
        return context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
            .getBoolean(key, default)
    }

    /** Reads and clears the pending alarm voice text (if set within 5 minutes). */
    private fun takePendingVoice(context: Context): String? {
        val prefs = context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
        val raw = prefs.getString("flutter.pending_alarm_voice", null) ?: return null
        prefs.edit().remove("flutter.pending_alarm_voice").apply()
        val sep = raw.indexOf('|')
        if (sep < 0) return null
        val ts = raw.substring(0, sep).toLongOrNull() ?: return null
        if (System.currentTimeMillis() - ts > 5 * 60 * 1000) return null
        val text = raw.substring(sep + 1)
        return text.ifBlank { null }
    }

    private fun startPulseVibration(context: Context) {
        val v = context.getSystemService(Vibrator::class.java) ?: return
        stopVibration(context)
        vibrator = v

        // ~30 seconds of pulses: 600 ms on, 400 ms off.
        val cycles = 30
        val timings = ArrayList<Long>().apply {
            add(0L)
            repeat(cycles) { add(600L); add(400L) }
        }.toLongArray()

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val amplitudes = ArrayList<Int>().apply {
                add(0)
                repeat(cycles) { add(255); add(0) }
            }.toIntArray()
            val effect = VibrationEffect.createWaveform(timings, amplitudes, -1)
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                val attrs = VibrationAttributes.Builder()
                    .setUsage(VibrationAttributes.USAGE_ALARM)
                    .build()
                v.vibrate(effect, attrs)
            } else {
                v.vibrate(effect)
            }
        } else {
            @Suppress("DEPRECATION")
            v.vibrate(timings, -1)
        }

        // Safety stop after 30 seconds even if the app is never opened.
        val appContext = context.applicationContext
        Handler(Looper.getMainLooper()).postDelayed({ stopVibration(appContext) }, 30_000)
    }

    /**
     * Applies the user's sound preference to the alarm stream.
     * - "app" (default): force the alarm stream to the app's chosen volume,
     *   ignoring the phone's setting (previous always-max behaviour at 100%).
     * - "phone": leave the phone's alarm volume untouched.
     */
    fun applyAlarmVolume(context: Context) {
        val prefs = context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
        val mode = prefs.getString("flutter.sound_mode", "phone")
        if (mode != "app") return
        // Flutter stores ints as Long in SharedPreferences.
        val percent = prefs.getLong("flutter.app_volume", 100L).toInt().coerceIn(0, 100)
        val am = context.getSystemService(AudioManager::class.java) ?: return
        val max = am.getStreamMaxVolume(AudioManager.STREAM_ALARM)
        val target = Math.round(percent / 100.0 * max).toInt().coerceIn(0, max)
        // Remember the original so we can restore it — don't permanently change
        // the system alarm volume (which also affects the user's alarm clock).
        if (savedAlarmVolume == null) {
            savedAlarmVolume = am.getStreamVolume(AudioManager.STREAM_ALARM)
        }
        try {
            am.setStreamVolume(AudioManager.STREAM_ALARM, target, 0)
        } catch (_: Exception) {
        }
    }

    /** Restores the system alarm volume changed by [applyAlarmVolume]. */
    fun restoreAlarmVolume(context: Context) {
        val saved = savedAlarmVolume ?: return
        savedAlarmVolume = null
        val am = context.getSystemService(AudioManager::class.java) ?: return
        try {
            am.setStreamVolume(AudioManager.STREAM_ALARM, saved, 0)
        } catch (_: Exception) {
        }
    }

    fun stopVibration(context: Context) {
        // Cancel via a fresh system Vibrator so it works no matter which context
        // started it (e.g. a background receiver vs. the activity).
        try {
            context.getSystemService(Vibrator::class.java)?.cancel()
        } catch (_: Exception) {
        }
        try {
            vibrator?.cancel()
        } catch (_: Exception) {
        }
        vibrator = null
    }

    private fun chosenAlarmUri(context: Context): Uri? {
        val saved = context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
            .getString("flutter.alarm_sound_uri", null) ?: return null
        return try {
            Uri.parse(saved)
        } catch (_: Exception) {
            null
        }
    }

    private fun playAlarmSound(context: Context) {
        val uri = chosenAlarmUri(context)
            ?: RingtoneManager.getDefaultUri(RingtoneManager.TYPE_ALARM)
            ?: RingtoneManager.getDefaultUri(RingtoneManager.TYPE_NOTIFICATION)
        val audioManager = context.getSystemService(AudioManager::class.java)

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            audioManager.requestAudioFocus(
                AudioFocusRequest.Builder(AudioManager.AUDIOFOCUS_GAIN_TRANSIENT_EXCLUSIVE)
                    .setAudioAttributes(
                        AudioAttributes.Builder()
                            .setUsage(AudioAttributes.USAGE_ALARM)
                            .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                            .build()
                    )
                    .build()
            )
        }

        try {
            val mp = MediaPlayer()
            currentPlayer = mp
            mp.setAudioAttributes(
                AudioAttributes.Builder()
                    .setUsage(AudioAttributes.USAGE_ALARM)
                    .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                    .build()
            )
            mp.setVolume(1.0f, 1.0f)
            mp.setDataSource(context.applicationContext, uri)
            mp.setOnPreparedListener { player ->
                player.setVolume(1.0f, 1.0f)
                player.start()
                handler.postDelayed({
                    try { if (player.isPlaying) player.stop() } catch (_: Exception) {}
                    player.release()
                    if (currentPlayer === player) currentPlayer = null
                }, 3000)
            }
            mp.setOnErrorListener { p, _, _ ->
                p.release()
                if (currentPlayer === p) currentPlayer = null
                true
            }
            mp.prepareAsync()
        } catch (_: Exception) {
        }
    }
}
