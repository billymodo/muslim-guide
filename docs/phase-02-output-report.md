# Phase 02 — Output Report

## Status
✅ COMPLETED — 2026-10-09

## Summary
Phase 02 (Prayer Times & Location) delivered:
- Pure Domain calculator (PrayTimes-derived, LGPL)
- 8 reference cities validated
- GPS + manual city selection
- DST + polar edge cases handled
- Device tested on Oppo A95 (CPH2365 / Android 13)

## Deliverables
- `lib/features/prayer/domain/services/prayer_calculator.dart` — pure
  domain calculator (no Flutter imports; PrayTimes.org port, LGPL)
- Domain models: `city`, `location_data`, `prayer_time(s)_result`,
  `calculation_method`, `asr_method`, `high_latitude_rule`
- `lib/features/location/` — `LocationService` + `GeolocatorLocationService`
  (CR-0009) with permission/service status mapping
- Data: `lib/features/prayer/data/cities_loader.dart` (bundled GeoNames
  cities asset) + `prayer_times_repository_impl.dart`
- Screens: `prayer_times_screen.dart` (SCREEN-005),
  `location_picker_screen.dart` (SCREEN-006)
- Widgets: `prayer_hero_card.dart` (incl. BUG-2 change-city button),
  `prayer_time_row.dart`, `countdown_timer.dart`
- Providers: `prayer_times`, `countdown`, `location`, `calculation_method`,
  `asr_method`, `high_latitude_rule`

## Test Results
- `flutter test`: **262/262 ✅** (`flutter analyze --fatal-infos`: clean)
- Domain: **174 tests** (calculator + polar + DST + solar-noon + edge cases
  + city models) — `flutter test test/features/prayer/domain`
- Presentation + root widget: **30 tests**
- Remaining suites (core/data/location/application): 58 tests
- CI: **9/9 jobs green (Run #46→#50)**
- Device: **M1–M5 + Step 0 all PASS** (see below)

## Device Testing Evidence
| Test | Status | Evidence |
|---|---|---|
| Step 0 — BUG-2 verify | PASS | docs/evidence/phase-02/t-bug2-01..04 |
| M1 — Screen timeout | PASS @30m | shell-verified |
| M2 — T7b location rejection | PASS | t7b-01/02 |
| M3 — T4 DST London | PASS | t4-01/02 |
| M4 — T5 Tromsø polar | PASS | t5-01 |
| M5 — T8c font 1.6 | PASS @device-max | t8c-01..03 |

## BUGs Resolved
| ID | Description | Fix commit |
|---|---|---|
| BUG-1 | mojibake in cities | c88cc97 |
| BUG-3 | cold-start deep link bypass | 4ba60bd |
| BUG-4 | English locale not applied | cedbbac |
| BUG-5 | splash deadlock (regression) | 862376e |
| BUG-2 | no UI path to change city | fc2e479 |

## Known Gaps (carried forward)
| Gap | Severity | Target |
|---|---|---|
| OD-0028 — Asr systematic −2/−3m (−8m Tromsø) | P2 | Phase 03 |
| Location ON + Permission Deny only (not tested) | P3 | Phase 05+ |
| BUG-6 — picker back navigation | P3 | Phase 05+ |
| Minor-1 — overflow @ 200% | P3 | Phase 10 |
| 200% font (device max = 1.6) | info | device constraint |

## Decisions Referenced
- DEC-0028 (calculation method default = MWL)
- DEC-0029 (timezone via flutter_timezone fallback Asia/Riyadh)
- DEC-0017 (reference devices — deviation via OD-0029)
- OD-0029 (Oppo A95 as temporary primary — decided)

## Commits Range
`cb64a83` (Phase 02 first commit, 2026-10-07) → `e56b96e` (M5)

## Sign-off
- M1–M5: tested and verified on Oppo A95 (Android 13).
- Deferred items explicitly documented above.
