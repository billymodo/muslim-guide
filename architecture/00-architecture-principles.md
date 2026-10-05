# Architecture Principles

## AP-001 — Separation of Concerns

UI لا يملك منطق التخزين مباشرة.

## AP-002 — Testability

منطق العمل قابل للاختبار بمعزل عن الواجهات.

## AP-003 — Explicit Dependencies

كل الاعتماديات صريحة.

## AP-004 — No Hidden Global State

لا حالة عامة قابلة للتغيير بلا تحكم.

## AP-005 — Offline First

الميزات المعتمدة Offline تعمل بلا شبكة.

## AP-006 — User Data Separation

Hive CE لبيانات المستخدم فقط. ممنوع تخزين المحتوى الديني فيه.

## AP-007 — No Premature Infrastructure

لا API، لا backend، لا telemetry، لا DB جديدة بلا متطلب معتمد.

## AP-008 — Change Traceability

كل تغيير معماري يشير إلى `DEC-` أو `ADR-`.

## AP-009 — Localization First

كل نص واجهة في ARB. لا نصوص مضمّنة.

## AP-010 — Accessibility First

الوصولية بند في كل مرحلة، لا مرحلة منفصلة.

