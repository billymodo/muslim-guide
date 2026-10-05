# Output Report — Phase 00

التاريخ: 2026-10-05/06 — المنفّذ: AI agent — المعتمد: User (2026-10-05)

## 0. البيئة (ناتج حرفي)

```text
Flutter 3.47.5 • channel stable • https://github.com/flutter/flutter.git
Framework • revision 6a19cca564 (3 weeks ago) • 2026-09-17 14:13:22 -0400
Engine • hash ab598368592da0064197e2bc15c7f5b0a2c6bb1f (revision af7e796e16)
Tools • Dart 3.13.4 • DevTools 2.60.0
```

```text
Dart SDK version: 3.13.4 (stable) (Tue Sep 15 01:01:15 2026 -0700) on "windows_x64"
```

```text
flutter doctor: [√] Flutter / [√] Windows / [√] Android toolchain (Android SDK 36.0.0)
```

## 1. الملفات المنشأة

- `pubspec.yaml` + `pubspec.lock` (إصدارات مثبتة تمامًا، بلا `^` للحزم المعتمدة)
- `analysis_options.yaml` (include = very_good_analysis — DEC-0011)
- `.github/workflows/ci.yml` (بوابات: asset-scan → analyze → test → build-debug؛ أسماء jobs حسب عقد ci/00)
- `LICENSES.md` (كل حزمة + إصدار + ترخيص + أداة تحقق + تاريخ)
- `.fvmrc` (`3.47.5` — ADR-0001)
- `lib/main.dart` (جذر فارغ بلا شاشات + ProviderScope)
- `test/widget/root_widget_test.dart` (اختبار واحد)
- `android/**` (هياكل `flutter create` + تعديلات DEC-0015)
- `.gitignore` + ملفات IDE من `flutter create` (`.idea/`, `muslim_guide.iml`)
- هيكل المجلدات مع `.gitkeep` (23 ملفًا): `lib/{app,core,shared,features/{onboarding,settings,prayer,qibla,adhan,azkar,quran,recitation,hijri}}`، `test/{unit,integration}`، `assets/{content/{quran,azkar,dua},audio,images,fonts}`، `tool/`، `docs/`، `.github/workflows/`
- `governance/cr/CR-0001-phase-aware-ci-rollout.md` (معتمد)
- `governance/cr/CR-0002-phase-a-naming.md` (معتمد)
- `governance/cr/CR-0003-minsdk-24-proposal.md` (**بانتظار القرار**)
- `docs/phase-00-output-report.md` (هذا الملف)

## 2. الملفات المعدلة (+ السبب)

- `03-decisions.md` — أُضيفت DEC-0014 … DEC-0018 (Rule 002/014).
- `04-open-decisions.md` — أُغلق OD-0001/0006/0018/0019 → DEC-0014…0017؛ أُضيف OD-0021 (iOS).
- `05-conflicts-and-gaps.md` — GAP-009 → RESOLVED (DEC-0017) — Rule 014.
- `README.md` — `Phase A` → `Phase 00` (قرار بشري + CR-0002).
- `ci/00-ci-policy.md` — قسم Phase-Aware Rollout من PROPOSED → معتمد (DEC-0018).
- `ci/01-ci-checks.md` — عمود `Phase` لكل فحص (DEC-0018).
- `phases/00-foundation.md` — Status=ACTIVE، الاعتماد، CI Requirements محدّثة، تصحيح مرجع `DECISIONS.md`، تعبئة Deviations.
- `security/02-dependencies.md` — جدول التبعيات (Rule 007).
- `android/app/build.gradle.kts` — applicationId/compileSdk/targetSdk (DEC-0015) + توثيق تعارض minSdk.
- حُذف: `lib/main.dart` (counter demo من القالب) و`test/widget_test.dart` (اختبار counter) — شاشتان خارج النطاق.

**لم تُعدَّل:** `approvals.yaml` (Rule 020 — تعديل بشري فقط)، `legal/assets.yaml` (السجل الأولي موجود؛ التحديث إلى schema v2 شرط DEC-0018 قبل Phase 05)، `content/reviewers.yaml` (موجود).

## 3. Dependencies الجديدة

| الحزمة | الإصدار المتحقق | السبب | الترخيص |
|---|---|---|---|
| flutter_riverpod | 2.6.1 (pub.dev، نُشر 2024-10-22، تحقق 2026-10-05) | DEC-0002 + DEC-0016 | MIT |
| very_good_analysis | 11.0.0 (pub.dev، نُشر 2026-09-03، تحقق 2026-10-05) | DEC-0011 | MIT |

حُذفت من قالب `flutter create` (غير مدرجة في أي DEC): `cupertino_icons ^1.0.8`، `flutter_lints ^6.0.0`.
تبعيات غير مباشرة (23 حزمة): كلها موثقة بإصداراتها وتراخيصها في `LICENSES.md` §4 — أدلة: ملفات LICENSE داخل أرشيفات pub.dev + صفحات pub.dev.

## 4. ناتج flutter analyze (حرفيًا)

```text
Analyzing Muslim_Guide...
No issues found! (ran in 9.7s)
```

(التشغيل الأول وجد 4 infos → أُصلحت عبر `dart fix --apply --code=unnecessary_type_name_in_constructor` + إزالة نوع closure + أسطر نهائية. **لا `// ignore` إطلاقًا**.)

## 5. ناتج flutter test (حرفيًا)

```text
00:00 +0: .../test/widget/root_widget_test.dart
00:05 +1: الجذر يُبنى بلا استثناءات
00:05 +1: All tests passed!
```

عدد الناجح: 1
عدد الفاشل: 0

## 6. ناتج flutter build (حرفيًا)

```text
Running Gradle task 'assembleDebug'...
√ Built build\app\outputs\flutter-apk\app-debug.apk
```

دليل APK (aapt2 dump badging):

```text
package: name='com.muslimguide.app' versionCode='1' versionName='0.1.0' platformBuildVersionName='15' platformBuildVersionCode='35' compileSdkVersion='35' compileSdkVersionCodename='15'
minSdkVersion:'24'
targetSdkVersion:'34'
```

ناتج YAML check لـ ci.yml:

```text
ci.yml: YAML OK
```

## 7. تأكيد Offline

- [x] لا API — لا أي استدعاء شبكة في `lib/` (ملف واحد `main.dart` بلا أي import شبكة).
- [x] لا شبكة — لا حزمة شبكة في `pubspec.yaml` ولا في `pubspec.lock` (المستضيف: flutter_riverpod وحدها؛ لا `http`/`dio`/`web_socket`). Rule 008 محفوظة.
- [ ] وضع الطيران — **لم يُختبر** (لا جهاز موصول لاختبار فعلي الآن؛ فحص release manifest مמחוّب لـ CI-015 المؤجل — 00B→04).

## 8. معايير القبول

| المعيار | النتيجة | الدليل |
|---|---|---|
| `flutter analyze --fatal-infos` بلا مخرجات | نجح | §4 — "No issues found!" |
| `flutter test` ينجح | نجح | §5 — "All tests passed!" (+1) |
| `flutter build apk --debug` ناجح | نجح | §6 — "√ Built ... app-debug.apk" |
| CI يعمل على PR تجريبي | **لم يتحقق** | المجلد ليس git repo ولا remote — يتطلب git init + push + PR من المستخدم (Stop Rule 17) |
| كل حزمة لها إصدار متحقق وترخيص وسبب | نجح | `LICENSES.md` + `security/02-dependencies.md` Register |

## 9. انحرافات عن المواصفة

- ما لم يُنفَّذ: `release.yml` (يُنشأ Phase 09 — قرار بشري)؛ «CI على PR تجريبي» (بيئة بدون git/remote)؛ الفحوصات الأسبوعية المجدولة (مؤجلة ضمن DEC-0018).
- ما نُفِّذ بشكل مختلف: نطاق CI = CI-002/009/010/011/018 بدل CI-001…018 (DEC-0018 / CR-0001)؛ `DECISIONS.md` → `03-decisions.md`؛ minSdk فعلي **24** بدل 23 (CR-0003 مفتوح).
- السبب: License Gate يتعارض مع `legal/assets.yaml` v1 (S-001/S-003)؛ Flutter 3.47.5 يفرض `flutter.minSdkVersion=24` ويهاجر القيم 16..23 تلقائيًا (`min_sdk_version_migration.dart`).
- التفاصيل: `phases/00-foundation.md` §Deviations.

## 10. نقاط تحتاج مراجعة بشرية

- شرعي؟ — لا محتوى شرعي (لا شيء في هذا Phase).
- ترخيص؟ — ✅ MIT معتمد (DEC-0014، بشري)؛ **CR-0003 (minSdk 24) بانتظار ردك**.
- معماري؟ — المنصات معتمدة (DEC-0015)؛ الجهاز المرجعي معتمد (DEC-0017)؛ ملاحظة: `approvals.yaml` APR-0001 ما زالت PENDING (تعديلها بشري فقط — Rule 020).

## 11. مخاطر متبقية

- **CR-0003** (minSdk 24 مقابل DEC-0015=23) — مفتوح؛ لا يُسدَّد قبل حسمه.
- معيار «CI على PR» معلّق حتى وجود git repo + GitHub remote + branch protection (أسماء الـjobs جاهزة كعقد).
- `legal/assets.yaml` v1 → schema v2 مطلوب **قبل** تفعيل CI-001/003–008 (شرط DEC-0018 — قبل Phase 05).
- FVM غير مثبّت محليًا: النظام يعتمد SDK النظام 3.47.5 المطابق لـ`.fvmrc` («FVM أو ما يعادله» — ADR-0001)؛ CI يثبّت 3.47.5 صراحة.
- `namespace = com.muslimguide.app.muslim_guide` داخلي مقابل `applicationId = com.muslimguide.app` — لا أثر خارجي، لكنه نقطة تذكر عند أي CR مستقبلي.

## 12. جاهزية الانتقال للمرحلة التالية

- [ ] نعم
- [x] لا — السبب: (1) معيار القبول «CI يعمل على PR تجريبي» لم يتحقق (بيئة بدون git/remote — يتطلب خطوة من المستخدم)؛ (2) CR-0003 (minSdk) بانتظار القرار البشري. باقي المخرجات العشرة مكتملة ومُتحقَّق منها.

