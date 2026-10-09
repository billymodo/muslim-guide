# Phase 03 — Output Report

## Status

✅ COMPLETED — 2026-10-10

## Summary

Phase 03 delivered the Qibla direction feature, offline compass integration,
numeric fallback when a magnetometer is unavailable, regression coverage for
the no-sensor stream contract, and device verification on an Oppo A95.

## Deliverables

- `lib/features/qibla/domain/qibla_calculator.dart`
- `lib/features/qibla/domain/qibla_direction.dart`
- `lib/features/qibla/application/qibla_providers.dart`
- `lib/features/qibla/application/qibla_state.dart`
- `lib/features/qibla/data/compass_service.dart`
- `lib/features/qibla/data/flutter_compass_service.dart`
- `lib/features/qibla/presentation/qibla_screen.dart`
- `lib/features/qibla/presentation/widgets/qibla_compass.dart`
- `/qibla` route
- Device report: [phase-03-device-testing.md](./phase-03-device-testing.md)

## Test Results

- Full suite: **368/368 passed** (CI #61, test job).
- Qibla domain: 35 tests.
- Qibla application/data: 28 tests, including 7 Task 9.5 regressions.
- Qibla presentation: 23 widget tests.
- Coverage, last measured in Task 9: domain 100%, application 98.1%,
  presentation 96.9%.
- `flutter_compass_service.dart`: 100% after Task 9.5.
- The final LCOV artifact was not retained; the 98.3% application coverage
  figure from the closeout request could not be independently verified.
- CI #61: 9/9 jobs succeeded on `a50fc45`:
  [workflow run](https://github.com/billymodo/muslim-guide/actions/runs/37984320892).
- CI analyze, test, and debug APK build all passed. The APK was also rebuilt
  locally with the Task 10 deep-link intent filter and installed on-device.

## Device Testing Evidence

Device: Oppo A95 (CPH2365), Android 13.

| Test | Status | Evidence |
|---|---|---|
| Test A compass rotation | PASS, all readings within ±5° | `t10-A1-baseline.png` through `t10-A4-return.png` |
| No-sensor | Fake-only; device has magnetometer | Task 8 widget and Task 9.5 unit regression tests |
| No-location | PASS; message and location-picker navigation verified | `t10-no-location.png` |
| Logcat | No Flutter exception or fatal crash; non-fatal platform/Oppo warnings documented | `t10-no-location-logcat.txt` |

See the [device report](./phase-03-device-testing.md) for angles, notes, and
the accepted A3 correction sequence.

## Bugs and Fixes

| Item | Description | Fix commit |
|---|---|---|
| BUG-5 | Splash deadlock regression from Phase 02 | `862376e` |
| Task 9.5 | Null compass event previously left Qibla UI loading indefinitely | `a50fc45` |
| BUG-6 | Picker back navigation; remains open for Phase 05+ | — |

## Known Gaps and Deferrals

| Gap | Severity | Target |
|---|---|---|
| GAP-compass-maintenance | P3 | Phase 05+ |
| GAP-city-resolution-dup | P3 | Phase 05+ |
| GAP-license-page | P3 | Phase 05+ |
| GAP-qibla-bg | P3 | Phase 05+ |
| GAP-deeplink-consolidation | P3 | Phase 04+ |
| BUG-6 (picker back navigation) | P3 | Phase 05+ |
| Permission-deny-only path (Location ON + Deny) | P3 | Phase 05+ |
| Minor-1 overflow at 200% text scale | P3 | Phase 10 |

## Decisions Referenced

- DEC-0015 — Android-only v1, minSdk 24.
- DEC-0016 — Riverpod 2.6.1.
- DEC-0028 — MWL default calculation method.
- DEC-0029 — `flutter_timezone` decision and Asia/Riyadh fallback policy;
  dependency addition remains subject to its required CR.
- CR-0011 — `flutter_compass 0.8.1`, MIT, exact pin.
- OD-0028 — CLOSED as an accepted known limitation
  (`99275fc`, `6ca67a4`).
- OD-0029 — Oppo A95 temporary reference device.

## Commit Range

`f44ffc9` (Phase 03 start) → `e9cbe6c` (device testing).

## Sign-off

- Tasks 1–10 completed, including the Task 9.5 no-magnetometer fix.
- Device evidence and deferred items are documented.
- No new open decision blocks Phase 04.

## Next Phase

Phase 04 — Notifications & Adhan (pending specification).
