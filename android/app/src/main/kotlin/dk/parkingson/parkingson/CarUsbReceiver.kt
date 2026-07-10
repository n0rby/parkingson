package dk.parkingson.parkingson

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.hardware.usb.UsbAccessory
import android.hardware.usb.UsbManager
import android.os.Build

/**
 * Listens for USB *accessory-mode* attach/detach, which is how a car head unit
 * (wired Android Auto / an AOA accessory) appears when the phone is cabled to
 * the car's computer: the phone becomes the USB accessory and the head unit is
 * the host.
 *
 * Mirrors CarBluetoothReceiver — events are written to FlutterSharedPreferences
 * so the Dart background isolate runs the same parking-detection pipeline.
 *
 * Caveat: standard wired Android Auto identifies generically (manufacturer
 * "Android", model "Android Auto"), so the recorded id marks "a car head unit"
 * but does not tell two cars apart. Fine for a single car; the ignored-location
 * check still guards against false alarms (e.g. an accessory used at home).
 */
class CarUsbReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val appContext = context.applicationContext
        // A USB event is an FGS-start exemption window — revive monitoring if killed.
        ServiceStarter.ensureRunning(appContext)

        val prefs = appContext.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
        val now = System.currentTimeMillis()
        val fromIntent = accessoryId(usbAccessory(intent))

        when (intent.action) {
            UsbManager.ACTION_USB_ACCESSORY_ATTACHED -> {
                val id = fromIntent ?: return
                prefs.edit()
                    .putString("flutter.usb_last_connect", "$id|$now")
                    .putString("flutter.usb_last_accessory", id) // detach fallback + setup
                    .apply()
            }
            UsbManager.ACTION_USB_ACCESSORY_DETACHED -> {
                // DETACHED omits the accessory extra on some devices — fall back
                // to the id we cached on the matching attach.
                val id = fromIntent
                    ?: prefs.getString("flutter.usb_last_accessory", null)
                    ?: return
                prefs.edit().putString("flutter.usb_last_disconnect", "$id|$now").apply()
            }
        }
    }

    private fun usbAccessory(intent: Intent): UsbAccessory? =
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            intent.getParcelableExtra(UsbManager.EXTRA_ACCESSORY, UsbAccessory::class.java)
        } else {
            @Suppress("DEPRECATION")
            intent.getParcelableExtra(UsbManager.EXTRA_ACCESSORY)
        }

    /** "manufacturer/model", '|'-free so the Dart "id|timestamp" parser is safe. */
    private fun accessoryId(accessory: UsbAccessory?): String? {
        if (accessory == null) return null
        val mfr = accessory.manufacturer?.trim().orEmpty()
        val model = accessory.model?.trim().orEmpty()
        return "$mfr/$model".replace("|", " ").trim('/').ifBlank { null }
    }
}
