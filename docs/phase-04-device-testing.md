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
- [Alarm dump after reboot and app launch](evidence/phase-04/t4-dumpsys-alarm-after-reboot-full.txt)

The captured alarm dump had 34 entries for the app before reboot. The initial
post-reboot observation was taken after opening the app, not at both prescribed
90-second intervals; it therefore does not distinguish plugin boot restoration
from app rescheduling. A controlled boot sequence remains pending.

A Dhuhr notification appeared with title "Dhuhr Prayer", body "Prayer time",
channel `prayer_adhan_v1`, and the generated raw placeholder sound. The
scheduled alarm time was 11:40:08 EEST. A subsequent NotificationManager dump
recorded `mCreationTimeMs=1791621613488`, equivalent to 11:40:13.488 EEST:
5.488 seconds after the scheduled alarm time. This persisted system timestamp
is within the ±60-second target, but was not captured by the prescribed
cleared-logcat timing procedure; repeat the measurement after this commit.
The relevant notification entry is preserved in
[t4-notification-manager-timing-initial.txt](evidence/phase-04/t4-notification-manager-timing-initial.txt).

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

## Pending measurements

1. Repeat the timing test with a cleared logcat, recording the alarm's scheduled
   timestamp and the system notification's actual post timestamp. The existing
   NotificationManager timestamp is a provisional 5.488-second result.
2. Repeat reboot validation without opening the app for 90 seconds, take an
   alarm count, wait another 90 seconds and take a second count, then open the
   app and take a third count.
3. Do not treat these pending measurements as failures or as confirmed passes.

## Source changes and commit

No application source, Manifest, or build configuration was changed during
this device session. Evidence and this report are committed separately from
the application implementation.
