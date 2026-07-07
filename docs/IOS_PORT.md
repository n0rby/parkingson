# Parkingson — iOS port plan

The app is Android-first: all native behaviour lives in Kotlin behind
`MethodChannel('dk.parkingson/alarm')`. iOS has **no** native implementation
yet, but the Dart calls are wrapped in `try/catch`, so the app **runs on iOS
without crashing** — the native-backed features just no-op until ported.

This doc is the checklist for finishing the iOS version on a Mac.

---

## 0. Already done (from Windows, no Mac needed)

- iOS project scaffold exists (`ios/Runner`, workspace, Podfile).
- **Bundle identifier** set to `henrock.n0rby.parkingson` (matches Android
  applicationId + Play listing).
- `Info.plist` has usage strings for location (when-in-use + always), Bluetooth,
  motion, **microphone + speech** (new), background modes
  (`location`, `bluetooth-central`, `fetch`, `processing`), all 9 localizations,
  and `LSApplicationQueriesSchemes` for parking apps (schemes need verifying).
- AppIcon set present in `Assets.xcassets/AppIcon.appiconset`.

---

## 1. First run on the Mac

```bash
flutter pub get
cd ios && pod install && cd ..
open ios/Runner.xcworkspace        # set your Signing Team on the Runner target
flutter run                        # simulator first, then a real device
```

Expected: UI, navigation, onboarding, localization, notifications and TTS work.
Location save + maps deep links work in the foreground. Everything behind the
MethodChannel (alarm, motion, voice, parking-app list) is silently inert.

Fix-ups likely needed:
- Set the **Development Team** (free Apple ID is fine for local device runs).
- Real **AdMob iOS app ID** in `Info.plist` `GADApplicationIdentifier`
  (currently Google's *test* ID). AdMob IDs are per-platform.
- Add **App Tracking Transparency**: `NSUserTrackingUsageDescription` + the ATT
  prompt if you keep personalised ads.

---

## 2. Feature-by-feature port (native Swift work)

Create a Swift `MethodChannel` handler mirroring the Kotlin one, plus a few
iOS-native subsystems. Order by value:

### 2a. Location + parking detection  ⭐ core value, hardest on iOS
Android uses a foreground service + Activity Recognition + classic-BT ACL
disconnect. iOS has none of those. The iOS-native equivalents:
- **`CLLocationManager`** with `allowsBackgroundLocationUpdates = true` and
  **significant-location-change** or **region (geofence) monitoring** to get
  woken in the background when the user moves away from the parked spot.
- **Core Motion** (`CMMotionActivityManager`) for automotive/walking, but note
  background sampling is limited.
- There is **no reliable classic-Bluetooth disconnect** API on iOS. Use
  **`AVAudioSession` route-change notifications** instead: when the car's
  Bluetooth audio route disappears, that's the "left the car" signal.
- Reminder = `UNUserNotificationCenter` local notification scheduled when the
  leave-car signal fires.

Reality: background detection on iOS is best-effort and less reliable than
Android's FGS. Design for "wake on region exit / audio-route change" rather than
a continuously-running service.

### 2b. Alarm / notification  ⚠️ DND limitation
Android `AlarmPlayer` forces sound on the ALARM stream and is DND-aware.
iOS cannot pierce Do Not Disturb without the **Critical Alerts** entitlement
(requires a special request to Apple, justified use only). Without it:
- Use **time-sensitive** notifications (`interruptionLevel = .timeSensitive`)
  with a custom sound. They break through Focus modes but not full DND.
- TTS via `flutter_tts` (AVSpeechSynthesizer) already works cross-platform.

### 2c. Voice commands
Android uses `RecognizerIntent`. iOS: **`SFSpeechRecognizer` + `AVAudioEngine`**
(needs the mic + speech usage strings already added). Implement
`startVoiceCapture` on the Swift channel to return candidate transcripts;
`voice_command_parser.dart` (all 9 languages) then works unchanged.

### 2d. Parking apps  ⚠️ model differs
iOS forbids listing installed apps, so `getInstalledApps` / `getAppIcon` /
`launchApp(package)` do not port. Instead:
- Ship a **fixed list** of known parking apps.
- Probe availability with `canOpenURL` against `LSApplicationQueriesSchemes`.
- Launch with `UIApplication.open(url)` using each app's URL scheme.
- Bundle each app's icon as an asset (can't read it from the system).

### 2e. Misc channel methods
- `openBluetoothSettings` → `App-Prefs:` / `UIApplication.openSettingsURLString`
  (deep-linking to BT settings is restricted; likely just open app settings).
- `isIgnoringBatteryOptimizations` / `requestIgnoreBatteryOptimizations` /
  `isDeviceLocked` / `requestUnlock` — **no iOS equivalent**; guard these to
  Android in Dart so no dead UI shows (battery card, lock-screen unlock flow).
- `pickAlarmSound` — iOS has no ringtone picker; ship bundled sounds.

---

## 3. Dart clean-up for iOS (small, do on Mac so both platforms are testable)

Guard Android-only UI with `Platform.isAndroid` so iOS shows no dead controls:
- `home_screen.dart`: battery-optimization card, motion-status line.
- `reminder_screen.dart`: skip the voice auto-start until 2c is implemented.
- `setup_screen.dart` / parking apps: hide or adapt the list on iOS.
Run `flutter analyze` and test the Android build still behaves.

---

## 4. App Store prep
- Apple Developer Program membership ($99/yr) for TestFlight/App Store.
- App icon (1024×1024 already in the asset set — verify).
- Privacy nutrition labels (location, identifiers/AdMob) — mirror the Play
  Data-safety answers.
- `NSUserTrackingUsageDescription` if personalised ads.
- Build/upload via Xcode or `flutter build ipa` → Transporter/TestFlight.

---

## Summary
Cross-platform parts (UI, l10n, notifications, TTS, location save, maps, the
voice-command *parser*) will work on iOS quickly. The **background
parking-detection** and the **DND-piercing alarm** are the two areas that are
fundamentally more constrained on iOS and need the most native work + realistic
expectation-setting.
