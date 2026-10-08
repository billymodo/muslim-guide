# Session Handoff Log

> **سجل تراكمي. آخر إدخال في الأعلى.**
> لا تحذف الإدخالات القديمة — هي ذاكرة المشروع.

---

## Session 16 — 2026-10-08 (Phase 02: Task 5 — Screens)

### ما نُفِّذ
- 23 مفتاح ARB (`prayer_*` + `sunrise_not_prayer` + `location_picker_*` +
  `prayer_settings_coming_soon`) + `flutter gen-l10n`
- 3 widgets:
  - `PrayerTimeRow` — 4 حالات (عادي/التالي/null/ملاحظة) + Semantics موحّد
  - `CountdownTimer` — ConsumerWidget، `HH:MM:SS`، ورسالة "لا صلاة قادمة اليوم"
  - `PrayerHeroCard` — gradient + اسم المدينة + countdown + settings
- `PrayerTimesScreen` (ConsumerWidget): 5 حالات + pull-to-refresh + RTL/LTR +
  text scale 200%
- `LocationPickerScreen` (ConsumerStatefulWidget): بحث فوري + GPS + صلاحيات +
  رسائل خطأ
- Router: `/prayer` و `/location-picker`
- 25 widget tests (4+3+3+8+7) — إجمالي المشروع 256/256
- `nextPrayerTime` أصبح public (تتطلبه طبقة العرض)

### القرارات / الانحرافات (معتمدة من المدير في هذه الجلسة)
- MenuButton حُذف — Drawer مؤجل إلى Phase 10؛ settings في hero معطّل
  (Tooltip "قريباً")؛ زر "إعدادات التنبيه" معطّل حتى Phase 04
- CitySelection → اسم المدينة من الحزمة؛ Coordinates → "الموقع الحالي"
- ARB: 21 مفتاحاً معتمداً + 2 (`location_picker_gps_error`,
  `prayer_settings_coming_soon`) = 23
- hero: gradient (صورة Haram TBD)
- حالات null (OD-0027): "غير متاح" — لا وقت بديل إطلاقاً
- أخطاء تحميل مدن الشاشة: `splash_error`/`splash_retry` (بلا مفتاح جديد)
- Dart 3.10: `const new(...)` لمنشئات widget (dart fix)

### للجلسة القادمة (Task 6 — Device Testing)
- Pixel 6a + Redmi Note 12: 5 مدن مرجعية، انتقال DST، وضع الطيران،
  رفض صلاحية الموقع، حالات القطبية
- بعد Task 6: Phase 02 ✅ → Phase 03 (Qibla)

### Commit
88a7081 — phase-02(task-5): prayer times + location picker screens (محلي، بلا push)

### Lessons (من هذه الجلسة)
- `find.byIcon` يعيد الـ`Icon` وليس `IconButton` — استخدم
  `find.ancestor(of: ..., matching: find.byType(IconButton))`
- SemanticsHandle: أغلقه يدوياً في نهاية جسم الاختبار؛ `addTearDown`
  يُنفَّذ بعد فحوصات flutter_test فيصبح التركيد نشطاً
- lint `unused_result` على `ref.refresh(...)`: `await` لا يكفي في هذا
  الإصدار — الحل: `.then<void>(...).catchError(...)`
- `const DateTime(...)` غير صالح (DateTime ليس const) — استخدم `DateTime(y, m)`
  غير const داخل `LocationResult`

---

## Session 15 — 2026-10-08 (Phase 02: Task 4 — Riverpod Providers)

### ما نُفِّذ
- 6 providers + 3 مساندة
  - locationServiceProvider, citiesLoaderProvider, prayerTimesRepositoryProvider
  - locationProvider (Notifier, keepAlive)
  - calculationMethodProvider (Notifier, keepAlive)
  - asrMethodProvider (Notifier, keepAlive)
  - highLatitudeRuleProvider (Notifier, keepAlive)
  - prayerTimesProvider (AsyncNotifier, autoDispose)
  - countdownProvider (StreamProvider, autoDispose + Timer)
- PrayerTimesRepository (interface) + Impl
- SettingsRepository: 5 حقول + 10 methods
- LocationSelection sealed class (City | Coordinates)
- GPS timezone via nearest city
- ~26 اختبار (231 إجمالي)
- commit 5c0f46a

### القرارات
- AutoDisposeAsyncNotifier (Riverpod 2.6 requirement)
- Hydration via hiveStoreProvider gate (avoid catch StateError)
- Riverpod 2.6 test gotchas documented

### للجلسة القادمة (Task 5)
Screens:
1. lib/features/prayer/presentation/screens/prayer_times_screen.dart
2. lib/features/prayer/presentation/screens/location_picker_screen.dart
3. lib/features/prayer/presentation/widgets/prayer_time_row.dart
4. lib/features/prayer/presentation/widgets/prayer_hero_card.dart
5. lib/features/prayer/presentation/widgets/countdown_timer.dart
6. Router update: /prayer route

**مهم:**
- countdownProvider stream فارغ بعد صلاة العشاء → شاشة يجب أن تعرض "لا صلاة قادمة اليوم"
- sunrise مستبعد من countdown (يُعرض بـsunrise_not_prayer)

### Commit
5c0f46a — Task 4

### Lessons (من الاختبارات)
- `container.listen` needs `fireImmediately: true` in Riverpod 2.6
- `pump()` without duration doesn't flush Riverpod tasks — `pump(100ms)` works
- Dispose container before testWidgets end

---

## Session 13 — 2026-10-07 (Phase 01: UI screens)

### ما نُفِّذ
- `splash_screen.dart` — خلفية gradient بلا تأخير اصطناعي، وتستمع إلى bootstrap.
- `language_selection_screen.dart` — اختيار AR/EN وحفظ اللغة في Hive.
- `router.dart` — ثلاثة مسارات مع منطق redirect.
- `home_placeholder.dart` — شاشة مؤقتة حتى Phase 10.
- `main.dart` — `ProviderScope` مع `MaterialApp.router`.
- `muslim_guide_app.dart` — واجهة presentational تستقبل router.
- إضافة `home_greeting` إلى ملفات ARB.
- إعادة هيكلة widget test؛ 7/7 اختبارات ناجحة.

### القرارات
- تأجيل Welcome Shell (SCREEN-003)؛ TODO في router.
- Splash يستخدم gradient لعدم توفر الصورة.
- `MuslimGuideApp` presentational لتبسيط الاختبار.

### Commit
- `e5e2f9c` — Phase 01 UI screens.

---

## Session 12 — 2026-10-07 (Phase 01: timezone + bootstrap)

### ما نُفِّذ
- أُضيفت `timezone 0.11.1` كتَبعية مباشرة مثبتة، ووُثّقت في سجلّي التراخيص
  والتبعيات.
- اعتُمد CR-0008، وسُجل OD-0025 لاكتشاف المنطقة الزمنية تلقائيًا قبل Phase 02.
- أُنشئ `bootstrap_provider.dart` لتهيئة Hive والترحيلات وسجل الأخطاء والمنطقة
  الزمنية، واستعادة لغة الواجهة المحفوظة.
- أُضيف `LocalErrorLog.init()` لإنشاء مجلد السجل، مع اختبار لذلك.
- أُصلح استيراد timezone واستخدام `.new` غير الضروري في `local_error_log.dart`.
- لم تُنفذ شاشات Splash أو اختيار اللغة أو Router أو `main.dart`؛ تظل الخطوة
  التالية بعد هذه الجلسة.
- `flutter analyze --fatal-infos`: بلا مشاكل؛ `flutter test`: 6/6؛
  `flutter build apk --debug`: نجح.

### القرارات
- timezone 0.11.1، BSD-2-Clause، مثبت بدقة — CR-0008.
- `Asia/Riyadh` مؤقتة حتى حسم OD-0025 قبل Phase 02.

### الملفات المتأثرة
- جديد: `governance/cr/CR-0008-timezone-package.md`,
  `lib/app/providers/bootstrap_provider.dart`.
- معدّل: `pubspec.yaml`, `pubspec.lock`, `LICENSES.md`,
  `security/02-dependencies.md`, `04-open-decisions.md`,
  `lib/core/logging/local_error_log.dart`,
  `test/core/logging/local_error_log_test.dart`.

### Commit
- `8baeb1c9fc89f51d43a1bbf955dcc6d2dd739e88` — timezone bootstrap؛
  `17457cf` — توثيق تقدم Phase 01.

### للجلسة القادمة
- تابع تنفيذ شاشات Phase 01 بعد مراجعة المدير: Splash، Language Selection،
  Router، و`main.dart`، إضافة إلى Home placeholder وARB keys حسب الموافقة.

---

## Session 11 — 2026-10-07 (Phase 01: UI foundation)

### ما نُفِّذ
- go_router 18.0.2 (BSD-3-Clause, exact pin).
- `l10n.yaml` + ملفات ARB للعربية والإنجليزية (11 مفتاحًا).
- `AppColors`, `AppSpacing`, `AppTypography`, و`AppTheme`.
- Material 3 مع ثيمي Light وDark؛ يدعم التطبيق اختيار System عبر `ThemeMode.system`.
- تفعيل توليد الترجمة عبر `flutter: generate: true`.
- `flutter analyze --fatal-infos`: بلا مشاكل؛ `flutter test`: 5/5؛
  `flutter build apk --debug`: نجح.

### القرارات
- go_router 18.0.2 (DEC-0003).
- رموز تصميم أولية قابلة للتوسع.

### الملفات المتأثرة
- جديد: `l10n.yaml`, `lib/l10n/app_ar.arb`, `lib/l10n/app_en.arb`.
- جديد: `lib/app/theme/app_colors.dart`, `app_spacing.dart`,
  `app_typography.dart`, `app_theme.dart`.
- معدّل: `pubspec.yaml`, `pubspec.lock`, `LICENSES.md`,
  `security/02-dependencies.md`.

### Commit
- `b4bed71fd0279fad44d6d4e27afaa46d4ecf182a` — UI foundation.

### للجلسة القادمة
ابدأ شاشات UI:
- `lib/features/splash/presentation/splash_screen.dart`
- `lib/features/onboarding/presentation/language_selection_screen.dart`
- `lib/app/router.dart`
- `lib/main.dart`
- راجع `docs/UI_VISION.md` §3 وتفاصيل onboarding قبل التنفيذ.

---

## Session 10 — 2026-10-06 (Phase 01: data layer)

### ما نُفِّذ
- اكتملت طبقة بيانات Phase 01 (5 ملفات):
  - `lib/data/storage/type_ids.dart` — سجل TypeAdapters، بلا typeIds معيّنة بعد.
  - `lib/data/storage/migrations.dart` — ترحيل schema بسيط ومُرقّم.
  - `lib/data/storage/hive_store.dart` — تهيئة Hive وإدارة الصندوق.
  - `lib/data/settings/settings_repository.dart` — اللغة وonboarding والثيم.
  - `lib/core/logging/local_error_log.dart` — سجل JSON Lines محلي.
- أُضيفت 4 ملفات اختبار data layer، والعدد الكلي مع اختبار الجذر 5 اختبارات.
- اعتُمد CR-0006 لـ`path_provider` في التطبيق الرئيسي، وصُحح OD-0006 (minSdk 24).
- أُضيفت تبعيات: `hive_ce`, `hive_ce_flutter`, `path_provider`, `intl`, `share_plus`.
- `flutter analyze --fatal-infos`: بلا مشاكل؛ `flutter test`: 5/5 ناجحة.
- CR-0007: `share_plus 13.3.1` هو أحدث إصدار مستقر، نُشر 2026-10-01. فشل 13.2.0 مع compileSdk 35، وفشل 11.1.0 مع AGP 9.1 بسبب class مسجل غير موجود؛ Android SDK 36 مثبت، وبناء APK نجح مع 13.3.1 وcompileSdk 36. التفاصيل موثقة في CR-0007.

### القرارات
- استخدام Riverpod Classic دون code generation في Phase 01.
- typeId مخصص لـTypeAdapters فقط؛ القيم البدائية تحفظ في `Box<dynamic>`.
- `compileSdk 36` وفق CR-0007، مع `minSdk 24` و`targetSdk 34`.
- إضافات إغلاق: `docs/PROJECT_STORY.md` (سياق المشروع)،
  `docs/DIRECTOR_PLAYBOOK.md` (أسلوب التوجيه)، و`.gitignore` (استثناء سجلات
  Spike الخام).

### ما للجلسة القادمة
- ابدأ طبقة UI: Splash وLanguage Selection.
- اقرأ `product/06-onboarding.md` و`product/02-screens.md`.
- استهدف SCREEN-001 وSCREEN-002 وSCREEN-003 shell.

### Commit
- `a7a71f5` — Phase 01 data layer (محلي).
- تُسجّل SHA الخاصة بالدفع بعد اكتماله.

---

## Session 9 — 2026-10-06 (Phase 00B: closure)

### ما نُفِّذ
- Step 5 closed: 6/6 core tests passed.
- DEC-0023 recorded for manual notification receiver declarations.
- DEC-0024 through DEC-0027 recorded for migrations, local error log, numerals, and Hive encryption.
- OD-0023 and OD-0024 remain open as Phase 04 deferrals.
- Phase 00B officially closed.
- Human Audio Verification: user manually tested and confirmed hearing the Beep; recorded in `spike/RESULTS.md`.

### Lessons Learned
1. `flutter_local_notifications` 22.x did not add the required receivers to the merged manifest in the tested setup.
2. ColorOS/Oppo may require Don't optimize, background-running, and auto-launch settings.
3. The `IsolateNameServer` + `SendPort` bridge keeps Hive operations in the main isolate.

### للجلسة القادمة (2026-10-07)
1. ابدأ Phase 01 بعد مراجعة الخطة والموافقة.
2. اقرأ `phases/01.md`.
3. تحقق من ODs المتبقية.
4. ابنِ Splash → Onboarding → Settings.
5. استخدم DEC-0024 إلى DEC-0027.

### Commit SHA
- Step 5: `9087c49`
- Session 9 closure: راجع أحدث commit في `main` بعد هذه الجلسة.

---

## Session 8 — 2026-10-06 (Phase 00B: step 3 pushed + step 4 approvals)

### ما نُفِّذ

**Step 3 — مدفوع ومُتحقق منه**

* commit `1a60965` (45 ملفًا) إلى `main` + فرع `test/ci-step-3` (`31bae1a`)
* **PR #2** → **run `37390142312` = success (9/9 jobs)**
* `tool/test_count_baseline.txt = 2` مع تعليق التبرير
* CR-0004 + CR-0005 مرفوعان + قائمة CRs في `03-decisions.md`

**Approvals للخطوة 4 (هذه الجلسة)**

* `path_provider` **exact 2.1.6** — داخل `spike/` فقط + توثيق (BSD-3-Clause)
* **VGA في spike**: `very_good_analysis 11.0.0` exact + حذف flutter_lints
* beep.wav: توليد ذاتي (440Hz sine، 2–3 ثوانٍ) — بلا تنزيل
* manifest spike فقط: service + receiver حرفًا من README audio_service

**بحث APIs (من مصادر الحزم المثبّتة — لا ذاكرة)**

* fln 22.3.1: `zonedSchedule(..., androidScheduleMode: exactAllowWhileIdle)` + `requestNotificationsPermission()` + `requestExactAlarmsPermission()`
* audio_service 0.18.19: `AudioService.init(builder:, config:)` + `BaseAudioHandler with QueueHandler, SeekHandler`
* just_audio 0.10.6: `AudioPlayer` + `setAsset()` + `LoopMode{off,one,all}`
* timezone 0.11.1: `package:timezone/data/latest.dart` + `TZDateTime.from(dt, tz.UTC)`
* hive_ce 2.20.1: `Hive.init(String? path)` — يحتاج path_provider
* (التفاصيل في `NEXT_SESSION.md`)

### ما توقف

* **بانتظار:** كتابة كود الخطوة 4 ثم `analyze/test/build` ثم إذن push
* **السبب:** قاعدة «لا تدفع حتى أرد» + Stop Rule 15 حُلّ بموافقة path_provider

### الملفات المتأثرة

جديد:

* (كود الخطوة 4 لم يُكتب بعد)

معدّل:

* `NEXT_SESSION.md`, `PHASE_PROGRESS.md`, `SESSION_HANDOFF.md` (هذا الإدخال)

### القرارات المتخذة

* path_provider مسموح داخل spike فقط ويُحذف معه
* VGA في spike (الخيار أ)
* لا OD جديدة

### للجلسة القادمة

1. كتابة `spike/lib/{main.dart, services/*, widgets/log_viewer.dart}` + `spike/test/*`
2. `cd spike && flutter pub get && flutter analyze --fatal-infos && flutter test && flutter build apk --debug`
3. اطلب إذن push — لا push قبله

---

## Session 7 — 2026-10-06 (Phase 00B: steps 1-3)

### ما نُفِّذ

**Step 1 — إنشاء `spike/`**

* مشروع Flutter مستقل داخل `spike/` (Android فقط)
* اسم: `muslim_guide_spike`
* 5 حزم exact (بلا `^`):

  * `flutter_local_notifications 22.3.1`
  * `timezone 0.11.1`
  * `hive_ce 2.20.1`
  * `audio_service 0.18.19`
  * `just_audio 0.10.6`
* 8 صلاحيات Android في manifest الـspike فقط
* `analysis_options.yaml` يستثني `spike/**`
* إصلاح build error: `isCoreLibraryDesugaringEnabled=true` + `desugar_jdk_libs:2.1.4`
* `spike/README.md`, `RESULTS.md`, `evidence/.gitkeep`

**Step 2 — CR-0004 + phases update**

* `governance/cr/CR-0004-audio-in-spike.md` (معتمد)
* `phases/00b-spike.md`: حذف بند iOS (N/A — deferred to v2.0)
* `spike/RESULTS.md`: قسم Build Issues

**Step 3 — CI jobs جديدة**

* 5 سكربتات في `tool/`:

  * `check_test_count.sh` (CI-012)
  * `check_no_print.sh` (CI-014)
  * `check_no_internet.sh` (CI-015)
  * `check_no_network_pkg.sh` (CI-016)
  * `check_no_placeholder.sh` (CI-017)
* `.github/workflows/ci.yml`: +5 jobs (SHA-pinned, ubuntu-24.04)
* `ci/01-ci-checks.md`: +عمود Phase
* `ci/00-ci-policy.md`: تحديث
* `legal/policy.yaml`: قسم `ci.exemptions`
* `.gitattributes`: `*.sh text eol=lf`
* `tool/test_count_baseline.txt = 2`
* `governance/cr/CR-0005-ci-job-names-expanded.md` (pending push)

### ما توقف

* **بانتظار:** push + PR تجريبي للتحقق من CI
* **السبب:** يجب التأكد من نجاح كل الـ9 jobs قبل الانتقال للخطوة 4

### الملفات المتأثرة

جديد:

* `spike/` (35+ ملف من flutter create + main.dart + test)
* `tool/*.sh` (5 سكربتات)
* `tool/test_count_baseline.txt`
* `governance/cr/CR-0004-*.md`, `CR-0005-*.md`
* `.gitattributes`

معدّل:

* `.github/workflows/ci.yml`
* `ci/00-ci-policy.md`, `ci/01-ci-checks.md`
* `legal/policy.yaml`
* `phases/00b-spike.md`
* `spike/android/app/src/main/AndroidManifest.xml`
* `spike/android/app/build.gradle.kts`
* `analysis_options.yaml` (الجذر)

### القرارات المتخذة

* baseline = 2 (العدّاد يحسب testID فريدة)
* SHA pinning إلزامي (Rule 019) — اقتراحي بـ `@v4` رُفض
* CR-0005 موثق (توسيع عقد أسماء CI)
* `spike/` معفى من CI-015/016/017

### للجلسة القادمة

1. `git add -A \&\& git commit` + `git push`
2. افتح PR تجريبي (`test/ci-step-3`)
3. راقب CI (9 jobs كلها ✅)
4. ابدأ Step 4 — بناء Spike كامل

---

## Session 6 — 2026-10-06 (Phase 00: closed)

### ما نُفِّذ

* تنفيذ كامل لـ Phase 00
* Flutter 3.47.5 مثبت, Dart 3.13.4
* `pubspec.yaml` + `pubspec.lock`
* `analysis_options.yaml` (very_good_analysis 11.0.0)
* `.github/workflows/ci.yml` (4 jobs: asset-scan, analyze, test, build-debug)
* `LICENSES.md`
* هيكل مجلدات + `.gitkeep`
* DEC-0014..0018
* إغلاق OD-0001/0006/0018/0019
* `approvals.yaml` محدّث
* `phases/00-foundation.md` (Status: APPROVED)
* `docs/phase-00-output-report.md`
* CI run: 37384176239 (success)

### القرارات

* MIT License
* Android only, minSdk 24, targetSdk 34
* Riverpod 2.6.1 (exact)
* Pixel 6a reference device
* Phase-Aware CI Rollout (Option A)
* applicationId: `com.muslimguide.app`

### CRs

* CR-0001: CI rollout
* CR-0002: Phase A → 00
* CR-0003: minSdk 24

---

## Session 5 — 2026-10-05/06 (MASTER_SPEC finalized)

### ما نُفِّذ

* إصلاح 5 ملفات بترميز مزدوج (CP1256 → UTF-8)
* اختبار 5 جولات فحص
* تجهيز MASTER_SPEC النهائي (70 ملف)

### القرارات

* Phase A = Phase 00 (توحيد التسمية)

---

## Session 4 — 2026-10-05 (MASTER_SPEC structure)

### ما نُفِّذ

* بناء هيكل `MASTER_SPEC/` كامل (70 ملف)
* 10 مجلدات فرعية
* شجرة كاملة

---

## Session 1-3 — 2026-10-04/05 (Planning)

### ما نُفِّذ

* تقييم `MASTER_ROADMAP v3.0`
* مراجعة `Master Specification` المقترح
* Audit شامل
* دمج `CONTENT_REGISTRY` مع `legal/assets.yaml`

### القرارات

* البنية الموزعة (لا وثيقة واحدة ضخمة)
* مصدر واحد لكل معلومة (Canonical Map)
* مراجع شرعي عبر HTML + JSON
* AR + EN مع اختيار عند التنصيب

---

## قالب الإدخال (للجلسات القادمة)

```markdown
## Session N — YYYY-MM-DD (Phase XX step Y)

### ما نُفِّذ
- ...

### ما توقف
- \*\*بانتظار:\*\* ...
- \*\*السبب:\*\* ...

### الملفات المتأثرة
جديد:
- ...

معدّل:
- ...

### القرارات المتخذة
- ...

### للجلسة القادمة
1. ...
2. ...





\---



\## 🎯 خطوات الحفظ



\### 1. احفظ الملفات الثلاثة



افتح Notepad (بترميز UTF-8) واحفظ كل ملف في:

C:\\Users\\Abdo\\Desktop\\Muslim\_Guide

├── NEXT\_SESSION.md

├── PHASE\_PROGRESS.md

└── SESSION\_HANDOFF.md



text



\### 2. commit + push



```powershell

cd C:\\Users\\Abdo\\Desktop\\Muslim_Guide

git add NEXT_SESSION.md PHASE_PROGRESS.md SESSION_HANDOFF.md

git commit -m "governance: add session continuity protocol (3 files)"

git push

3. تحقق من سلامة الملفات

powershell

# عدد الأسطر

Write-Host "NEXT_SESSION: $((Get-Content NEXT_SESSION.md).Count) lines"

Write-Host "PHASE_PROGRESS: $((Get-Content PHASE_PROGRESS.md).Count) lines"

Write-Host "SESSION_HANDOFF: $((Get-Content SESSION_HANDOFF.md).Count) lines"



# تأكد من عدم وجود تشويه عربي

Select-String -Path *.md -Pattern 'ط¸|ط§|â€' | Select-Object -First 5

المتوقع:



كل ملف > 50 سطر



لا نتائج للبحث العربي المشوّه
