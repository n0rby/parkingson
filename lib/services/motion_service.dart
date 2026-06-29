// TODO: Implement using flutter_background_service
// Mirrors ActivityRecognitionMonitor.kt from the Android version.
// Detects IN_VEHICLE → ON_FOOT transition and triggers parking reminder.
class MotionService {
  static const minVehicleDurationMs = 20000;
  static const reminderCooldownMs = 10000;

  Future<void> startMonitoring({required Function onParkingDetected}) async {
    // TODO: Use flutter_background_service to run detection in background
    // Android: activity_recognition_flutter for Google Play Services API
    // iOS: CoreMotion CMMotionActivityManager via platform channel
  }

  Future<void> stopMonitoring() async {
    // TODO: Stop background service
  }
}
