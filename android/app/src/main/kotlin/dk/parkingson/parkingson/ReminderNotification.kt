package dk.parkingson.parkingson

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build

/**
 * The parking-reminder notification, posted natively (on Android) so we can
 * catch the user swiping it away: [ACTION_STOP] via the notification's
 * deleteIntent stops the alarm, vibration and spoken reminder.
 *
 * This lives here rather than in Dart because flutter_local_notifications
 * cannot set a deleteIntent, so a swipe-away would otherwise leave the native
 * pulse vibration running until its 30 s safety stop.
 *
 * Uses the framework [Notification.Builder] (not androidx) to avoid depending on
 * a transitive support library from a background receiver.
 */
object ReminderNotification {
    const val ACTION_STOP = "dk.parkingson.parkingson.STOP_ALARM"
    private const val CHANNEL_ID = "parking_visual"
    private const val NOTIF_ID = 1

    /** Auto-dismiss after 20 s, matching the previous Flutter notification. */
    private const val TIMEOUT_MS = 20_000L

    fun ensureChannel(context: Context) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return
        val nm = context.getSystemService(NotificationManager::class.java) ?: return
        if (nm.getNotificationChannel(CHANNEL_ID) != null) return
        val channel = NotificationChannel(
            CHANNEL_ID,
            "Parkeringspåmindelser",
            NotificationManager.IMPORTANCE_HIGH
        ).apply {
            description = "Viser parkeringspåmindelser"
            // Sound and vibration are handled by AlarmPlayer (which is DND- and
            // silent-aware), so the notification itself stays silent — otherwise
            // it would double up.
            setSound(null, null)
            enableVibration(false)
        }
        nm.createNotificationChannel(channel)
    }

    fun show(context: Context, title: String, body: String) {
        ensureChannel(context)
        val nm = context.getSystemService(NotificationManager::class.java) ?: return

        val open = activityPendingIntent(context)
        val stop = stopPendingIntent(context)

        val builder = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            Notification.Builder(context, CHANNEL_ID)
        } else {
            @Suppress("DEPRECATION")
            Notification.Builder(context)
                .setPriority(Notification.PRIORITY_HIGH)
                .setDefaults(0)
                .setSound(null)
                .setVibrate(null)
        }

        builder
            .setSmallIcon(context.applicationInfo.icon)
            .setContentTitle(title)
            .setContentText(body)
            .setCategory(Notification.CATEGORY_ALARM)
            .setAutoCancel(true)
            .setContentIntent(open)
            // Launch the reminder full-screen over the lock screen.
            .setFullScreenIntent(open, true)
            // Swiping the notification away means "I'm done" — stop the alarm,
            // vibration and spoken reminder.
            .setDeleteIntent(stop)

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            builder.setTimeoutAfter(TIMEOUT_MS)
        }

        try {
            nm.notify(NOTIF_ID, builder.build())
        } catch (_: Exception) {
            // e.g. POST_NOTIFICATIONS not granted — nothing to show.
        }
    }

    fun cancel(context: Context) {
        try {
            context.getSystemService(NotificationManager::class.java)?.cancel(NOTIF_ID)
        } catch (_: Exception) {
        }
    }

    private fun activityPendingIntent(context: Context): PendingIntent {
        val intent = Intent(context, MainActivity::class.java).apply {
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP)
        }
        return PendingIntent.getActivity(context, 6001, intent, pendingIntentFlags())
    }

    private fun stopPendingIntent(context: Context): PendingIntent {
        val intent = Intent(context, AlarmReceiver::class.java).setAction(ACTION_STOP)
        return PendingIntent.getBroadcast(context, 6002, intent, pendingIntentFlags())
    }

    private fun pendingIntentFlags(): Int {
        // minSdk is 24, so FLAG_IMMUTABLE (API 23+) is always available.
        return PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
    }
}
