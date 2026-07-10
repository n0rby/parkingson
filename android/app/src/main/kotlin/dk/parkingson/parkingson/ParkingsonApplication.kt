package dk.parkingson.parkingson

import android.app.Application
import android.bluetooth.BluetoothDevice
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.hardware.usb.UsbManager
import android.os.Build

/**
 * Registers the "left the car" broadcast receivers for the whole process
 * lifetime: classic-Bluetooth ACL, USB accessory (car head unit) and USB power.
 *
 * Context-registered receivers (as opposed to manifest-declared ones) reliably
 * receive these implicit/runtime-only broadcasts in the background, as long as
 * the process is alive — which it is, because flutter_background_service keeps a
 * foreground service running.
 */
class ParkingsonApplication : Application() {
    private val receiver = CarBluetoothReceiver()
    private val usbReceiver = CarUsbReceiver()
    private val powerReceiver = PowerReceiver()

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

        // USB accessory-mode (wired Android Auto / AOA car head unit).
        val usbFilter = IntentFilter().apply {
            addAction(UsbManager.ACTION_USB_ACCESSORY_ATTACHED)
            addAction(UsbManager.ACTION_USB_ACCESSORY_DETACHED)
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            registerReceiver(usbReceiver, usbFilter, Context.RECEIVER_EXPORTED)
        } else {
            @Suppress("UnspecifiedRegisterReceiverFlag")
            registerReceiver(usbReceiver, usbFilter)
        }

        // USB power (low-trust fallback for charge-only cars). POWER_* can't be
        // manifest-declared, so it must be context-registered.
        val powerFilter = IntentFilter().apply {
            addAction(Intent.ACTION_POWER_CONNECTED)
            addAction(Intent.ACTION_POWER_DISCONNECTED)
        }
        registerReceiver(powerReceiver, powerFilter)

        // Every process start (app launch, boot, a background broadcast that
        // spawned us) is a chance to revive monitoring after a reboot or after
        // the user swiped the app away / used "Clear all".
        val flutterPrefs = getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
        val setupDone = flutterPrefs.getBoolean("flutter.setup_completed", false)
        val btOnly = flutterPrefs.getBoolean("flutter.bt_only_mode", false)
        if (setupDone && !btOnly) {
            startMotionMonitoring(this)
        }
        if (setupDone) {
            ServiceStarter.ensureRunning(this)
            ServiceStarter.scheduleWatchdog(this)
        }
    }
}
