package dk.parkingson.parkingson

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import com.google.android.gms.location.ActivityRecognitionResult
import com.google.android.gms.location.ActivityTransitionResult
import com.google.android.gms.location.DetectedActivity

/**
 * Receives Activity Recognition events (Play Services) and runs the
 * drive-then-walk detection state machine — ported from husk-parkering.
 *
 * On a confirmed park (was in a vehicle >= 20s, now on foot), it writes a
 * parking event to the shared FlutterSharedPreferences. The Dart background
 * isolate picks it up and runs the same handling as Bluetooth detection
 * (GPS + ignored-location check + notification/alarm).
 */
class ActivityRecognitionReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val appContext = context.applicationContext
        when {
            intent.action == ACTION_ACTIVITY_TRANSITION && ActivityTransitionResult.hasResult(intent) -> {
                val result = ActivityTransitionResult.extractResult(intent) ?: return
                result.transitionEvents.forEach {
                    recordActivity(appContext, it.activityType, -1)
                    handleActivity(appContext, it.activityType)
                }
            }
            intent.action == ACTION_ACTIVITY_UPDATE && ActivityRecognitionResult.hasResult(intent) -> {
                val result = ActivityRecognitionResult.extractResult(intent) ?: return
                result.probableActivities
                    .filter { it.confidence >= MIN_ACTIVITY_CONFIDENCE }
                    .maxByOrNull { it.confidence }
                    ?.let {
                        recordActivity(appContext, it.type, it.confidence)
                        handleActivity(appContext, it.type)
                    }
            }
        }
    }

    private fun handleActivity(context: Context, activityType: Int) {
        val prefs = context.getSharedPreferences(MOTION_PREFS, Context.MODE_PRIVATE)
        val now = System.currentTimeMillis()

        if (activityType == DetectedActivity.IN_VEHICLE) {
            if (prefs.getLong(KEY_IN_VEHICLE_STARTED_AT, 0L) == 0L) {
                prefs.edit().putLong(KEY_IN_VEHICLE_STARTED_AT, now).apply()
            }
            return
        }

        if (!isOnFoot(activityType)) return

        val vehicleStartedAt = prefs.getLong(KEY_IN_VEHICLE_STARTED_AT, 0L)
        val lastReminderAt = prefs.getLong(KEY_LAST_REMINDER_AT, 0L)
        val wasInVehicleLongEnough = vehicleStartedAt > 0L && now - vehicleStartedAt >= MIN_VEHICLE_DURATION_MS
        val isPastCooldown = now - lastReminderAt >= MOTION_COOLDOWN_MS
        if (!wasInVehicleLongEnough || !isPastCooldown) return

        prefs.edit()
            .remove(KEY_IN_VEHICLE_STARTED_AT)
            .putLong(KEY_LAST_REMINDER_AT, now)
            .apply()

        // Bridge to the Dart background isolate (same pipeline as BT detection).
        context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
            .edit()
            .putString("flutter.motion_parking_event", now.toString())
            .apply()
    }

    private fun isOnFoot(type: Int): Boolean {
        return type == DetectedActivity.ON_FOOT ||
            type == DetectedActivity.WALKING ||
            type == DetectedActivity.RUNNING
    }
}
