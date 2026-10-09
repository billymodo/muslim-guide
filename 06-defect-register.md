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
| D-25 | تراخيص pending | بدء مسار الاعتماد الآن |

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

## Phase 02 — Device Testing Bugs

> المصدر: `docs/phase-02-device-testing.md` — Rule 011 (Evidence Required).
> BUG-1 و BUG-2 **غير مسجَّلين بعد** — بانتظار قرار المالك بعد مراجعة التفاصيل.

| ID | Bug | Severity | Found In | Status | Evidence |
|---|---|---|---|---|---|
| BUG-3 | Cold-start deep link يتجاوز bootstrap في `/splash` → `selectCity` يرمي «Settings are unavailable before app initialization» (فشل صامت بلا تنقل) | P1 | T2 — Oppo A95 (2026-10-09) | OPEN | logcat `E flutter` 09:31:01 — `location_provider.dart:110` + `bootstrap_provider.dart:16` |
| BUG-4 | اختيار الإنجليزية في Onboarding لا يُطبَّق؛ `/prayer` يظل عربياً (تعذر الوصول لمسار LTR) | P1 | T8b — Oppo A95 (2026-10-09) | OPEN | `docs/evidence/phase-02/t8-06-en-selected.png` مقابل `t8-07-empty-en-ltr.png` |
