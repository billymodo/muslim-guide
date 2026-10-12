# Phase 04 Device Session — Tasks 3, 4, and 5

Device: Oppo A95 (CPH2365), Android 13 (API 33)  
Build under test: debug APK from `cf3d673`  
Session date: 2026-10-10

## Preparation

The owner confirmed Location ON, fine/coarse location permission granted,
Don't optimize, ColorOS Auto-launch and background running enabled, and the
default font. ADB identified the connected phone as CPH2365.

## Task 3 — Notification diagnostics

**PASS.** A cold start displayed onboarding; after selecting English, the
approved diagnostics deep link opened `/diagnostics/notifications`. Initial
state showed notification permission denied and exact-alarm access granted.
The request button displayed Android's notification permission prompt.
After granting, returning to the app refreshed the screen to show notifications
granted and exact alarms granted.

- [Initial diagnostics](evidence/phase-04/t3-01-diagnostics-initial.png)
- [Android permission prompt](evidence/phase-04/t3-permission-dialog.png)
- [Diagnostics after grant/resume](evidence/phase-04/t3-02-after-grant.png)

The device reports API 33. Exact alarm access was granted in Android package
state. Location was enabled and fine/coarse permissions were granted.

## Task 4 — Scheduling

Riyadh was selected; the prayer screen displayed all five prayer times and the
app registered scheduled-notification alarms.

- [Prayer screen after selecting Riyadh](evidence/phase-04/t4-after-city.png)
- [Alarm dump before reboot](evidence/phase-04/t4-dumpsys-alarm-before-reboot.txt)
- [First post-boot sample](evidence/phase-04/t4-dumpsys-alarm-reboot-90s.txt)
- [Second post-boot sample](evidence/phase-04/t4-dumpsys-alarm-reboot-180s.txt)
- [After-launch sample](evidence/phase-04/t4-dumpsys-alarm-after-launch-controlled.txt)

The earlier, pre-Dhuhr alarm dump had 34 entries for the app. In the controlled
reboot sequence after Dhuhr had fired, the app had zero alarms at the first
post-boot sample (>90 seconds after boot) and zero again 90 seconds later,
without opening the app. Opening the app restored 33 future alarms. Result:
**0 → 0 → 33**. The one-entry difference from 34 is expected because Dhuhr's
same-day alarm had already fired. On this Oppo A95 run, alarms were not
restored while the app remained unopened after reboot; the boot-restoration
gap is confirmed.

A Dhuhr notification appeared with title "Dhuhr Prayer", body "Prayer time",
channel `prayer_adhan_v1`, and the generated raw placeholder sound. Its initial
persisted NotificationManager timestamp was 5.488 seconds after the alarm
target, but it predates the approved evidence push. For the post-push retest,
Tokyo was temporarily selected to bring the next prayer earlier. The Isha alarm
target was 12:32:50.000 EEST (`origWhen=1791624770000`); NotificationManager
recorded `mCreationTimeMs=1791624846526`, or 12:34:06.526 EEST. The measured
delay was **+76.526 seconds**, exceeding the ±60-second limit: **FAIL**.

The app requests `AndroidScheduleMode.exactAllowWhileIdle` and exact-alarm
access was granted. The captured AlarmManager record nevertheless showed
`windowLength=725776 ms` (12m 5.776s); ColorOS logged the app being unfrozen
for the alarm at 12:34:06.397 EEST. These observations are consistent with
OS/OEM deferral but do not establish its root cause. A follow-up device-state
check confirmed `SCHEDULE_EXACT_ALARM` is granted, but
`com.muslimguide.app` is absent from the current `dumpsys deviceidle` user
whitelist despite the reported battery-optimization exemption. This mismatch
needs verification in ColorOS settings; the follow-up snapshot does not prove
the exact device-idle state at delivery time. Scheduler timing investigation
is required before Phase 04 can proceed to Task 6. **Update 2026-10-11
07:40 EEST (foreground retest):** the next prayer alarm target was
07:39:25.000 EEST (`origWhen=1791693565000`); NotificationManager recorded
`mCreationTimeMs=1791693609888`. The measured delay was **+44.888 seconds**,
within the ±60-second target: **PASS (foreground)**. The owner heard the 3
notification beeps. Evidence:
[t4-timing-scheduled-alarm.txt](evidence/phase-04/t4-timing-scheduled-alarm.txt),
[t4-timing-notification-record.txt](evidence/phase-04/t4-timing-notification-record.txt),
[t4-timing-notification-manager.txt](evidence/phase-04/t4-timing-notification-manager.txt),
and [t4-timing-logcat-pending.txt](evidence/phase-04/t4-timing-logcat-pending.txt).

- [Notification shade](evidence/phase-04/t4-01-notification-arrived.png)

No `ScheduledNotificationReceiver` exception or fatal app exception was found
in the captured log review. The captured receiver log is
[t4-logcat-after-reboot.txt](evidence/phase-04/t4-logcat-after-reboot.txt).

## Task 5 — Adhan player

**PASS.** Playback started from Prayer, the screen showed `Playing`, and
Android exposed the `Prayer audio` foreground media notification. Stop returned
the UI to `Ready` and the media session to stopped. The eight-second
placeholder ended naturally after playback; a playing state observed shortly
before its natural completion was expected and is not a defect.

After swiping the app away from Recents, playback remained available; reopening
the app and starting playback again succeeded on this ColorOS device with the
owner-confirmed battery/background settings.

- [Playing](evidence/phase-04/t5-01-playing.png)
- [Stopped](evidence/phase-04/t5-02-stopped.png)
- [Playback in Recents](evidence/phase-04/t5-recents-playing.png)
- [Player after relaunch](evidence/phase-04/t5-after-reopen-playing.png)
- [Notification shade including Prayer audio](evidence/phase-04/t4-01-notification-arrived.png)

The notification-sound truncation gap remains untested: the placeholder is only
eight seconds long. ColorOS playback passed under the tested settings; this
does not establish behavior when battery optimization is enabled.

## Lesson — ColorOS integration audio tests

Integration audio tests on ColorOS need `adb shell am force-stop
com.muslimguide.app` before each run: a stale `audio_service` foreground
service poisons the state stream and the next run hangs or fails.
Additionally, `flutter test integration_test/` replaces the app package on
the device — reinstall with `flutter install --debug` and verify launch
afterwards. Documented for Task 11 and future integration tests
(GAP-integration-player-race).

## Pending measurements

1. Verify the ColorOS battery-optimization setting against the app's absence
   from the current device-idle user whitelist.
2. Investigate why AlarmManager exposed a 725,776 ms delivery window for an
   `exactAllowWhileIdle` schedule despite exact-alarm access being granted.
3. Keep Task 6 blocked until the scheduler timing failure is resolved.
4. Do not treat the reboot-restoration failure as a timing-test result.

## CR-0013 — Night thirds row (2026-10-11)

**PASS (owner device verification, Oppo A95).** Build: debug APK from `89ffed7`.
Alexandria selected; Prayer screen showed two new cells (first third +
last third/Tahajjud) positioned between the hero and the prayer-times list.
Times were sensible, Arabic labels correct, no overflow observed.

- [Prayer screen with night thirds](evidence/phase-04/cr0013-01-prayer-with-thirds.png)
- Polar spot-check (Tromsø + 2026-06-21 → cells hidden): optional, not run
  in this session.

## Task 8 — Sunrise reposition + settings screen (2026-10-11)

**PASS (owner device verification, Oppo A95).**

- Sunrise row between Fajr and Dhuhr with inline "ليست صلاة فريضة" note.
- `/settings/notifications` opens with 6 sections (prayer alerts,
  notifications, adhan, device, licenses, about).
- Deep link `muslimguide://notifications/settings` opens the screen.
- Toggle Fajr off → dumpsys alarm check pending explicit confirmation.

- [Settings screen](evidence/phase-04/t8-01-settings.png)
- [Sunrise position](evidence/phase-04/t8-02-sunrise-position.png)

## Task 12 — Real adhan 2:34 (2026-10-12)

**PASS (owner device verification, Oppo A95).**

- Beautiful_adhan.ogg (CC0, 2:34, 1.17MB, Adam-synagda) plays **fully
  without truncation** on channel `prayer_adhan_v2`.
- Notification arrived with full 2:34 adhan sound.
- **No GAP-prayer-adhan-truncation** — Android played the full 2:34.
- [Adhan notification on device](evidence/phase-04/t12-01-adhan-notification.png)

## Source changes and commit

No application source, Manifest, or build configuration was changed during
this device session. Evidence and this report are committed separately from
the application implementation.
