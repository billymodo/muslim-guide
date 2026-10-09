# NEXT_SESSION — اقرأني أولاً

> **آخر تحديث:** 2026-10-09
> **الحالة:** Phase 02 — Task 6 (Device Testing) — أُنجزت جزئياً ومُوثقة

## المرحلة الحالية
- Phase 02: ACTIVE (~97%)
- Tasks 1, 1.5, 2, 3, 4, 5 ✅ مكتملة
- **Task 6:** منفَّذ 2026-10-09: T1 ✅ T2 ✅ T3 ❌(42/48 موثق) T6 ✅ T7a ✅ T8a ✅ T9–T11 ✅
  — T4/T5/T7b/T8c = BLOCKED (خطوات يدوية أدناه)
- الدليل الكامل: `docs/phase-02-device-testing.md` (34 صورة في `docs/evidence/phase-02/`)

## المطلوب في الجلسة القادمة

### 1) يحاول المستخدم خطوات يدوية على الجهاز (M1–M5)
| # | الإجراء | يفكّ |
|---|---|---|
| M1 | شاشة أطول من 60 ث | موثوقية الأتمتة كلها |
| M2 | تفعيل خدمة الموقع | T7b (حوار الرفض) |
| M3 | التاريخ → 2026-10-25 | T4 (DST لندن) |
| M4 | التاريخ → 2026-06-21 | T5 (ترومسو قطبية) |
| M5 | حجم الخط → Largest | T8c (200%) |

### 2) قرارات معلّقة للمالك
- BUG-1: إصلاح الأصل (تشفير + checksum في `legal/assets.yaml` + إعادة إثبات مصدر)؟
- BUG-3 / BUG-4: تسجيل في `06-defect-register.md` أم إصلاح مباشرة؟

### 3) إغلاق المرحلة
- تعبئة `docs/phase-02-output-report.md` ثم APPROVED في `phases/02.md`

**الجهاز:** Oppo A95 (CPH2365, Android 13) — OD-0029 الخيار A (DECIDED 2026-10-09)
**وصفة التنقل (مقفلة):** `force-stop` → `am start` عادي (6 ث — bootstrap) → deep link (4 ث) → `KEYCODE_WAKEUP` → `input motionevent DOWN/UP` (150ms) → `uiautomator dump` للتحقق → `adb pull`

## Commit HEAD
88a7081 — phase-02(task-5): prayer times + location picker screens
> **ملاحظة:** تغييرات الجلسة الحالية (وثائق + OD-0029) **غير مُلزمة (غير committed)** —
> بانتظار مراجعة المستخدم؛ لا push بدون موافقة.
