package dk.parkingson.parkingson

import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Intent
import android.content.pm.PackageManager
import android.media.RingtoneManager
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.os.PowerManager
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private var pendingSoundResult: MethodChannel.Result? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        createNotificationChannels()
    }

    override fun onResume() {
        super.onResume()
        // Opening the app (from icon, recents or the notification) stops any
        // ongoing DND alarm vibration.
        AlarmPlayer.stopVibration(this)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "dk.parkingson/alarm")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "playAlarm" -> {
                        AlarmPlayer.trigger(this)
                        result.success(null)
                    }
                    "stopAlarmVibration" -> {
                        AlarmPlayer.stopVibration(this)
                        result.success(null)
                    }
                    "speak" -> {
                        Speaker.speak(
                            this,
                            call.argument<String>("text") ?: "",
                            call.argument<String>("lang") ?: "en"
                        )
                        result.success(null)
                    }
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
                    "getInstalledApps" -> result.success(installedLaunchableApps())
                    "getAlarmSoundTitle" -> result.success(currentAlarmSoundTitle())
                    "pickAlarmSound" -> {
                        pendingSoundResult = result
                        launchAlarmPicker(call.argument<String>("title"))
                    }
                    "isIgnoringBatteryOptimizations" -> {
                        val pm = getSystemService(PowerManager::class.java)
                        result.success(pm.isIgnoringBatteryOptimizations(packageName))
                    }
                    "requestIgnoreBatteryOptimizations" -> {
                        try {
                            startActivity(
                                Intent(Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS)
                                    .setData(Uri.parse("package:$packageName"))
                            )
                        } catch (_: Exception) {
                            try {
                                startActivity(Intent(Settings.ACTION_IGNORE_BATTERY_OPTIMIZATION_SETTINGS))
                            } catch (_: Exception) {}
                        }
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    // ── Installed apps (for the parking-app picker) ─────────────────────────
    private fun installedLaunchableApps(): List<Map<String, String>> {
        val pm = packageManager
        val intent = Intent(Intent.ACTION_MAIN).addCategory(Intent.CATEGORY_LAUNCHER)
        val resolveInfos = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            pm.queryIntentActivities(intent, PackageManager.ResolveInfoFlags.of(0))
        } else {
            @Suppress("DEPRECATION")
            pm.queryIntentActivities(intent, 0)
        }
        return resolveInfos
            .mapNotNull { info ->
                val pkg = info.activityInfo?.packageName ?: return@mapNotNull null
                if (pkg == packageName) return@mapNotNull null
                mapOf("package" to pkg, "label" to info.loadLabel(pm).toString())
            }
            .distinctBy { it["package"] }
            .sortedBy { (it["label"] ?: "").lowercase() }
    }

    // ── Alarm sound picker ──────────────────────────────────────────────────
    private val ringtonePickRequest = 5001

    private fun currentAlarmSoundUri(): Uri? {
        val saved = getSharedPreferences("FlutterSharedPreferences", MODE_PRIVATE)
            .getString("flutter.alarm_sound_uri", null)
        return if (saved != null) Uri.parse(saved)
        else RingtoneManager.getDefaultUri(RingtoneManager.TYPE_ALARM)
    }

    private fun currentAlarmSoundTitle(): String {
        return try {
            RingtoneManager.getRingtone(this, currentAlarmSoundUri())?.getTitle(this) ?: ""
        } catch (_: Exception) {
            ""
        }
    }

    private fun launchAlarmPicker(title: String?) {
        val intent = Intent(RingtoneManager.ACTION_RINGTONE_PICKER).apply {
            putExtra(RingtoneManager.EXTRA_RINGTONE_TYPE, RingtoneManager.TYPE_ALARM)
            putExtra(RingtoneManager.EXTRA_RINGTONE_SHOW_DEFAULT, true)
            putExtra(RingtoneManager.EXTRA_RINGTONE_SHOW_SILENT, false)
            putExtra(RingtoneManager.EXTRA_RINGTONE_EXISTING_URI, currentAlarmSoundUri())
            if (title != null) putExtra(RingtoneManager.EXTRA_RINGTONE_TITLE, title)
        }
        try {
            startActivityForResult(intent, ringtonePickRequest)
        } catch (_: Exception) {
            pendingSoundResult?.success(null)
            pendingSoundResult = null
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode != ringtonePickRequest) return
        if (resultCode == RESULT_OK) {
            val uri: Uri? = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                data?.getParcelableExtra(RingtoneManager.EXTRA_RINGTONE_PICKED_URI, Uri::class.java)
            } else {
                @Suppress("DEPRECATION")
                data?.getParcelableExtra(RingtoneManager.EXTRA_RINGTONE_PICKED_URI)
            }
            val prefs = getSharedPreferences("FlutterSharedPreferences", MODE_PRIVATE)
            if (uri != null) {
                prefs.edit().putString("flutter.alarm_sound_uri", uri.toString()).apply()
            } else {
                prefs.edit().remove("flutter.alarm_sound_uri").apply()
            }
            val title = try {
                RingtoneManager.getRingtone(this, uri ?: currentAlarmSoundUri())?.getTitle(this) ?: ""
            } catch (_: Exception) {
                ""
            }
            pendingSoundResult?.success(title)
        } else {
            pendingSoundResult?.success(null)
        }
        pendingSoundResult = null
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
