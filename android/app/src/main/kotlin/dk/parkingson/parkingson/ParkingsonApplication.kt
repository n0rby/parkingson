package dk.parkingson.parkingson

import android.app.Application
import android.bluetooth.BluetoothDevice
import android.content.Context
import android.content.IntentFilter
import android.os.Build

/**
 * Registers the classic-Bluetooth ACL receiver for the whole process lifetime.
 *
 * A context-registered receiver (as opposed to a manifest-declared one) reliably
 * receives the implicit ACL_CONNECTED/DISCONNECTED broadcasts in the background,
 * as long as the process is alive — which it is, because flutter_background_service
 * keeps a foreground service running.
 */
class ParkingsonApplication : Application() {
    private val receiver = CarBluetoothReceiver()

    override fun onCreate() {
        super.onCreate()
        val filter = IntentFilter().apply {
            addAction(BluetoothDevice.ACTION_ACL_CONNECTED)
            addAction(BluetoothDevice.ACTION_ACL_DISCONNECTED)
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            registerReceiver(receiver, filter, Context.RECEIVER_EXPORTED)
        } else {
            @Suppress("UnspecifiedRegisterReceiverFlag")
            registerReceiver(receiver, filter)
        }
    }
}
