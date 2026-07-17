package dk.parkingson.parkingson

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

/**
 * Lets the Dart background isolate trigger the DND-aware alarm by sending a
 * broadcast (via android_intent_plus). Runs headless, so it works even when no
 * activity is alive.
 *
 * Two actions:
 * - `PLAY_ALARM` (from Dart): post the reminder notification (with a swipe-away
 *   deleteIntent) and fire the alarm/vibration/voice.
 * - `STOP_ALARM` (from the notification's deleteIntent / swipe-away): stop the
 *   alarm, vibration and spoken reminder, and clear the notification.
 */
class AlarmReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val ctx = context.applicationContext

        if (intent.action == ReminderNotification.ACTION_STOP) {
            AlarmPlayer.stop(ctx)
            ReminderNotification.cancel(ctx)
            return
        }

        val title = intent.getStringExtra("title")
        val body = intent.getStringExtra("body")
        if (title != null && body != null) {
            ReminderNotification.show(ctx, title, body)
        }
        AlarmPlayer.trigger(ctx)
    }
}
