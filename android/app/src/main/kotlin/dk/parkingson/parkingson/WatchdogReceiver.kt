package dk.parkingson.parkingson

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

/**
 * Fires every ~15 minutes (scheduled via ServiceStarter.scheduleWatchdog) and
 * makes sure the background monitoring service is running.
 */
class WatchdogReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        ServiceStarter.ensureRunning(context.applicationContext)
    }
}
