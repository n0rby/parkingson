package dk.parkingson.parkingson

import android.app.NotificationManager
import android.content.Context
import android.media.AudioAttributes
import android.media.AudioFocusRequest
import android.media.AudioManager
import android.media.MediaPlayer
import android.media.RingtoneManager
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
        if (isDndActive(context)) {
            // Silent alert; the voice is spoken when the app is opened.
            startPulseVibration(context)
        } else {
            // Take the pending voice now (and clear it) so opening the app
            // later won't speak it a second time.
            val voice = takePendingVoice(context)
            playAlarmSound(context)
            if (voice != null) {
                val appContext = context.applicationContext
                Handler(Looper.getMainLooper()).postDelayed({
                    Speaker.speak(appContext, voice, Locale.getDefault().toLanguageTag())
                }, 3300)
            }
        }
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

    private fun playAlarmSound(context: Context) {
        val uri = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_ALARM)
            ?: RingtoneManager.getDefaultUri(RingtoneManager.TYPE_NOTIFICATION)
        val audioManager = context.getSystemService(AudioManager::class.java)
        val handler = Handler(Looper.getMainLooper())

        // Force alarm stream to full volume so it isn't faded in / muted.
        val maxVol = audioManager.getStreamMaxVolume(AudioManager.STREAM_ALARM)
        audioManager.setStreamVolume(AudioManager.STREAM_ALARM, maxVol, 0)

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
                }, 3000)
            }
            mp.setOnErrorListener { p, _, _ -> p.release(); true }
            mp.prepareAsync()
        } catch (_: Exception) {
        }
    }
}
