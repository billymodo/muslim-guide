# CI Policy

- **Status**: DRAFT (v2)
- **Owner**: Project owner
- **Related Rules**: Rule 012 (CI Is Authoritative), Rule 015, Rule 018, Rule 019
- **Related Files**: `ci/01-ci-checks.md`, `ci/02-branch-policy.md`, `ci/03-release-pipeline.md`, `adr/ADR-0001-flutter-version.md`
- **Related Decisions**: DEC-0001, DEC-0011

## Principle

CI **بوابة إصدار**، لا مُحذِّر. فشل أي بوابة إلزامية = المستودع غير قابل للدمج أو الإصدار.
CI هو المرجع الوحيد لإثبات النجاح؛ أي ادعاء نجاح بلا سجل CI أو ناتج أمر حرفي لا يُقبل (Rule 011).

## Gate Order

تُنفَّذ البوابات بالترتيب التالي، وفشل بوابة مبكرة يمنع اللاحقة (`needs` بين الـjobs):

| # | البوابة | الفحوصات (من `ci/01-ci-checks.md`) |
|---|---|---|
| 1 | License Gate | CI-001، CI-003، CI-004، CI-005، CI-007، CI-008 |
| 2 | Asset Scan | CI-002 |
| 3 | Hash Verification | CI-006 |
| 4 | Analyze | CI-009، CI-014 |
| 5 | Tests | CI-010، CI-012، CI-013 |
| 6 | Build | CI-011 |
| 7 | Project-specific | CI-015، CI-016، CI-017، CI-018 |

ملاحظة: ترتيب CI-018 (تثبيت إصدار Flutter) منطقيًا يسبق كل شيء، لذا يُنفَّذ كخطوة أولى داخل كل job ويُسجَّل ضمن البوابة 7 للتقارير فقط.

## Reproducibility (Rule 019)

- إصدار Flutter/Dart مثبت صراحة في الـworkflow (لا `stable` مفتوح)، ويطابق `.fvmrc`.
- إصدارات الـactions مثبتة بـSHA كامل أو tag غير متحرك، لا `@main` ولا `@latest`.
- `pubspec.lock` مُلتزَم ويُتحقق منه (`flutter pub get --enforce-lockfile` أو ما يعادله).
- نسخة الأدوات المساعدة (سكربتات التحقق) مثبتة في المستودع.
- نتائج التحقق قابلة للتكرار: لا اعتماد على شبكة خارجية داخل الفحوصات، باستثناء جلب الاعتماديات.

## Fail Rules

- أي فشل في بوابة إلزامية يُوقف الـpipeline.
- لا `continue-on-error` على بوابة إلزامية.
- لا تخطي بوابة (`if:` شرطي) إلا بشروط موثقة في `ci/01-ci-checks.md`.
- لا إعادة تشغيل حتى النجاح لإخفاء اختبار متقطع: الاختبار المتقطع يُسجَّل كعيب في `06-defect-register.md`.
- حذف اختبار أو إنقاص عدد الاختبارات = فشل (CI-012).

## Triggers

| الحدث | ما يُنفَّذ |
|---|---|
| Pull Request إلى `main` | كل البوابات 1–7 |
| Push إلى `main` | البوابات 1–7 + build release + checksum الأصول + مسح التراخيص + توليد THIRD_PARTY_NOTICES |
| Tag إصدار | `ci/03-release-pipeline.md` |
| جدولة أسبوعية | مسح التبعيات والتراخيص (اكتشاف تغيّر الاعتماديات) |

## Status Check Names (Contract)

- أسماء الـjobs ثابتة وتُعدّ عقدًا مع branch protection (`ci/02-branch-policy.md`).
- أي تغيير في اسم job يُحدَّث في حماية الفرع في نفس الـPR، وإلا يتعطل الدمج.
- الأسماء المعتمدة:

```text
license-gate
asset-scan
hash-verification
analyze
test
build-debug
project-checks
```

أسماء إضافية (تفعيل Phase 00B — تعليم بشري 2026-10-06):

```text
check-test-count
check-no-print
check-no-internet
check-no-network-pkg
check-no-placeholder
```

## Network & Manifest Checks (توضيح CI-015)

- Flutter يضيف صلاحية `INTERNET` تلقائيًا في manifest نسخ debug/profile لأجل hot reload.
- لذلك يُفحص `INTERNET` على **manifest نسخة release المدمج** (merged release manifest)، وليس على نسخة debug.
- قبل Phase 07: وجود `INTERNET` في release manifest = FAIL.
- استثناء Spike (00B): مسار `spike/` مستثنى من CI-015 وCI-016، ويُحذف قبل اعتماد 00B (`legal/policy.yaml`).

## Phase-Aware Rollout (معتمد — DEC-0018 / CR-0001)

تُفعَّل الفحوصات تدريجيًا:

| المرحلة | الفحوصات المفعّلة |
|---|---|
| Phase 00 | CI-009، CI-010، CI-011، CI-002 (فحص الأصول الأساسي)، CI-018 |
| Phase 00B → Phase 04 | **مفعّلة منذ 2026-10-06:** CI-012, CI-014, CI-015, CI-016, CI-017 — وCI-013 مؤجّل إلى Phase 01 |
| Phase 05+ | إضافة CI-001، CI-003 … CI-008 (license gate كامل) — **مشروطًا** بتحديث `legal/assets.yaml` إلى schema v2 أولًا |

- المعتمد في: `03-decisions.md` (DEC-0018) و`governance/cr/CR-0001-phase-aware-ci-rollout.md`.
- التاريخ: 2026-10-05.

## Evidence & Artifacts

- يُحفَظ لكل تشغيل: سجل الـjob، ناتج `flutter analyze`، ناتج `flutter test`، ناتج البناء.
- في Pull Request المرحلة: يُرفق ناتج الأوامر حرفيًا وفق `governance/05-output-report-template.md`.
- artifacts الإصدار (APK، checksums، notices) تُحفَظ مع الإصدار ولا تُحذف.

## Secrets in CI

- لا أسرار في الـworkflow أو المستودع (`security/01-secrets.md`).
- أسرار التوقيع في GitHub Secrets فقط، وتُستخدم في job الإصدار حصرًا.
- لا تُمرَّر الأسرار إلى PRs من forks.
- تقليل الصلاحيات: `permissions:` صريحة وأدنى حد لكل job.

## Prohibited

- تجاوز CI أو دمج بفشل بوابة إلزامية.
- تعطيل بوابة لتمرير تغيير ("سأصلحه لاحقًا").
- تعديل الـworkflow وتغيير الكود المحمي به في نفس الـPR بلا مراجعة خاصة لتغيير الـworkflow.
- استخدام `latest` لأي أداة أو action.

## Change Control

تعديل هذه السياسة أو `ci/01-ci-checks.md` أو أسماء الـjobs يتطلب `Change Request` (`governance/00-change-control.md`) وتحديث حماية الفرع.
