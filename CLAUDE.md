# CLAUDE.md

Guidance for Claude Code (and any AI agent) working in this repo.

## What this app is

**parkingson** — a parking reminder app: *"never forget to pay for parking."* It
detects when you leave your car (Bluetooth disconnect + motion + location) and
reminds you to pay/start a parking session, with a loud DND-aware alarm, TTS
announcements, and voice commands. Localized in **9 languages**
(da, de, en, es, fi, fr, is, nb, sv).

- **Framework:** Flutter (Dart), single codebase.
- **Live on:** Google Play (Android), applicationId `henrock.n0rby.parkingson`,
  version `0.1.0+3`.
- **In progress:** iOS port — see [`docs/IOS_PORT.md`](docs/IOS_PORT.md).

## ⚠️ Golden rule

**The Android app is live in production. Do not break the Android build.**
Any iOS work must keep Android compiling and behaving. After changes, run
`flutter analyze` and, ideally, build/run on an Android device before committing.

## Architecture

- **Dart** (`lib/`) holds all UI, navigation, localization, business logic,
  repositories (SharedPreferences-backed), and cross-platform services
  (notifications, TTS, foreground location, maps deep-links).
- **Native behaviour** lives behind a single method channel:
  **`MethodChannel('dk.parkingson/alarm')`**.
  - **Android** implements it fully in Kotlin
    (`android/app/src/main/kotlin/dk/parkingson/parkingson/`): foreground
    service, `AlarmPlayer` (DND-aware alarm on the ALARM stream), Activity
    Recognition, classic-Bluetooth ACL-disconnect receiver, boot/watchdog
    receivers, `Speaker` (TTS), voice capture via `RecognizerIntent`.
  - **iOS** has **no** native implementation yet. All Dart channel calls are
    wrapped in `try/catch`, so the app **runs on iOS without crashing** — the
    native-backed features simply no-op until ported.

### Key directories
- `lib/screens/` — screens (home, setup, reminder, cars, parking apps, …)
- `lib/services/` — location, bluetooth, motion, notification, voice
- `lib/repositories/` — persistence (SharedPreferences)
- `lib/models/` — data models
- `lib/l10n/` — ARB files + generated localizations (9 locales)
- `android/app/src/main/kotlin/.../` — native Kotlin (the channel handler)
- `ios/` — scaffold only; port target
- `docs/IOS_PORT.md` — **the iOS port plan and checklist**

## Common commands

```bash
flutter pub get              # deps
flutter analyze              # lint / static analysis (run before committing)
flutter test                 # widget tests (test/widget_test.dart)
flutter run -d <device-id>   # run (use `flutter devices` to list)
flutter install -d <id>      # build release + install to a connected device
flutter build apk --release  # Android release APK
flutter build ipa            # iOS release (Mac only)
```

Localization is generated (`generate: true` + `l10n.yaml`); edit the `.arb`
files in `lib/l10n/`, not the generated `app_localizations_*.dart`.

## iOS port — the short version

Cross-platform parts (UI, l10n, notifications, TTS, foreground location save,
maps, the voice-command *parser*) work on iOS quickly. The two hard parts:

1. **Background parking detection** — iOS has no foreground service. Use
   `CLLocationManager` region/geofence monitoring + significant-location-change,
   Core Motion, and `AVAudioSession` route-change (car BT audio dropping) as the
   "left the car" signal.
2. **DND-piercing alarm** — needs Apple's **Critical Alerts** entitlement;
   otherwise fall back to time-sensitive notifications.

Some Android channel methods have **no iOS equivalent** (installed-apps list,
battery-optimization, lock-screen unlock) — guard them with `Platform.isAndroid`
so no dead UI shows on iOS. Full details and ordering in
[`docs/IOS_PORT.md`](docs/IOS_PORT.md).

## Conventions

- Match the surrounding code's style; keep both platforms buildable.
- Commit messages: short imperative subject (see `git log`).
- Store/marketing assets live in `store/`; privacy & Play docs at repo root
  (`PRIVACY_POLICY.md`, `PLAY_STORE_DATA_SAFETY.md`) and `docs/`.
