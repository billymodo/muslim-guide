# CR-0001 — Phase-Aware CI Rollout

- المرحلة المتأثرة: Phase 00 → Phase 05
- الوثيقة/الملف: `ci/00-ci-policy.md`, `ci/01-ci-checks.md`, `phases/00-foundation.md`
- قبل: كل الفحوصات CI-001 … CI-018 إلزامية على كل PR اعتبارًا من Phase 00.
- بعد:
  - **Phase 00:** CI-009 (analyze), CI-010 (test), CI-011 (build-debug), CI-002 (asset scan أساسي), CI-018 (Flutter version pinned).
  - **Phase 00B → Phase 04:** إضافة CI-012 … CI-017.
  - **Phase 05+:** إضافة CI-001, CI-003 … CI-008 (license gate كامل) — مشروطًا بتحديث `legal/assets.yaml` إلى schema v2 أولًا.
- السبب: License Gate يفترض محتوى مُشحونًا؛ `legal/assets.yaml` ما زالت بصيغة schema v1 ومخالفة لـ schema v2 (S-001/S-003)، وتشغيله الآن = فشل دائم.
- أثره على مراحل أخرى / بيانات مخزنة: لا أثر على الكود؛ يأجل بوابات الترخيص حتى Phase 05، ويستلزم تحديث `legal/assets.yaml` قبلها.
- اختبارات إضافية مطلوبة: لا يوجد — الفحوصات المؤجلة تُفعَّل عند مراحلها.
- القرار: موافق — 2026-10-05
- المرتبط: DEC-0018
