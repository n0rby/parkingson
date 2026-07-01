package dk.parkingson.parkingson

import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Intent
import android.media.AudioAttributes
import android.media.AudioFocusRequest
import android.media.AudioManager
import android.media.MediaPlayer
import android.media.RingtoneManager
import android.os.Build
import android.os.Bundle
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        createNotificationChannels()
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "dk.parkingson/alarm")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "playAlarm" -> playAlarmOnce(result)
                    "openBluetoothSettings" -> {
                        startActivity(Intent(Settings.ACTION_BLUETOOTH_SETTINGS))
                        result.success(null)
                    }
                    "startMotionDetection" -> {
                        startMotionMonitoring(this)
                        result.success(null)
                    }
                    "stopMotionDetection" -> {
                        stopMotionMonitoring(this)
                        result.success(null)
                    }
                    "getMotionStatus" -> result.success(readMotionStatus(this))
                    else -> result.notImplemented()
                }
            }
    }

    private fun playAlarmOnce(result: MethodChannel.Result) {
        val uri = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_ALARM)
            ?: RingtoneManager.getDefaultUri(RingtoneManager.TYPE_NOTIFICATION)
        val audioManager = getSystemService(AudioManager::class.java)
        val handler = android.os.Handler(android.os.Looper.getMainLooper())

        // Force alarm stream to full volume — prevents Samsung fade-in
        val maxVol = audioManager.getStreamMaxVolume(AudioManager.STREAM_ALARM)
        audioManager.setStreamVolume(AudioManager.STREAM_ALARM, maxVol, 0)

        // Request exclusive audio focus so nothing ducks us
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
            mp.setDataSource(applicationContext, uri)
            mp.setOnPreparedListener { player ->
                player.setVolume(1.0f, 1.0f)
                player.start()
                handler.postDelayed({
                    try { if (player.isPlaying) player.stop() } catch (_: Exception) {}
                    player.release()
                    result.success(null)
                }, 3000)
            }
            mp.setOnErrorListener { mp, _, _ -> mp.release(); result.success(null); true }
            mp.prepareAsync()
        } catch (e: Exception) {
            result.success(null)
        }
    }

    private fun createNotificationChannels() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val manager = getSystemService(NotificationManager::class.java)

            manager.createNotificationChannel(
                NotificationChannel(
                    "parkingson_monitoring",
                    "Parkeringsovervågning",
                    NotificationManager.IMPORTANCE_LOW
                ).apply {
                    description = "Viser at appen overvåger din bil i baggrunden"
                }
            )

            manager.createNotificationChannel(
                NotificationChannel(
                    "parking_reminder",
                    "Parkeringspåmindelser",
                    NotificationManager.IMPORTANCE_HIGH
                )
            )
        }
    }
}
