# Phase 00 — Decisions and Foundation

## Status
ACTIVE

## Objective
تثبيت baseline، حسم القرارات، إنشاء الوثائق، مشروع Flutter فارغ يبنى، وCI.

## Scope
- الوثائق الأساسية
- `pubspec.yaml` بإصدارات مثبتة
- `analysis_options.yaml`
- `.github/workflows/ci.yml`
- هيكل المجلدات + `.gitkeep`
- `legal/assets.yaml` بالسجل الأولي
- `content/reviewers.yaml`

## Out of Scope
- أي شاشة (حتى Splash)
- Hive
- Theme
- Localization
- أي ميزة إسلامية
- أي شبكة

## Requirements
- REQ-FOUND-001 (مرجع فقط)

## Decisions Required
- OD-0001 (ترخيص الكود) → حُسم: DEC-0014
- OD-0006 (المنصات) → حُسم: DEC-0015
- OD-0018 (إصدار Riverpod) → حُسم: DEC-0016
- OD-0019 (الجهاز المرجعي) → حُسم: DEC-0017

## Implementation Tasks
1. تحقق من إصدارات الحزم على pub.dev
2. إنشاء `pubspec.yaml` + `pubspec.lock`
3. `analysis_options.yaml`
4. `.github/workflows/ci.yml` (`release.yml` في Phase 09 — قرار بشري 2026-10-05)
5. هيكل المجلدات
6. `LICENSES.md`
7. `03-decisions.md` محدّث (DEC-0014 … DEC-0018)

## Tests Required
- اختبار واحد على الأقل

## CI Requirements
- CI-002، CI-009، CI-010، CI-011، CI-018 (وفق DEC-0018 / CR-0001؛ بقية الفحوصات مؤجلة إلى 00B+ و05+)

## Exit Criteria
- [x] `flutter analyze --fatal-infos` بلا مخرجات — دليل: "No issues found!" (2026-10-06)
- [x] `flutter test` ينجح — دليل: "All tests passed!" (+1) (2026-10-06)
- [x] `flutter build apk --debug` ناجح — دليل: "√ Built app-debug.apk" (2026-10-06)
- [x] CI يعمل على PR تجريبي — دليل: run ناجح على PR التجريبي `chore/trial-pr` (2026-10-06، أكده المستخدم) — https://github.com/billymodo/muslim-guide/actions (يُرفق الرابط المباشر للمانع عند استلامه)
- [x] كل حزمة لها إصدار متحقق وترخيص وسبب — دليل: `LICENSES.md` + `security/02-dependencies.md`

## Evidence Required
- ناتج الأوامر حرفيًا
- `pubspec.lock`
- سجل CI

## Deviations from Specification

- **نطاق CI**: بدل «CI-001 … CI-018» → نطاق Phase 00 = CI-002, CI-009, CI-010, CI-011, CI-018 — بقرار DEC-0018 (CR-0001)؛ السبب: License Gate يفترض `legal/assets.yaml` محدّثة إلى schema v2 (حاليًا v1 ومخالفة S-001/S-003).
- **`release.yml`** (مهمة التنفيذ 4): لم يُنشأ — قرار بشري 2026-10-05 (يُنشأ في Phase 09).
- **`DECISIONS.md`** (مهمة التنفيذ 7): لا يوجد ملف منفصل — المصدر الوحيد `03-decisions.md` (قرار بشري 2026-10-05)؛ أُعيدت تسمية الإشارة داخل هذا الملف.
- **minSdk**: DEC-0015 ينص على 23، والبناء الفعلي = **24** (يفرضها Flutter 3.47.5 وتهاجر أدواته القيم 16..23 تلقائيًا عند كل `flutter build`) → **CR-0003 بانتظار القرار البشري**.
- **«CI يعمل على PR تجريبي»**: غير مُتحقَّق منه — المجلد ليس git repo ولا يوجد GitHub remote؛ يتطلب git init + push + PR من المستخدم (Stop Rule 17 — مُصرَّح به صراحةً).
- **الفحوصات المجدولة أسبوعيًا** (ci/00): غير مفعّلة — فحوصات التبعيات والتراخيص مؤجلة ضمن DEC-0018 حتى Phase 05+.
- **namespace الباكدج**: `com.muslimguide.app.muslim_guide` (داخلي لـ MainActivity/Kotlin) مقابل `applicationId = com.muslimguide.app` (المعتمد) — فصل داخلي عادي من `flutter create`.

## Human Review Points
- ترخيص الكود
- المنصات
- الجهاز المرجعي

## Approval
- Status: ACTIVE
- Approved By: User
- Approval Date: 2026-10-05
- Approval Text: أُعتمد تنفيذ Phase 00.