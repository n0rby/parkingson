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
        // A motion event is an FGS-start exemption window — revive monitoring if
        // it was killed (reboot / "Clear all").
        ServiceStarter.ensureRunning(appContext)
        when {
            intent.action == ACTION_ACTIVITY_TRANSITION && ActivityTransitionResult.hasResult(intent) -> {
                val result = ActivityTransitionResult.extractResult(intent) ?: return
                result.transitionEvents.forEach {
                    recordActivity(appContext, it.activityType, -1)
                    updateDormancy(appContext, it.activityType)
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
                        updateDormancy(appContext, it.type)
                        handleActivity(appContext, it.type)
                    }
            }
        }
    }

    private fun handleActivity(context: Context, activityType: Int) {
        val prefs = context.getSharedPreferences(MOTION_PREFS, Context.MODE_PRIVATE)
        val now = System.currentTimeMillis()

        if (activityType == DetectedActivity.IN_VEHICLE) {
            // Mirror to the Flutter store as soft "was driving" corroboration for
            // the confidence check (never a hard gate — AR is too flaky for that).
            context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
                .edit().putString("flutter.last_in_vehicle_at", now.toString()).apply()
            // Track the last time we saw the vehicle, so the fallback below can
            // tell when we've clearly left it. A brief stop (red light) keeps
            // refreshing this, so it never trips mid-drive.
            val edit = prefs.edit().putLong(KEY_LAST_IN_VEHICLE_AT, now)
            if (prefs.getLong(KEY_IN_VEHICLE_STARTED_AT, 0L) == 0L) {
                edit.putLong(KEY_IN_VEHICLE_STARTED_AT, now)
            }
            edit.apply()
            return
        }

        // Any non-vehicle activity. We conclude "parked" either the fast way
        // (clearly on foot now) or via the fallback (drove, then haven't seen the
        // vehicle for a sustained window — catches STILL/UNKNOWN that never turn
        // into ON_FOOT).
        val vehicleStartedAt = prefs.getLong(KEY_IN_VEHICLE_STARTED_AT, 0L)
        if (vehicleStartedAt == 0L) return // never drove → nothing to conclude

        val lastReminderAt = prefs.getLong(KEY_LAST_REMINDER_AT, 0L)
        val wasInVehicleLongEnough = now - vehicleStartedAt >= MIN_VEHICLE_DURATION_MS
        val isPastCooldown = now - lastReminderAt >= MOTION_COOLDOWN_MS
        if (!wasInVehicleLongEnough || !isPastCooldown) return

        val fallbackMs = fallbackThresholdMs(context)
        val lastInVehicleAt = prefs.getLong(KEY_LAST_IN_VEHICLE_AT, vehicleStartedAt)
        val leftVehicleLongEnough =
            fallbackMs > 0L && now - lastInVehicleAt >= fallbackMs

        val onFoot = isOnFoot(activityType)
        if (!onFoot && !leftVehicleLongEnough) return

        prefs.edit()
            .remove(KEY_IN_VEHICLE_STARTED_AT)
            .remove(KEY_LAST_IN_VEHICLE_AT)
            .putLong(KEY_LAST_REMINDER_AT, now)
            .apply()

        // Bridge to the Dart isolate. ON_FOOT ("walked away") is the reliable
        // signal and fires for everyone; the timeout fallback is low-confidence,
        // so it goes to a separate key that Dart only honours for users with no
        // BT/USB car (see motion_service).
        val key = if (onFoot) "flutter.motion_parking_event" else "flutter.motion_fallback_event"
        context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
            .edit()
            .putString(key, now.toString())
            .apply()
    }

    /** The user-configured fallback window in ms (from the "Andet" settings). */
    private fun fallbackThresholdMs(context: Context): Long {
        val seconds = context
            .getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
            .getLong("flutter.motion_fallback_seconds", MOTION_FALLBACK_DEFAULT_SECONDS)
        return seconds * 1000L
    }

    private fun isOnFoot(type: Int): Boolean {
        return type == DetectedActivity.ON_FOOT ||
            type == DetectedActivity.WALKING ||
            type == DetectedActivity.RUNNING
    }

    /**
     * Battery-saving dormancy. When the user has been still for a while, and a
     * car is parked, and there's no walk-back timer, we pause the periodic
     * activity sampling — cheap transition events remain and wake us on the
     * next movement. Any non-still activity resets the timer and wakes us.
     */
    private fun updateDormancy(context: Context, activityType: Int) {
        val prefs = context.getSharedPreferences(MOTION_PREFS, Context.MODE_PRIVATE)
        val now = System.currentTimeMillis()
        val dormant = prefs.getBoolean(KEY_DORMANT, false)

        if (activityType == DetectedActivity.STILL) {
            var stillSince = prefs.getLong(KEY_STILL_SINCE, 0L)
            if (stillSince == 0L) {
                stillSince = now
                prefs.edit().putLong(KEY_STILL_SINCE, now).apply()
            }
            if (dormant) return
            val stillLongEnough = now - stillSince >= STILL_DORMANT_THRESHOLD_MS
            if (stillLongEnough && isParked(context) && !hasActiveWalkBackTimer(context)) {
                pauseActivityUpdates(context)
                prefs.edit().putBoolean(KEY_DORMANT, true).apply()
            }
        } else {
            // Movement resumed → reset the still timer and wake if dormant.
            prefs.edit().remove(KEY_STILL_SINCE).apply()
            if (dormant) {
                resumeActivityUpdates(context)
                prefs.edit().putBoolean(KEY_DORMANT, false).apply()
            }
        }
    }

    private fun isParked(context: Context): Boolean {
        val p = context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
        return !p.getString("flutter.last_parking_location", null).isNullOrEmpty()
    }

    private fun hasActiveWalkBackTimer(context: Context): Boolean {
        val p = context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
        return !p.getString("flutter.parking_timer", null).isNullOrEmpty()
    }
}
