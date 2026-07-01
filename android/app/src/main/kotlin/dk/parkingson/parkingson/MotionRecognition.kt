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
const val KEY_LAST_REMINDER_AT = "last_reminder_at"

const val MIN_VEHICLE_DURATION_MS = 10_000L
const val MOTION_COOLDOWN_MS = 10_000L
const val ACTIVITY_UPDATE_INTERVAL_MS = 15_000L
const val MIN_ACTIVITY_CONFIDENCE = 35

fun hasActivityRecognitionPermission(context: Context): Boolean {
    return Build.VERSION.SDK_INT < Build.VERSION_CODES.Q ||
        context.checkSelfPermission(Manifest.permission.ACTIVITY_RECOGNITION) ==
        PackageManager.PERMISSION_GRANTED
}

fun startMotionMonitoring(context: Context) {
    if (!hasActivityRecognitionPermission(context)) return
    val request = ActivityTransitionRequest(
        listOf(
            enterTransition(DetectedActivity.IN_VEHICLE),
            enterTransition(DetectedActivity.ON_FOOT),   // generic on-foot; many devices send this
            enterTransition(DetectedActivity.WALKING),
            enterTransition(DetectedActivity.RUNNING)
        )
    )
    try {
        ActivityRecognition.getClient(context)
            .requestActivityTransitionUpdates(request, transitionPendingIntent(context))
        ActivityRecognition.getClient(context)
            .requestActivityUpdates(ACTIVITY_UPDATE_INTERVAL_MS, updatePendingIntent(context))
    } catch (_: SecurityException) {
    }
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
