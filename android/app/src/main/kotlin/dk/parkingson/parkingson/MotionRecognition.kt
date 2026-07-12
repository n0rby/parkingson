package dk.parkingson.parkingson

import android.Manifest
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import com.google.android.gms.location.ActivityRecognition
import com.google.android.gms.location.ActivityTransition
import com.google.android.gms.location.ActivityTransitionRequest
import com.google.android.gms.location.DetectedActivity

// Ported from husk-parkering's ActivityRecognitionMonitor.
const val ACTION_ACTIVITY_TRANSITION = "dk.parkingson.parkingson.ACTIVITY_TRANSITION"
const val ACTION_ACTIVITY_UPDATE = "dk.parkingson.parkingson.ACTIVITY_UPDATE"

const val MOTION_PREFS = "motion_state"
const val KEY_IN_VEHICLE_STARTED_AT = "in_vehicle_started_at"
const val KEY_LAST_IN_VEHICLE_AT = "last_in_vehicle_at"
const val KEY_LAST_REMINDER_AT = "last_reminder_at"
const val KEY_REGISTERED = "registered"
const val KEY_LAST_ERROR = "last_error"
const val KEY_LAST_ACTIVITY_TYPE = "last_activity_type"
const val KEY_LAST_ACTIVITY_CONFIDENCE = "last_activity_confidence"
const val KEY_LAST_ACTIVITY_AT = "last_activity_at"

const val MIN_VEHICLE_DURATION_MS = 60_000L
const val MOTION_COOLDOWN_MS = 10_000L
const val ACTIVITY_UPDATE_INTERVAL_MS = 15_000L
const val MIN_ACTIVITY_CONFIDENCE = 35

// Fallback: if a drive ends but Activity Recognition never reports ON_FOOT
// (it can stay STILL/UNKNOWN), treat "haven't seen the vehicle for this long"
// as having parked. User-configurable ("Andet" settings); 0 disables it.
const val MOTION_FALLBACK_DEFAULT_SECONDS = 120L

// Battery-saving dormancy: after being still this long (while parked and with no
// walk-back timer) we pause the periodic activity sampling. Cheap transition
// events stay registered and wake us on the next movement.
const val STILL_DORMANT_THRESHOLD_MS = 15 * 60 * 1000L
const val KEY_STILL_SINCE = "still_since"
const val KEY_DORMANT = "dormant"

fun hasActivityRecognitionPermission(context: Context): Boolean {
    return Build.VERSION.SDK_INT < Build.VERSION_CODES.Q ||
        context.checkSelfPermission(Manifest.permission.ACTIVITY_RECOGNITION) ==
        PackageManager.PERMISSION_GRANTED
}

fun startMotionMonitoring(context: Context) {
    val prefs = context.getSharedPreferences(MOTION_PREFS, Context.MODE_PRIVATE)
    if (!hasActivityRecognitionPermission(context)) {
        prefs.edit()
            .putBoolean(KEY_REGISTERED, false)
            .putString(KEY_LAST_ERROR, "Mangler tilladelse til fysisk aktivitet")
            .apply()
        return
    }
    // Fresh start is never dormant.
    prefs.edit()
        .remove(KEY_LAST_ERROR)
        .remove(KEY_STILL_SINCE)
        .putBoolean(KEY_DORMANT, false)
        .apply()

    val request = ActivityTransitionRequest(
        listOf(
            enterTransition(DetectedActivity.IN_VEHICLE),
            enterTransition(DetectedActivity.ON_FOOT),   // generic on-foot; many devices send this
            enterTransition(DetectedActivity.WALKING),
            enterTransition(DetectedActivity.RUNNING),
            enterTransition(DetectedActivity.STILL)      // so the status flips back to "still" promptly
        )
    )
    try {
        ActivityRecognition.getClient(context)
            .requestActivityTransitionUpdates(request, transitionPendingIntent(context))
            .addOnSuccessListener {
                prefs.edit().putBoolean(KEY_REGISTERED, true).apply()
            }
            .addOnFailureListener { e ->
                prefs.edit()
                    .putBoolean(KEY_REGISTERED, false)
                    .putString(KEY_LAST_ERROR, e.message ?: e.javaClass.simpleName)
                    .apply()
            }
        ActivityRecognition.getClient(context)
            .requestActivityUpdates(ACTIVITY_UPDATE_INTERVAL_MS, updatePendingIntent(context))
    } catch (_: SecurityException) {
        prefs.edit()
            .putBoolean(KEY_REGISTERED, false)
            .putString(KEY_LAST_ERROR, "SecurityException")
            .apply()
    }
}

/** Pauses only the periodic activity sampling; transition events stay registered. */
fun pauseActivityUpdates(context: Context) {
    try {
        ActivityRecognition.getClient(context)
            .removeActivityUpdates(updatePendingIntent(context))
    } catch (_: RuntimeException) {
    }
}

/** Re-enables the periodic activity sampling after dormancy. */
fun resumeActivityUpdates(context: Context) {
    if (!hasActivityRecognitionPermission(context)) return
    try {
        ActivityRecognition.getClient(context)
            .requestActivityUpdates(ACTIVITY_UPDATE_INTERVAL_MS, updatePendingIntent(context))
    } catch (_: SecurityException) {
    }
}

/** Records the most recently detected activity for the debug status line. */
fun recordActivity(context: Context, activityType: Int, confidence: Int) {
    context.getSharedPreferences(MOTION_PREFS, Context.MODE_PRIVATE)
        .edit()
        .putInt(KEY_LAST_ACTIVITY_TYPE, activityType)
        .putInt(KEY_LAST_ACTIVITY_CONFIDENCE, confidence)
        .putLong(KEY_LAST_ACTIVITY_AT, System.currentTimeMillis())
        .apply()
}

/** Snapshot of the motion-detection state for the UI debug status line. */
fun readMotionStatus(context: Context): HashMap<String, Any?> {
    val prefs = context.getSharedPreferences(MOTION_PREFS, Context.MODE_PRIVATE)
    return hashMapOf(
        "hasPermission" to hasActivityRecognitionPermission(context),
        "registered" to prefs.getBoolean(KEY_REGISTERED, false),
        "lastError" to prefs.getString(KEY_LAST_ERROR, null),
        "lastActivityType" to prefs.getInt(KEY_LAST_ACTIVITY_TYPE, -1),
        "lastActivityConfidence" to prefs.getInt(KEY_LAST_ACTIVITY_CONFIDENCE, -1),
        "lastActivityAt" to prefs.getLong(KEY_LAST_ACTIVITY_AT, 0L),
        "inVehicleSince" to prefs.getLong(KEY_IN_VEHICLE_STARTED_AT, 0L),
        "lastReminderAt" to prefs.getLong(KEY_LAST_REMINDER_AT, 0L),
        "dormant" to prefs.getBoolean(KEY_DORMANT, false)
    )
}

fun stopMotionMonitoring(context: Context) {
    try {
        ActivityRecognition.getClient(context)
            .removeActivityTransitionUpdates(transitionPendingIntent(context))
        ActivityRecognition.getClient(context)
            .removeActivityUpdates(updatePendingIntent(context))
    } catch (_: RuntimeException) {
    }
}

private fun enterTransition(activityType: Int): ActivityTransition {
    return ActivityTransition.Builder()
        .setActivityType(activityType)
        .setActivityTransition(ActivityTransition.ACTIVITY_TRANSITION_ENTER)
        .build()
}

private fun pendingIntentFlags(): Int {
    return PendingIntent.FLAG_UPDATE_CURRENT or
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) PendingIntent.FLAG_MUTABLE else 0
}

private fun transitionPendingIntent(context: Context): PendingIntent {
    val intent = Intent(context, ActivityRecognitionReceiver::class.java)
        .apply { action = ACTION_ACTIVITY_TRANSITION }
    return PendingIntent.getBroadcast(context, 3001, intent, pendingIntentFlags())
}

private fun updatePendingIntent(context: Context): PendingIntent {
    val intent = Intent(context, ActivityRecognitionReceiver::class.java)
        .apply { action = ACTION_ACTIVITY_UPDATE }
    return PendingIntent.getBroadcast(context, 3002, intent, pendingIntentFlags())
}
