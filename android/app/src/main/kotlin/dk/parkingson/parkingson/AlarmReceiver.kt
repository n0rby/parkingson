package dk.parkingson.parkingson

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

/**
 * Lets the Dart background isolate trigger the DND-aware alarm by sending a
 * broadcast (via android_intent_plus). Runs headless, so it works even when no
 * activity is alive.
 */
class AlarmReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        AlarmPlayer.trigger(context.applicationContext)
    }
}
