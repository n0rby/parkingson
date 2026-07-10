package dk.parkingson.parkingson

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

/**
 * Fires every ~15 minutes (scheduled via ServiceStarter.scheduleWatchdog) and
 * makes sure the background monitoring service is running. Because it fires from
 * an *exact* alarm, its onReceive runs inside a valid FGS-start window, so it can
 * revive the service even after the app was swiped away.
 */
class WatchdogReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val appContext = context.applicationContext
        ServiceStarter.ensureRunning(appContext)
        // Exact alarms are one-shot — chain the next tick from inside this
        // (exempt) firing window so the watchdog keeps supervising.
        ServiceStarter.scheduleWatchdog(appContext)
    }
}
