# Play Console — Health apps declaration: ACTIVITY_RECOGNITION justification

Parkingson is flagged for the **Health apps** policy because it declares
`android.permission.ACTIVITY_RECOGNITION`. Parkingson is **not** a health,
fitness, wellness, or medical app. The permission is used for a single,
non-health core feature: detecting when the user stops driving and starts
walking, so the app can remind them to pay for parking.

This file holds the justification to submit to Google Play support (in English,
since review is in English) and the facts that back it up.

---

## Submittable justification (paste into the Play support case / appeal)

> **App:** Parkingson (`henrock.n0rby.parkingson`)
>
> **Permission in question:** `android.permission.ACTIVITY_RECOGNITION`
>
> **Why the app uses it (non-health core feature):**
> Parkingson is a parking-reminder utility. It uses the Activity Recognition
> API solely to detect the transition from *in-vehicle* (driving) to *on-foot*
> (walking). That transition is how the app determines the user has parked and
> left their car — for cars **without** Bluetooth, where a Bluetooth
> disconnect signal isn't available. When this transition is detected, the app
> saves the parking location and reminds the user to pay for parking.
>
> **The app is not a health/fitness/wellness/medical app.** It does **not**:
> - track steps, distance, calories, heart rate, sleep, stress, nutrition,
>   menstruation, or any fitness/wellness metric;
> - provide any health, medical, diagnostic, or clinical functionality;
> - build a fitness/activity history or profile.
>
> **Data handling:** Detected activity states are used **transiently and
> on-device only**, exclusively to trigger the parking reminder. Activity data
> is **not stored long-term, not transmitted off the device, and not shared**
> with any third party or server. Parkingson has no backend that receives user
> data.
>
> **User disclosure:** During onboarding the app shows a prominent disclosure
> that physical-activity permission is used to "detect driving and walking",
> and the permission is requested at runtime. A privacy policy describing this
> is provided.
>
> We therefore ask to retain `ACTIVITY_RECOGNITION` for this non-health core
> feature. Removing it would disable parking detection for vehicles without
> Bluetooth, which is a core purpose of the app.

---

## Supporting facts (already true in the codebase)

- **Purpose in code:** `MotionRecognition.kt` registers Activity Transition
  updates for `IN_VEHICLE → ON_FOOT/WALKING` only, to fire the parking flow.
- **On-device only:** the activity state is read via the on-device Activity
  Recognition API; nothing is uploaded (the app has no server).
- **Prominent disclosure:** the permissions onboarding screen lists
  "Fysisk aktivitet — Detektér kørsel og gang" before requesting it.
- **No Health Connect / Body Sensors:** the app does not use any health API.

## Checklist before/with the appeal
- [ ] A public **privacy policy** URL is set in Play Console and mentions the
      activity-recognition use + on-device processing.
- [ ] **Data safety** form: activity data declared honestly — not collected
      (not sent off device) / not shared.
- [ ] Keep the in-app prominent disclosure shown before the runtime request.
- [ ] Submit the justification above via Play Console → the health declaration
      flow (any free-text field) or Policy status → contact/appeal.

## Honest note
Google's form is worded to push non-health apps to *remove* the permission, so
the appeal is not guaranteed to succeed. If it's rejected, the fallback is to
remove `ACTIVITY_RECOGNITION` and rely on Bluetooth-only parking detection.
