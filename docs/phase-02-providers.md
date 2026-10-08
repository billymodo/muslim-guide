# Phase 02 — Application Providers (Task 4)

Status: IMPLEMENTED
Last updated: 2026-10-08

## Scope

The Riverpod providers of `lib/features/prayer/application/` wiring the pure
domain (Task 1), the cities data (Task 2), and the location service
(Task 3) to the screens (Task 5). Riverpod 2.6.1 Classic, no code
generation (DEC-0002, DEC-0016).

## Provider matrix

| Provider | Kind | Lifecycle | State | Depends on |
|---|---|---|---|---|
| `locationServiceProvider` | `Provider` | keepAlive | `LocationService` | `GeolocatorLocationService` |
| `citiesLoaderProvider` | `Provider` | keepAlive | `CitiesLoader` | root asset bundle |
| `locationProvider` | `Notifier` | keepAlive | `LocationSelection?` | `SettingsRepository` (Hive) |
| `calculationMethodProvider` | `Notifier` | keepAlive | `CalculationMethod` | `SettingsRepository` |
| `asrMethodProvider` | `Notifier` | keepAlive | `AsrMethod` | `SettingsRepository` |
| `highLatitudeRuleProvider` | `Notifier` | keepAlive | `HighLatitudeRule` | `SettingsRepository` |
| `prayerTimesProvider` | `AsyncNotifier` | autoDispose | `PrayerTimesResult?` | location, 3 settings, cities, repository |
| `countdownProvider` | `StreamProvider` | autoDispose | `Duration` | `prayerTimesProvider` |

Rules of thumb: keepAlive for settings and shared state, autoDispose for
derived or expensive state. `null` from `prayerTimesProvider` means the
Empty state (no location selected).

## Decisions (approved 2026-10-08)

1. **Six providers** — `asrMethodProvider` and `highLatitudeRuleProvider`
   added on top of the four originally listed, because the phase scope
   covers the Asr school and the high-latitude rule as settings.
2. **Minimal repository** — `PrayerTimesRepository` /
   `PrayerTimesRepositoryImpl` isolate Application from Domain (isolation
   only; no caching, no I/O), as required by `phases/02.md` §Architecture.
3. **GPS timezone via nearest city** — a `CoordinatesSelection` resolves
   `timeZoneId` from the nearest bundled city within 500 km
   (`maxNearestCityDistanceKm`); beyond that the device timezone
   (`tz.local`) is used, falling back to `Asia/Riyadh` on failure
   (DEC-0029). `flutter_timezone` stays out until CR-0010 is approved.
4. **Persistence in Hive** — `SettingsRepository` gained five fields
   (`selectedCityId`, `selectedCoordinates`, `calculationMethod`,
   `asrMethod`, `highLatitudeRule`) with DEC-0028 defaults (MWL, Standard,
   MiddleOfNight).

## Design notes

- **Hydration**: notifiers start at their default, read the persisted
  value in `build()` (gated on `hiveStoreProvider` so pre-bootstrap reads
  defer until storage exists), and skip hydration once the user has
  changed the value (`_touched`) or the provider was disposed
  (`_disposed`). Hydration failures are logged with `dart:developer`;
  persistence failures propagate to the caller while the in-session value
  stays active.
- **Recalculation**: `prayerTimesProvider` watches the location and the
  three settings, so changing any of them recomputes the times; screens
  trigger pull-to-refresh with `ref.invalidate(prayerTimesProvider)`.
  The calculation date is the current date in the *location's* timezone.
- **Countdown**: `Timer.periodic(1s)` driving a `StreamController`,
  created only while a next prayer exists. The remainder is recomputed
  from `DateTime.now()` on every tick (no accumulation drift). A
  `WidgetsBindingObserver` stops the ticker whenever the app leaves the
  resumed state and restarts it on resume; `ref.onDispose` cancels the
  timer and closes the controller. When all of today's prayers have
  passed the stream stays empty.
- **Repository**: `PrayerTimesRepository.calculate(...)` mirrors
  `PrayerCalculator.calculate(...)` one-to-one.

## Tests

`test/features/prayer/application/` plus the extended
`test/data/settings/settings_repository_test.dart`:

- `location_provider_test.dart` — 8 cases (defaults, select/clear,
  persistence, hydration, city-over-coordinates precedence).
- `prayer_times_provider_test.dart` — 8 cases (Empty, city calculation,
  recalculation on method change, unknown-city error, settings defaults
  and persistence, `resolveLocationData` matrix).
- `countdown_provider_test.dart` — 5 cases (`nextPrayerTime`, per-second
  emission, background pause/resume, empty streams).
- `settings_repository_test.dart` — 4 cases including the five new
  fields.

## Deviations from specification

- The architecture tree and Files Expected were extended with the two
  repository files and the four extra provider files (decisions 1–2).
- `flutter_timezone` (CR-0010) is not part of Task 4; the nearest-city
  strategy replaces it until the CR is approved.
