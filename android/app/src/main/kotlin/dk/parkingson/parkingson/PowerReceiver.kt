package dk.parkingson.parkingson

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.BatteryManager

/**
 * Listens for USB *power* connect/disconnect — the low-trust fallback for cars
 * that only charge over USB (no wired Android Auto / AOA), so CarUsbReceiver
 * never fires.
 *
 * ACTION_POWER_CONNECTED/DISCONNECTED can't be declared in the manifest on
 * modern Android, so this is registered at runtime (the foreground service
 * keeps the process alive). It writes to FlutterSharedPreferences like the other
 * receivers; the Dart side treats a plain power drop as ambiguous and only fires
 * when there's independent driving evidence (see _shouldFire).
 *
 * The plug type is only readable while plugged in, so we record it on CONNECT
 * and gate the DISCONNECT event on having seen a USB connect.
 */
class PowerReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val appContext = context.applicationContext
        // A power event is an FGS-start exemption window — revive monitoring if killed.
        ServiceStarter.ensureRunning(appContext)

        val prefs = appContext.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
        val now = System.currentTimeMillis()

        when (intent.action) {
            Intent.ACTION_POWER_CONNECTED ->
                if (isUsbPlugged(appContext)) {
                    prefs.edit().putString("flutter.usbpower_last_connect", "usb|$now").apply()
                }
            Intent.ACTION_POWER_DISCONNECTED ->
                // Only meaningful if the last connect was USB (not AC/wireless).
                if (prefs.getString("flutter.usbpower_last_connect", null) != null) {
                    prefs.edit().putString("flutter.usbpower_last_disconnect", "usb|$now").apply()
                }
        }
    }

    private fun isUsbPlugged(context: Context): Boolean {
        val status = context.registerReceiver(null, IntentFilter(Intent.ACTION_BATTERY_CHANGED))
        return (status?.getIntExtra(BatteryManager.EXTRA_PLUGGED, -1) ?: -1) ==
            BatteryManager.BATTERY_PLUGGED_USB
    }
}
