package dk.parkingson.parkingson

import android.app.KeyguardManager
import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Intent
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.drawable.BitmapDrawable
import android.media.RingtoneManager
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.os.PowerManager
import android.provider.Settings
import android.speech.RecognizerIntent
import android.view.WindowManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.ByteArrayOutputStream

class MainActivity : FlutterActivity() {
    private var pendingSoundResult: MethodChannel.Result? = null
    private var pendingVoiceResult: MethodChannel.Result? = null
    private val voiceCaptureRequest = 5002

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        createNotificationChannels()
        // Let the reminder appear on top of the lock screen and wake the screen
        // when the full-screen alarm launches us.
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1) {
            setShowWhenLocked(true)
            setTurnScreenOn(true)
        } else {
            @Suppress("DEPRECATION")
            window.addFlags(
                WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED or
                    WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON
            )
        }
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
                    "stopAlarm" -> {
                        AlarmPlayer.stop(this)
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
                    "launchApp" -> result.success(launchApp(call.argument<String>("package")))
                    "getAppIcon" -> result.success(appIconPng(call.argument<String>("package")))
                    "startVoiceCapture" -> {
                        pendingVoiceResult = result
                        launchVoiceCapture(call.argument<String>("locale"))
                    }
                    "isDeviceLocked" -> {
                        val km = getSystemService(KeyguardManager::class.java)
                        result.success(km?.isKeyguardLocked == true)
                    }
                    "requestUnlock" -> requestUnlock(result)
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

    // ── Lock screen: bring up the unlock prompt so voice can run ────────────
    private fun requestUnlock(result: MethodChannel.Result) {
        val km = getSystemService(KeyguardManager::class.java)
        if (km == null || !km.isKeyguardLocked) {
            result.success(true)
            return
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            km.requestDismissKeyguard(
                this,
                object : KeyguardManager.KeyguardDismissCallback() {
                    override fun onDismissSucceeded() = result.success(true)
                    override fun onDismissCancelled() = result.success(false)
                    override fun onDismissError() = result.success(false)
                }
            )
        } else {
            result.success(false)
        }
    }

    // ── Voice capture (system speech recognizer) ───────────────────────────
    // Uses the OS RecognizerIntent: a fresh recognition each time (no reused-
    // recognizer bug), and the system handles mic/Bluetooth routing itself.
    private fun launchVoiceCapture(locale: String?) {
        val intent = Intent(RecognizerIntent.ACTION_RECOGNIZE_SPEECH).apply {
            putExtra(RecognizerIntent.EXTRA_LANGUAGE_MODEL, RecognizerIntent.LANGUAGE_MODEL_FREE_FORM)
            putExtra(RecognizerIntent.EXTRA_PARTIAL_RESULTS, false)
            putExtra(RecognizerIntent.EXTRA_MAX_RESULTS, 5)
            if (locale != null) {
                putExtra(RecognizerIntent.EXTRA_LANGUAGE, locale)
                putExtra(RecognizerIntent.EXTRA_LANGUAGE_PREFERENCE, locale)
            }
        }
        try {
            startActivityForResult(intent, voiceCaptureRequest)
        } catch (_: Exception) {
            pendingVoiceResult?.success(null)
            pendingVoiceResult = null
        }
    }

    private fun launchApp(pkg: String?): Boolean {
        if (pkg.isNullOrEmpty()) return false
        val intent = packageManager.getLaunchIntentForPackage(pkg) ?: return false
        return try {
            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            startActivity(intent)
            true
        } catch (_: Exception) {
            false
        }
    }

    /** Returns the app's launcher icon as PNG bytes, or null if unavailable. */
    private fun appIconPng(pkg: String?): ByteArray? {
        if (pkg.isNullOrEmpty()) return null
        return try {
            val drawable = packageManager.getApplicationIcon(pkg)
            val bitmap = if (drawable is BitmapDrawable && drawable.bitmap != null) {
                drawable.bitmap
            } else {
                val size = (48 * resources.displayMetrics.density).toInt().coerceAtLeast(48)
                val w = drawable.intrinsicWidth.takeIf { it > 0 } ?: size
                val h = drawable.intrinsicHeight.takeIf { it > 0 } ?: size
                val bmp = Bitmap.createBitmap(w, h, Bitmap.Config.ARGB_8888)
                val canvas = Canvas(bmp)
                drawable.setBounds(0, 0, canvas.width, canvas.height)
                drawable.draw(canvas)
                bmp
            }
            ByteArrayOutputStream().use { stream ->
                bitmap.compress(Bitmap.CompressFormat.PNG, 100, stream)
                stream.toByteArray()
            }
        } catch (_: Exception) {
            null
        }
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
        if (requestCode == voiceCaptureRequest) {
            val texts = if (resultCode == RESULT_OK) {
                data?.getStringArrayListExtra(RecognizerIntent.EXTRA_RESULTS)
            } else null
            pendingVoiceResult?.success(texts?.toList() ?: emptyList<String>())
            pendingVoiceResult = null
            return
        }
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
