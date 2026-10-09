# Defect Register

> **ملاحظة:** النطاق المعتمد هو D-01 الى D-25.

## 6.1 تناقضات داخل الوثائق

| ID | المشكلة | العلاج | الحالة |
|---|---|---|---|
| D-01 | "15 قرارا" مقابل "العشرة" | توحيد الصياغة | RESOLVED |
| D-02 | حلقة دائرية في المرفقات | المرفقات = CONSTITUTION + المرحلة | RESOLVED |
| D-03 | Phase 00 تبني واجهات | Phase 00 = قرارات + هيكل فارغ | RESOLVED |
| D-04 | Hive boxes للمحتوى | Hive لبيانات المستخدم فقط | RESOLVED |
| D-05 | لا محتوى في DB | لا يكتب المحتوى الثابت في DB المستخدم | RESOLVED |
| D-21 | قالب بلا انحرافات | أضيف قسم Deviations | RESOLVED |

## 6.2 قرارات معمارية

| ID | المشكلة | العلاج |
|---|---|---|
| D-06 | Hive + drift = over-engineering | Hive فقط، drift في OD-0002 |
| D-07 | Quran JSON واحد | OD-0003 بقياس فعلي |
| D-08 | تطبيع البحث متأخر | OD-0004 قبل Phase 06 |
| D-22 | أرقام إصدارات من الذاكرة | تحقق من pub.dev |

## 6.3 المحتوى والتراخيص

| ID | المشكلة | العلاج |
|---|---|---|
| D-09 | Amiri vs Amiri Quran | توثيق الاسم الدقيق + OFL |
| D-10 | مصدر التلاوة | OD-0007 |
| D-19 | المراجع الشرعي غير محدد | content/reviewers.yaml |
| D-20 | تحقق بعدد السور فقط | عدد الآيات + checksum |
| D-25 | تراخيص pending | GeoNames APPROVED 2026-10-08 · PrayTimes APPROVED — FIXED |

## 6.4 مخاطر تقنية

| ID | المشكلة | العلاج |
|---|---|---|
| D-11 | الإشعارات عالية الخطر | Phase 00B Spike |
| D-12 | دقة المواقيت | حالات حدية + OD-0005 |
| D-13 | الوصولية في 27B فقط | بنود في كل مرحلة |
| D-14 | لا telemetry | سجل محلي (OD-0010) |
| D-15 | نقص منتج | OD-0006, OD-0009 |
| D-16 | لا آلية migrations | OD-0008 |
| D-17 | home widgets | OD-0017 |
| D-18 | لا تقدير جهد | أحجام S/M/L |
| D-23 | شبكة بلا تحقق | CI |
| D-24 | fatal-infos | CI |
| OD-0028 | Asr systematic shift −2/−3m across cities, −8m Tromsø | **CLOSED — accept-as-known-limitation (2026-10-09)** — no calculator defect (app == PrayTimes.js v2.5 golden, 0s × 12/12); offset is Aladhan-side (low-sun divergence ∝ zenith + unstable refs); reproducible Tromsø −4m within ±5m — `docs/od-0028-asr-investigation.md` |

## Phase 02 — Device Testing Bugs

> المصدر: `docs/phase-02-device-testing.md` — Rule 011 (Evidence Required).
> BUG-2 مسجَّل — **OPEN** (P2) — Option C approved 2026-10-09.

| ID | Bug | Severity | Found In | Status | Evidence |
|---|---|---|---|---|---|
| BUG-1 | `major_cities.json` — mojibake في `name_ar`/`country_ar` (double-UTF-8 عبر cp1256) | P1 | T2 — Oppo A95 (2026-10-09) | **FIXED in `c88cc97`** — verified | استبدال جراحي 234 قيمة؛ diff ‎234±234؛ checksum محدّث في `legal/assets.yaml` ‎(sha256:3eedc611…)؛ تحقق بصري: دبي/أبوظبي/لندن/ترومسو ✓ |
| BUG-3 | Cold-start deep link يتجاوز bootstrap في `/splash` → `selectCity` يرمي «Settings are unavailable before app initialization» (فشل صامت بلا تنقل) | P1 | T2 — Oppo A95 (2026-10-09) | **FIXED in `4ba60bd`** — analyze ✅ tests 256/256 | logcat `E flutter` 09:31:01 — `location_provider.dart:110` + `bootstrap_provider.dart:16`؛ **الإصلاح:** بوابة `bootstrapProvider` في `_AppBootstrap` (`lib/main.dart`) قبل بناء router — كل مسار (deep link / cold start / splash) ينتظر اكتمال bootstrap؛ شاشات loading وerror+retry بنفس ARB keys |
| BUG-4 | اختيار الإنجليزية في Onboarding لا يُطبَّق؛ `/prayer` يظل عربياً (تعذر الوصول لمسار LTR) | P1 | T8b — Oppo A95 (2026-10-09) | **FIXED in `cedbbac`** — analyze ✅ tests 257/257 | `docs/evidence/phase-02/t8-06-en-selected.png` مقابل `t8-07-empty-en-ltr.png`؛ **الإصلاح:** `MuslimGuideApp` تستهلك `appLocaleProvider` (ConsumerWidget) + `LanguageSelectionScreen` تحدّثها فور حفظها في Hive |
| BUG-2 | No UI path to change city after successful load | P2 | T7-02 — Oppo A95 (2026-10-09) | **FIXED in `fc2e479`** — device-verified 2026-10-09 (Step 0 PASS) | Registered 2026-10-09; Option C approved؛ **إثبات الجهاز:** `t-bug2-01..04` (4 صور) — زر `clickable=true` → picker → كابل: كل الصفوف أُعيد حسابها → settings `enabled=false`؛ logcat نظيف |
| BUG-5 | Splash deadlock — bootstrap gate (`4ba60bd`) causes splash to never navigate when bootstrap already complete (normal startup broken; only deep link works) | P0 | T0 — Oppo A95 (2026-10-09) | **FIXED in `862376e`** — analyze ✅ tests 262/262 | `t-bug2-00-fail-splash-deadlock.png` + logcat؛ regression test في `splash_screen_test.dart` |
| BUG-6 | Location picker opened via `context.go` from Prayer hero — no AppBar back button; system BACK exits app instead of returning to /prayer | P3 | M5 — Oppo A95 (2026-10-09) | **OPEN** (backlog — Phase 05+) | `t8c-03` observation + report M5 deviation #2 |

## Known Gaps (pre-Phase 03)

| ID | Gap | Severity | Found In | Status |
|---|---|---|---|---|
| GAP-meta-caret | `meta: ^1.15.0` يستخدم `^` بدل exact pin — Rule 019 audit | P3 | Pre-existing | **CLOSED (this commit — follows f44ffc9)** — Pinned to 1.18.3 exact (Rule 019). |
| GAP-license-page | لا يوجد `showLicensePage`/`LicenseRegistry` في `lib/` — سياسة `legal/02-attribution-policy.md` تتوقع عرض تراخيص الحزم (مثل flutter_timezone Apache-2.0) | P3 | CR-0010 review (2026-10-09) | **OPEN** (Phase 05+ — قرار Decisions 5؛ LICENSES.md + legal/CI يكفيان مؤقتاً) |
| GAP-compass-maintenance | flutter_compass 0.8.1 — maintenance stopped ~23 months; migration to sensors_plus if critical | P3 | CR-0011 (Phase 03) | **OPEN** (Phase 05+ audit) |
| GAP-hive-patch | hive_ce 2.20.1 → 2.20.2 patch upgrade | P3 | Phase 03 Task 2 | **CLOSED (this commit — follows f44ffc9)** |
| GAP-compass-pinned | flutter_compass 0.8.1 (MIT, exact) — added to pubspec | — | CR-0011 (Phase 03) | **CLOSED (this commit)** |
| GAP-city-resolution-dup | cityId → coordinates resolution duplicated in QiblaNotifier (copied from location_provider) | P3 | Phase 03 Task 6 | **OPEN (Phase 05+ refactor)** |
| GAP-qibla-bg | `assets/images/qibla_bg.webp` — license TBD — deferred | P3 | UI_VISION §4 (PROPOSED) | **OPEN** (Phase 05+ — UI polish؛ Phase 03 يستخدم gradient placeholder) |
| GAP-deeplink-consolidation | Deep-link intent filters path-specific (`/prayer`, `/qibla`); consider wildcard or production scheme | P3 | Phase 03 Task 10 | OPEN (Phase 04+) |
