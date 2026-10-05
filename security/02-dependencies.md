# Dependencies

## Each Dependency
- purpose
- version constraint (مثبتة صراحة)
- license review
- maintenance review
- security review
- owner/usage location

## Rules
- لا `latest`.
- FVM أو ما يعادله.
- حزمة غير مستخدمة = تُحذف.
- حزمة غير مدرجة في `LICENSES.md` = **BLOCK**.

## Register (Phase 00 — 2026-10-05)

حزم مباشرة:

| Package | Purpose | Constraint | License | Verified | Location |
|---|---|---|---|---|---|
| flutter_riverpod | State management (DEC-0002، DEC-0016) | `2.6.1` (exact) | MIT | 2026-10-05 — https://pub.dev/packages/flutter_riverpod/versions/2.6.1 | `pubspec.yaml` dependencies |
| very_good_analysis | قواعد التحليل الساكن (DEC-0011) | `11.0.0` (exact) | MIT | 2026-10-05 — https://pub.dev/packages/very_good_analysis | `pubspec.yaml` dev_dependencies |

تبعيات غير مباشرة (تُستنتَج فعليًا من `pubspec.lock`):

| Package | License | Verified |
|---|---|---|
| riverpod | MIT | 2026-10-05 — https://pub.dev/packages/riverpod |
| state_notifier | MIT | 2026-10-05 — https://pub.dev/packages/state_notifier |
| collection | BSD-3-Clause | 2026-10-05 — https://pub.dev/packages/collection |
| meta | BSD-3-Clause | 2026-10-05 — https://pub.dev/packages/meta |

ملاحظة: القائمة الكاملة لجميع تبعيات `pubspec.lock` مع التراخيص تُوثَّق في `LICENSES.md` (المصدر الوحيد: `03-decisions.md` DEC-0014 … DEC-0018).