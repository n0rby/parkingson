package dk.parkingson.parkingson

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build

/**
 * Keeps the background monitoring service alive after reboots and after the
 * user swipes the app away / uses "Clear all".
 *
 * Honest caveat: on Android 12+ a foreground service can only be *started* from
 * the background inside an exemption window (boot, an activity-recognition or
 * Bluetooth event, an exact alarm, ...). So [ensureRunning] is wrapped in a
 * try/catch — outside such a window the start is simply skipped and retried on
 * the next motion/Bluetooth event or watchdog tick, instead of crashing.
 */
object ServiceStarter {
    private const val WATCHDOG_REQUEST = 4001
    private const val WATCHDOG_ACTION = "dk.parkingson.parkingson.WATCHDOG"
    private const val WATCHDOG_INTERVAL_MS = 15L * 60L * 1000L

    fun ensureRunning(context: Context) {
        val prefs = context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
        if (!prefs.getBoolean("flutter.setup_completed", false)) return
        try {
            val intent = Intent(
                context,
                id.flutter.flutter_background_service.BackgroundService::class.java
            )
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                context.startForegroundService(intent)
            } else {
                context.startService(intent)
            }
        } catch (_: Exception) {
            // Not in an FGS-start exemption window — retried on the next event.
        }
    }

    /** Schedules a repeating ~15 min watchdog that re-checks the service. */
    fun scheduleWatchdog(context: Context) {
        val am = context.getSystemService(AlarmManager::class.java) ?: return
        val intent = Intent(context, WatchdogReceiver::class.java).apply {
            action = WATCHDOG_ACTION
        }
        var flags = PendingIntent.FLAG_UPDATE_CURRENT
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            flags = flags or PendingIntent.FLAG_IMMUTABLE
        }
        val pending = PendingIntent.getBroadcast(context, WATCHDOG_REQUEST, intent, flags)
        am.setInexactRepeating(
            AlarmManager.RTC,
            System.currentTimeMillis() + WATCHDOG_INTERVAL_MS,
            WATCHDOG_INTERVAL_MS,
            pending
        )
    }
}
