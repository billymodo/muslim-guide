# CR-0005 — CI Job Names Expanded (Phase 00B)

**Status:** APPROVED
**Date:** 2026-10-06

**المرحلة:** Phase 00B
**الوثيقة المتأثرة:** ci/00-ci-policy.md, ci/01-ci-checks.md, .github/workflows/ci.yml

**قبل:** عقد CI يحتوي jobs: license-gate, asset-scan, hash-verification, analyze, test, build-debug, project-checks

**بعد:** إضافة 5 jobs جديدة:
- `check-test-count` (CI-012)
- `check-no-print` (CI-014)
- `check-no-internet` (CI-015)
- `check-no-network-pkg` (CI-016)
- `check-no-placeholder` (CI-017)

**السبب:** تفعيل CI-012, 014, 015, 016, 017 وفق DEC-0018 (Phase-Aware Rollout) وPhase 00B.

**أثره على مراحل أخرى:**
- CI-013 (ARB) مؤجل إلى Phase 01
- CI-001, 003–008 مؤجلة إلى Phase 05+

**اختبارات إضافية مطلوبة:**
- PR تجريبي يتحقق من تشغيل الـ5 jobs بنجاح
- اختبار أن spike/ معفى من CI-015/016

**القرار:** موافق — 2026-10-06

**ملاحظة حوكمية:** أسماء jobs هي عقد (contract) — أي تعديل مستقبلي يحتاج CR جديد.
