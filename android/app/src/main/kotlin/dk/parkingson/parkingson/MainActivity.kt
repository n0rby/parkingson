package dk.parkingson.parkingson

import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.os.PowerManager
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        createNotificationChannels()
    }

    override fun onResume() {
        super.onResume()
        // Opening the app stops any ongoing DND alarm vibration.
        AlarmPlayer.stopVibration()
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
                        AlarmPlayer.stopVibration()
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
