# ADR-0001 — Flutter Version Pinning

## Status
ACCEPTED

## Context
المشروع يحتاج reproducibility (Rule 019).
إصدارات Flutter المتغيرة (latest/stable) تسبب كسر CI وأخطاء غير قابلة للتتبع.

## Decision
- استخدام **FVM** (Flutter Version Management) أو ما يعادله.
- الرقم الفعلي يُحدَّد بعد التحقق في Phase 00 (OD-0019).
- CI يثبت الرقم صراحة (لا `stable` مفتوح).
- `pubspec.lock` يُلتزم به في المستودع.

## Alternatives
- `stable` مفتوح: مرفوض (يخالف Rule 019).
- إصدار من الذاكرة: مرفوض (يخالف D-22).

## Consequences
- الترقية patch: تلقائية.
- minor: بمراجعة.
- major: بقرار موثق في DEC-.

## Migration
- عند ترقية كاسرة: فتح CR + تحديث ADR + تشغيل كل الاختبارات.

## Related Requirements
- REQ-FOUND-001

## Related Decisions
- DEC-0001
- OD-0019

## References
- `ci/00-ci-policy.md`
- `adr/README.md`