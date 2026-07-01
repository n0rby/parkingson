package dk.parkingson.parkingson

import android.bluetooth.BluetoothDevice
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build

/**
 * Listens for CLASSIC Bluetooth connect/disconnect events (ACL), which is how a
 * car stereo connects — unlike BLE (flutter_blue_plus), which never fires for a car.
 *
 * The events are written to the shared FlutterSharedPreferences store so the Dart
 * background isolate can pick them up and run the parking-detection logic.
 */
class CarBluetoothReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val device: BluetoothDevice? = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            intent.getParcelableExtra(BluetoothDevice.EXTRA_DEVICE, BluetoothDevice::class.java)
        } else {
            @Suppress("DEPRECATION")
            intent.getParcelableExtra(BluetoothDevice.EXTRA_DEVICE)
        }
        val address = device?.address ?: return

        val prefs = context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
        val now = System.currentTimeMillis()

        when (intent.action) {
            BluetoothDevice.ACTION_ACL_CONNECTED ->
                prefs.edit().putString("flutter.bt_last_connect", "$address|$now").apply()
            BluetoothDevice.ACTION_ACL_DISCONNECTED ->
                prefs.edit().putString("flutter.bt_last_disconnect", "$address|$now").apply()
        }
    }
}
