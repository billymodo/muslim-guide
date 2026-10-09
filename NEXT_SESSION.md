# NEXT_SESSION — اقرأني أولاً

> **آخر تحديث:** 2026-10-09
> **الحالة:** Phase 02 — M1-M5 (Manual Testing) + BUG-2

## المرحلة الحالية (Phase 02 Status)
- Phase 02: ACTIVE (~97%)
- Tasks 1, 1.5, 2, 3, 4, 5 ✅ + Task 6 (partial) ✅
  — T1 ✅ T2 ✅ T3 ❌(42/48 موثق) T6 ✅ T7a ✅ T8a ✅ T9–T11 ✅
  — T4/T5/T7b/T8c = BLOCKED (خطوات يدوية M1–M5 أدناه)
- **BUG-1 ✅ FIXED** (`c88cc97`)
- **BUG-3 ✅ FIXED** (`4ba60bd`) — بوابة bootstrap في `_AppBootstrap`
- **BUG-4 ✅ FIXED** (`cedbbac`) — `appLocaleProvider` مُستهلكة في `MaterialApp`
- **BUG-2 ⏳ P2** (city change UI) — موثّق في `06-defect-register.md`
- الدليل الكامل: `docs/phase-02-device-testing.md` (34 صورة في `docs/evidence/phase-02/`)

## المتبقي

### M1–M5 (يدوي مع المستخدم)
| # | الإجراء | يفكّ |
|---|---|---|
| M1 | مهلة شاشة (>60 ث) | موثوقية الأتمتة كلها |
| M2 | خدمة موقع ON → فتح `/prayer` | T7b (حوار الرفض) |
| M3 | التاريخ → 2026-10-25 | T4 (DST لندن) |
| M4 | التاريخ → 2026-06-21 | T5 (ترومسو قطبية) |
| M5 | حجم الخط → Largest | T8c (200%) |

### BUG-2 (P2)
- city change UI من شاشة Prayer — **بعد M1–M5**

### إغلاق المرحلة
- تعبئة `docs/phase-02-output-report.md` ثم APPROVED في `phases/02.md`
- إعادة اختبار T8b على الجهاز للتحقق من BUG-4 (English يُطبَّق)

**الجهاز:** Oppo A95 (CPH2365, Android 13) — OD-0029 الخيار A (DECIDED 2026-10-09)
**وصفة التنقل (مقفلة):** `force-stop` → `am start` عادي (6 ث — bootstrap) → deep link (4 ث) → `KEYCODE_WAKEUP` → `input motionevent DOWN/UP` (150ms) → `uiautomator dump` للتحقق → `adb pull`
> ملاحظة بعد BUG-3: الـ deep link البارد آمن الآن (البوابة تنتظر bootstrap)، لكن الوصفة تبقى كما هي.

## Commit HEAD
cedbbac — fix(bug-4): apply saved locale from appLocaleProvider in MaterialApp
4ba60bd — fix(bug-3): gate app startup on bootstrap before building router
335efb2 — phase-02(task-6): register BUG-1 as FIXED in c88cc97
> هذا الـ commit (توثيق BUG-3/BUG-4) يُرفع معهم في نفس الدفعة — push ثم انتظار CI (المتوقع 9/9 ✅).
