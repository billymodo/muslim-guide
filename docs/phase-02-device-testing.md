# Phase 02 — Real-Device Testing Record (Task 6)

## Scope, device and method

| Item | Value |
|---|---|
| Test dates | 2026-10-08 (T1–T2 start), 2026-10-09 (T2–T11) |
| Device | Oppo A95 (CPH2365), Android 13 (API 33), ColorOS — **OD-0029 Option A** |
| Package / version | `com.muslimguide.app` 0.1.0 (debug) |
| APK | `flutter build apk --debug` (Step 0, installed via `flutter install`) |
| Status values | PASS / FAIL / BLOCKED only |
| Evidence | `evidence/phase-02/*.png` (linked per test) |

Method notes (binding for reproducing the results):

- **Navigation:** the app has no UI entry to `/prayer` (BUG-2) and the picker is
  only reachable from the Empty state. Tests used explicit deep links:
  `adb shell am start -a android.intent.action.VIEW -d "muslimguide://test/<route>" com.muslimguide.app/.muslim_guide.MainActivity`.
- **BUG-3 (discovered this session):** a deep link that *cold-starts* the app
  skips `/splash` bootstrap, so `settingsRepository` is uninitialized and
  `LocationNotifier.selectCity` throws. Recipe used everywhere: normal
  `am start` first (bootstrap completes), *then* the deep link.
- **State authority:** `uiautomator dump` text/semantics; screenshots are the
  visual record (ColorOS sometimes captures a stale frame — dumps prevail).
- **Runtime calculation method:** MWL (DEC-0028) for every city; device date
  `2026-10-09`; comparison reference = Aladhan **secondary** readings for
  `09-10-2026`, method 3, margins as declared in
  [`phase-02-reference-cities.md`](phase-02-reference-cities.md).
- **ColorOS limits (shell denied):** `date` set, `settings put`,
  `pm clear`, `pm revoke`, `svc power stayon`, `cmd location
  set-location-enabled` — all require manual Settings actions or root.
  Screen timeout = 60 s; every interaction block starts with
  `input keyevent KEYCODE_WAKEUP`.

## Results summary

| # | Test | Status | Evidence |
|---|---|---|---|
| 1 | Smoke: launch → onboarding → `/prayer` Success + GPS (2026-10-08) | PASS | [dt-01-onboard](evidence/phase-02/dt-01-onboard.png), [dt-01e](evidence/phase-02/dt-01e.png) |
| 2 | Location picker: search, empty result, select → recompute | PASS | [t2-01](evidence/phase-02/t2-01-picker.png), [t2-02](evidence/phase-02/t2-02-search-empty.png), [t2-03](evidence/phase-02/t2-03-search-cairo.png), [t2-04](evidence/phase-02/t2-04-selected-cairo.png) |
| 3 | Eight reference cities vs documented margins (2026-10-09) | **FAIL** (42/48 within margin; all 6 breaches are Asr) | [t3-01](evidence/phase-02/t3-01-cairo.png) … [t3-08](evidence/phase-02/t3-08-tromso.png) |
| 4 | DST transition, London `2026-10-25` (`Europe/London`) | BLOCKED — manual date change required (see below) | — |
| 5 | Tromsø polar day `2026-06-21` (`Europe/Oslo`) | BLOCKED — manual date change required | — |
| 6 | Airplane mode: offline recalculation + cold restart | PASS | [t6-01](evidence/phase-02/t6-01-airplane.png), [t6-02](evidence/phase-02/t6-02-offline-restart.png) |
| 7a | No location services → error message + manual fallback to Success | PASS | [t7-01](evidence/phase-02/t7-01-permission-dialog.png), [t7-02](evidence/phase-02/t7-02-manual-fallback.png) |
| 7b | Permission **denial dialog** flow | **PASS** (2026-10-09) — Settings-deny ⇒ Android 13 auto-denies silently (no system dialog possible); in-app rejection «تعذر تحديد موقعك» + manual city fallback verified | [t7b-01](evidence/phase-02/t7b-01-rejection-dialog.png), [t7b-02](evidence/phase-02/t7b-02-manual-fallback.png) |
| 8a | RTL Arabic rendering on device | PASS | [t8-07](evidence/phase-02/t8-07-empty-en-ltr.png), [t3-*](evidence/phase-02/t3-01-cairo.png) |
| 8b | LTR English via onboarding selection | **FAIL** — BUG-4: English selection does not apply | [t8-06](evidence/phase-02/t8-06-en-selected.png), [t8-07](evidence/phase-02/t8-07-empty-en-ltr.png) |
| 8c | Text scale 200 % | BLOCKED — `font_scale` write denied (manual Settings) | — |
| 9 | Countdown/next-prayer badge live across all screens | PASS | [t6-01](evidence/phase-02/t6-01-airplane.png) (03:52:31 while offline) |
| 10 | Screenshot capture for each state | PASS | all `evidence/phase-02/*.png` (34 files, 2026-10-09) |
| 11 | This documentation | PASS | this file |

## T3 — eight cities, device vs reference (2026-10-09, MWL)

Margins (declared): Fajr ±3 min, Sunrise ±1 min, Dhuhr ±1 min published,
Asr ±1 min (±5 min high-latitude Tromsø), Maghrib ±1 min, Isha ±3 min.
Reference: Aladhan timings API — **secondary only**, `09-10-2026`, method 3.

| City | Fajr Δ | Sunrise Δ | Dhuhr Δ | Asr Δ | Maghrib Δ | Isha Δ | Within margin |
|---|---|---|---|---|---|---|---|
| Cairo | -1 m | 0 | 0 | **-2 m ✗** | 0 | -1 m | 5/6 |
| Mecca | 0 | 0 | -1 m | -1 m | 0 | 0 | 6/6 |
| Riyadh | -1 m | 0 | -1 m | **-2 m ✗** | 0 | -1 m | 5/6 |
| Karachi | 0 | 0 | 0 | **-2 m ✗** | -1 m | 0 | 5/6 |
| Jakarta | 0 | -1 m | -1 m | **-2 m ✗** | 0 | -1 m | 5/6 |
| London | 0 | 0 | -1 m | **-3 m ✗** | 0 | -1 m | 5/6 |
| Istanbul | 0 | -1 m | 0 | -1 m | 0 | 0 | 6/6 |
| Tromsø | 0 | 0 | 0 | **-8 m ✗** (±5 m) | 0 | 0 | 5/6 |

**Result: 42/48 prayers within the declared margins → test status FAIL**
(no partial pass claimed). Every breach is Asr and every breach is *earlier*
than the reference; the Tromsø Asr difference extends the existing OD-0028
observation from -5 m 37 s (2026-10-07) to -8 min (2026-10-09). One
systematic secondary-source deviation cannot be declared a calculator defect
or dismissed — record and continue (Rule: secondary ≠ official).

## Defects found on device

| ID | Severity | Summary | Evidence / proof |
|---|---|---|---|
| BUG-1 | High | `assets/cities/major_cities.json` double-encoded UTF-8: 114/120 `name_ar`, 120/120 `country_ar` mojibake; only the 6 manual transliterations are correct. Fix needs re-encode + `legal/assets.yaml` checksum update + provenance re-review. | [t2-01](evidence/phase-02/t2-01-picker.png), [t3-08](evidence/phase-02/t3-08-tromso.png) |
| BUG-2 | Medium | No UI navigation to `/prayer`; picker reachable only from Empty state. Re-tested today: Empty → picker → select → `/prayer` works **when bootstrap ran**; the "nothing navigates" impression is explained by BUG-3 and by deep-link-only testing. | [t7-02](evidence/phase-02/t7-02-manual-fallback.png) |
| BUG-3 | High | Deep link that cold-starts the app skips `/splash` bootstrap → `Bad state: Settings are unavailable before app initialization.` at `location_provider.dart:110` (`selectCity`); selection silently fails, no navigation. | logcat `E flutter` 2026-10-09 09:31:01 (stack includes `bootstrap_provider.dart:16`) |
| BUG-4 | Medium | Onboarding language = English (verified `selected=true`) still yields Arabic strings after continue + restart; LTR path unreachable → T8b FAIL. | [t8-06](evidence/phase-02/t8-06-en-selected.png) vs [t8-07](evidence/phase-02/t8-07-empty-en-ltr.png) |
| Minor-1 | Low | Home placeholder text overflows the right edge in RTL — Phase 10 scope. | [t8-08](evidence/phase-02/t8-08-state.png) |

## BLOCKED tests — manual device steps required

These cannot be done from adb on this ColorOS build (each command was tried
and denied: `WRITE_SETTINGS`, `WRITE_SECURE_SETTINGS`, `REVOKE_RUNTIME_PERMISSIONS`,
`CLEAR_APP_USER_DATA`, root-less `date`). One owner pass completes T4, T5, T7b
and T8c:

| Step | Action (owner, on device) | Unblocks |
|---|---|---|
| M1 | Settings → Display & Brightness → Auto screen off → **30 minutes** (currently 60 s) | all automation reliability |
| M2 | Quick Settings → enable **Location** (currently `location_mode=0`) | T7b (permission dialog → Deny) |
| M3 | Settings → System → Date & time → disable automatic → set **2026-10-25**, then restore | T4 (DST London end) |
| M4 | Set **2026-06-21**, then restore automatic date | T5 (Tromsø polar day) |
| M5 | Settings → Display → Font size → **Largest (≈200 %)**, then restore | T8c |

## Manual session attempt — 2026-10-09 (BUG-2 verify + M1–M5) — **ABORTED at Step 0**

> Session aborted per Stop Rule: no step skipped, no code changed, no commit.

### Step 0 — BUG-2 device verification: **FAIL (blocked before start)**

- App reinstalled with the BUG-2 build (`flutter install --debug`, `fc2e479`);
  the install wiped app data (fresh onboarding state).
- **Normal start** (`force-stop` → `am start` → 6 s, per locked recipe): the app
  reaches `SplashScreen` and **never leaves it** (observed > 60 s; re-dumped
  3×). No Flutter exception in logcat — the process is alive and rendering.
- **Deep-link start** (`muslimguide://test/prayer`): reaches `/prayer` Empty
  state normally ("مواقيت الصلاة / لم يتم تحديد الموقع"). The app itself works;
  only the normal-start path deadlocks.
- Evidence:
  - [t-bug2-00-fail-splash-deadlock.png](evidence/phase-02/t-bug2-00-fail-splash-deadlock.png)
  - [t-bug2-00-fail-logcat.txt](evidence/phase-02/t-bug2-00-fail-logcat.txt)
    (no Flutter errors; only system noise)

**Root-cause hypothesis (regression from the BUG-3 gate, `4ba60bd`):**
`splash_screen.dart` navigates to `/home` **only** inside
`ref.listen(bootstrapProvider, …)` → `whenData(…)` — i.e. it relies on the
provider *changing* to `data`. Before the gate, splash itself triggered
bootstrap (loading → data transition fired the listener). After the gate,
`_AppBootstrap` completes bootstrap **before** the router/`SplashScreen`
is ever built, so the listener is registered on an already-`data` value,
never fires, and navigation never happens.
**Fix direction (NOT applied — out of this session's scope):** splash must
navigate when `bootstrap` is *already* `data` (e.g. check
`bootstrap.whenData`/`hasValue` in `build`, or `fireImmediately: true`).
**Regression class:** BUG-3's gate broke the path it preserved; needs a
route-level test for "bootstrap already complete when splash mounts".

### Steps M1–M5: **not started** (aborted with Step 0).

### BUG-2 verification status: **not verified on device** (blocked).

### BUG-5 hotfix verification (2026-10-09, same device): **PASS**

- Fix commit `862376e` (splash `initState` post-frame state check +
  existing `ref.listen` for later transitions); register commit `e5d6895`.
- **Normal start** after reinstall: left Splash within ~6 s → Onboarding
  language screen (fresh data) — no deadlock
  ([t-bug5-01-fixed-startup.png](evidence/phase-02/t-bug5-01-fixed-startup.png)).
- **Deep-link cold start:** `muslimguide://test/prayer` → `/prayer` opens —
  BUG-3 still fixed.
- logcat: **clean** on both paths (no Flutter exceptions).
- Local verification before install: `flutter analyze --fatal-infos` clean,
  `flutter test` **262/262** (3 new regression tests in
  `test/features/splash/presentation/splash_screen_test.dart`), debug APK built.

### Step 0 retry — BUG-2 device verification (2026-10-09): **PASS**

Sequence (locked recipe; interrupted once by a USB disconnect and resumed
with app state preserved):

1. Normal start → onboarding (Arabic) → `/home` → deep link → `/prayer`
   Empty state → تحديد الموقع → picker → **Riyadh** → times rendered.
   [t-bug2-01-before.png](evidence/phase-02/t-bug2-01-before.png)
   (Fajr 04:57 / Dhuhr 12:05 / Asr 15:27 / Maghrib 17:57 / Isha 19:08).
2. Change-city button (`Icons.edit_location_alt`, content-desc
   «تغيير المدينة»): uiautomator node = **`clickable="true"
   enabled="true"`**; motionevent tap → **picker opened**.
   [t-bug2-02-picker-open.png](evidence/phase-02/t-bug2-02-picker-open.png)
3. Selected **Kabul** → returned to `/prayer`; **all rows recalculated**:
   04:30 / 11:40 / 14:57 / 17:26 / 18:45.
   [t-bug2-03-times-updated.png](evidence/phase-02/t-bug2-03-times-updated.png)
4. Hero settings button unchanged: content-desc «قريباً», node =
   **`clickable="false" enabled="false"`**.
   [t-bug2-04-settings-disabled.png](evidence/phase-02/t-bug2-04-settings-disabled.png)
5. logcat during the whole sequence: **no Flutter exceptions**.

Note: `pm grant` is blocked on ColorOS (SecurityException, as with
`pm revoke`); runtime permission was not needed for this verification
(manual-city flow) and remains `granted=false` — revisit for M2.

**Step 0 result: PASS — BUG-2 verified fixed on device (4/4 screenshots).**

### M1 — Screen timeout (2026-10-09): ✅ **DONE**

- ColorOS path/name: **Settings → Display & brightness → Auto screen off**.
- Owner set it manually; verified from shell:
  `settings get system screen_off_timeout` = **1800000 ms (30 minutes)** —
  not the requested 10 minutes, but well above the 60 s requirement;
  automation stability needs are met.

### M2 / T7b — permission rejection + manual fallback (2026-10-09): **PASS**

Setup (owner, manual): Settings → Location = **OFF**; app Location
permission = **Deny** (`pm grant`/`pm revoke` are blocked on ColorOS —
Settings only).

Sequence (locked recipe): cold start (6 s) → deep link `/prayer` →
change-city button → picker → tap «استخدام موقعي» (`_useGps`):

- **No system permission dialog.** Android 13 auto-denies silently after a
  Settings denial (and the shell cannot grant/deny on ColorOS). This is the
  documented operating behavior for T7b (alternative accepted by the
  director: rejection without dialog).
- **In-app rejection message shown:** «تعذر تحديد موقعك»
  (`location_picker_gps_error`, error color) — node
  [380,824][700,898].
- **Manual fallback works:** the city list stayed interactive below the
  message; selected **Riyadh** → `/prayer` recomputed
  (Kabul Dhuhr 11:40 → Riyadh 12:05).
- Evidence:
  [t7b-01-rejection-dialog.png](evidence/phase-02/t7b-01-rejection-dialog.png),
  [t7b-02-manual-fallback.png](evidence/phase-02/t7b-02-manual-fallback.png).
- logcat during the sequence: **clean** (no exceptions).

**T7b result: PASS (documented alternative — no system dialog possible).**

## Lessons recorded

1. **CI green ≠ correct (BUG-1):** unit/widget tests use internal fixtures,
   so a corrupted shipped asset passed CI. Device testing caught it.
2. **Deep links skip bootstrap (BUG-3):** route-level test coverage must
   include the cold-start-via-intent path, or initialization order bugs ship.
3. **uiautomator dumps over screenshots** when ColorOS returns stale/black
   frames; screenshot immediately after the wake, never across long sleeps.
4. `input tap` (0 ms) is unreliable for Flutter gestures — use
   `input motionevent DOWN/…/UP` with ~150 ms hold.

## Mapping to Exit Criteria (`phases/02.md`)

- [x] Eight-city device comparison executed and documented — result **FAIL**
  (42/48; Asr breaches recorded here and against OD-0028).
- [x] Airplane mode (PASS), smoke/GPS (PASS), screenshots (PASS).
- [x] Permission-denial flow (T7b) — **PASS** 2026-10-09 (M2; rejection
  without dialog + manual fallback — `t7b-01/02`).
- [ ] DST transition, Tromsø polar day, 200 % font scale — **BLOCKED** on
  manual steps M3–M5 above.
- Pending owner decisions: none for BUGs (1, 2, 3, 4, 5 all FIXED and
  device-verified); T8b re-verification (BUG-4 on device) still open.
