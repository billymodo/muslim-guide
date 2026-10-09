# Phase 03 — Qibla Device Testing

Device: Oppo A95 (CPH2365), Android 13
Build under test: debug APK at `a50fc45`, rebuilt locally with the Task 10
`/qibla` intent filter.

## Compass rotation — Test A

The displayed angle is relative to the device heading. Baseline and return
were aimed at Qibla; clockwise rotations were made with the screen facing up.

| Evidence | Relative angle | Expected | Result |
|---|---:|---:|---|
| [A1 baseline](evidence/phase-03/t10-A1-baseline.png) | 357° | 0° | PASS (3° circular difference) |
| [A2 90° clockwise](evidence/phase-03/t10-A2-90cw.png) | 271° | 270° | PASS (1° difference) |
| [A3 180° clockwise](evidence/phase-03/t10-A3-180cw.png) | 180° | 180° | PASS |
| [A4 return](evidence/phase-03/t10-A4-return.png) | 1° | 0° | PASS (1° difference) |

All readings were within the ±5° tolerance. Test B was skipped per the
director's decision; Test A and the domain reference tests were considered
sufficient.

The first attempted A3 turn was 180° additional from the A2 position, reaching
270° overall and reading 90°. No evidence was retained for that out-of-sequence
position. With approval, the phone was corrected to 180° overall; the final A3
reading above is from the corrected position.

## Sensor availability

The Oppo A95 has a magnetometer, so the no-sensor state could not be reproduced
on-device. The no-sensor path is covered by the Task 8 widget test and Task 9.5
unit regression tests: **fake only (device constraint)**.

## No-location and navigation

Location permission denial and system Location OFF did not by themselves cause
the no-location UI while Alexandria remained saved. The app correctly continued
using that manually selected city without requiring GPS. After the owner
approved clearing app data in Android Settings, the cold-start
`muslimguide://test/qibla` deep link displayed “لم يتم تحديد الموقع”; the
“تغيير المدينة” button opened the location picker.

- [No-location screen](evidence/phase-03/t10-no-location.png)
- Location was restored to ON; system `location_mode` verified as `3`.
- App location permission was restored to Allow.
- [App logcat](evidence/phase-03/t10-no-location-logcat.txt): no Flutter
  exception or fatal crash observed. Non-fatal platform/Oppo messages include
  blocked Android hidden-API access, missing Oplus scheduler files, a cold-start
  `ANR_LOG` slow-message report (2453 ms), a slow OpenGL frame (1993 ms), and an
  `IPCThreadState` unsupported-handle warning. The UI became available and
  remained interactive; these log messages were not investigated further.

## Deep-link manifest change

An Android intent filter for `muslimguide://test/qibla` was added to
`android/app/src/main/AndroidManifest.xml` after the link did not open on the
device. It adds no permissions. The administrative deviation and
`GAP-deeplink-consolidation` are recorded in `phases/03.md` and
`06-defect-register.md`.
