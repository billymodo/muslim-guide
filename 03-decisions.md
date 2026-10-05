# Approved Decisions

## DEC-0001 — Framework
- **Status**: APPROVED
- **Title**: Flutter + Dart
- **Decision**: استخدام Flutter مع إصدار Dart مثبت عبر FVM.
- **Reason**: توحيد المنصات، سرعة التطوير، دعم RTL/LTR ممتاز.
- **Consequences**: التزام بـ Flutter SDK مثبت في CI.
- **Affected Documents**: `architecture/02`, `ci/00`
- **Supersedes**: —

## DEC-0002 — State Management
- **Status**: APPROVED
- **Title**: Riverpod
- **Decision**: استخدام Riverpod (الإصدار يُحسم في OD-0018).
- **Reason**: AsyncNotifier مناسب للبيانات، اختبار سهل، `autoDispose` افتراضي.
- **Consequences**: ممنوع `provider` أو `get_it` بلا CR.
- **Affected Documents**: `architecture/04`

## DEC-0003 — Navigation
- **Status**: APPROVED
- **Title**: go_router
- **Decision**: استخدام `go_router` مع مسارات feature-first.
- **Affected Documents**: `architecture/05`

## DEC-0004 — User Data Storage
- **Status**: APPROVED
- **Title**: Hive CE
- **Decision**: Hive CE لبيانات المستخدم فقط. ممنوع تخزين المحتوى الديني فيه.
- **Affected Documents**: `architecture/03`

## DEC-0005 — Static Content
- **Status**: APPROVED
- **Title**: Assets للقراءة فقط
- **Decision**: المحتوى الثابت (قرآن، أذكار، …) في `assets/` للقراءة فقط.
- **Affected Documents**: `architecture/03`, `content/`

## DEC-0006 — Localization
- **Status**: APPROVED
- **Title**: AR + EN مع اختيار عند التنصيب
- **Decision**: دعم اللغتين، مع شاشة اختيار عند أول تشغيل.
- **Affected Documents**: `product/06-onboarding.md`, `architecture/07-localization.md`

## DEC-0007 — Theme
- **Status**: APPROVED
- **Title**: Material 3 + Light/Dark/System
- **Decision**: استخدام M3 مع design tokens.
- **Affected Documents**: `product/04-settings.md`

## DEC-0008 — Audio Stack
- **Status**: APPROVED
- **Title**: audio_service + just_audio
- **Decision**: لـ Phase 07 فقط.
- **Affected Documents**: `phases/07`, `content/06`

## DEC-0009 — Notifications
- **Status**: APPROVED
- **Title**: flutter_local_notifications + timezone
- **Decision**: مع اختبار Spike في Phase 00B.
- **Affected Documents**: `phases/00b`, `phases/04`

## DEC-0010 — Testing
- **Status**: APPROVED
- **Title**: flutter_test + mocktail + integration_test
- **Decision**: golden اختياري.
- **Affected Documents**: `quality/01`

## DEC-0011 — Quality Gates
- **Status**: APPROVED
- **Title**: `flutter analyze --fatal-infos` + very_good_analysis
- **Decision**: لا warnings، لا infos، لا `// ignore` غير موثق.
- **Affected Documents**: `quality/02`, `ci/01`

## DEC-0012 — Privacy
- **Status**: APPROVED
- **Title**: لا telemetry
- **Decision**: لا إرسال بيانات، لا crash reporting خارجي في v1.
- **Affected Documents**: `security/03`

## DEC-0013 — Content Review
- **Status**: APPROVED
- **Title**: مراجعة شرعية عبر HTML + JSON
- **Decision**: كل pack يمر بمسار مراجعة موثق، والاعتماد مكتوب.
- **Affected Documents**: `content/08-review-workflow.md`, `content/reviewers.yaml`

## DEC-0014 — Code License
- **Status**: APPROVED
- **Title**: MIT License للكود
- **Decision**: ترخيص كود التطبيق `MIT`.
- **Reason**: توافق مع OFL/CC-BY/QuranEnc، بساطة، لا تعارض مع مكتبات Flutter.
- **Decided**: 2026-10-05 (حسم OD-0001)
- **Affected Documents**: `LICENSES.md`, `phases/00-foundation.md`, `governance/cr/`

## DEC-0015 — Platforms (v1.0)
- **Status**: APPROVED
- **Title**: Android فقط في v1.0
- **Decision**: Android فقط في v1.0 — `minSdk 24`، `compileSdk 35`، `targetSdk 34`.
- **Note**: Flutter 3.47.5 enforces minSdk 24.
- **Amended**: CR-0003 (2026-10-06) — كان `minSdk 23`.
- **Consequences**: iOS مؤجل إلى v2.0+ وسُجّل كـ OD-0021.
- **Decided**: 2026-10-05 (حسم OD-0006)
- **Affected Documents**: `pubspec.yaml`, `android/`, `phases/00-foundation.md`

## DEC-0016 — Riverpod Version
- **Status**: APPROVED
- **Title**: flutter_riverpod 2.6.1 (آخر إصدار 2.x ثابت)
- **Decision**: تثبيت `flutter_riverpod: 2.6.1` تثبيتًا صريحًا (بلا `^`).
- **Verification**: pub.dev، تاريخ التحقق 2026-10-05، تاريخ النشر 2024-10-22، الترخيص MIT — https://pub.dev/packages/flutter_riverpod/versions/2.6.1
- **Decided**: 2026-10-05 (حسم OD-0018)
- **Affected Documents**: `pubspec.yaml`, `LICENSES.md`, `security/02-dependencies.md`

## DEC-0017 — Reference Device
- **Status**: APPROVED
- **Title**: Pixel 6a (أساسي) + Redmi Note 12 (ثانوي)
- **Decision**: Pixel 6a الجهاز المرجعي الأساسي، Redmi Note 12 ثانوي.
- **Decided**: 2026-10-05 (حسم OD-0019 — أغلق GAP-009)
- **Affected Documents**: `phases/00-foundation.md`, `quality/`

## DEC-0018 — Phase-Aware CI Rollout
- **Status**: APPROVED
- **Title**: تفعيل فحوصات CI مرحليًا
- **Decision**:
  - **Phase 00:** CI-009 (analyze), CI-010 (test), CI-011 (build-debug), CI-002 (asset scan أساسي), CI-018 (Flutter version pinned).
  - **Phase 00B → Phase 04:** إضافة CI-012 … CI-017.
  - **Phase 05+:** إضافة CI-001, CI-003 … CI-008 (license gate كامل) — مشروطًا بتحديث `legal/assets.yaml` إلى schema v2 أولًا.
- **Reason**: License Gate يفترض محتوى مُشحونًا؛ `legal/assets.yaml` ما زالت بصيغة schema v1 ومخالفة لـ S-001/S-003.
- **Decided**: 2026-10-05 — `governance/cr/CR-0001-phase-aware-ci-rollout.md`
- **Affected Documents**: `ci/00-ci-policy.md`, `ci/01-ci-checks.md`, `phases/00-foundation.md`, `.github/workflows/ci.yml`