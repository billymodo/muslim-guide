# ADR-0002 — State Management

## Status
ACCEPTED

## Context
الحاجة لإدارة حالة testable، async-friendly، minimal coupling.

## Decision
Riverpod (DEC-0002).
- `Notifier` للحالة المتزامنة.
- `AsyncNotifier` للبيانات.
- `autoDispose` افتراضيًا.
- `keepAlive` بقرار موثق.

## Alternatives
- Provider — أقل مرونة في async.
- BLoC — أكثر boilerplate.
- GetX — غير مناسب لمعايير الاختبار.

## Consequences
- منع `provider`/`get_it` بلا CR.
- الاختبار بـ`ProviderScope` override.

## Related Decisions
- DEC-0002
- OD-0018