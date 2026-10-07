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
| flutter_localizations | Localization (Phase 01) | Flutter SDK | BSD-style (BSD-3-Clause text) | Flutter SDK | `pubspec.yaml` dependencies |
| go_router | Navigation (DEC-0003) | `18.0.2` (exact) | BSD-3-Clause | 2026-10-07 — https://pub.dev/packages/go_router/versions/18.0.2 (published 2026-09-28) | `pubspec.yaml`; `lib/app/router.dart` |
| hive_ce | Local key-value storage (DEC-0024، DEC-0027) | `2.20.1` (exact) | BSD-3-Clause (+ Apache-2.0 embedded component) | 2026-10-06 — https://pub.dev/packages/hive_ce/versions/2.20.1 | `pubspec.yaml` dependencies |
| hive_ce_flutter | Initialize Hive in Flutter | `2.4.0` (exact) | BSD-3-Clause; older portions Apache-2.0 | 2026-10-06 — https://pub.dev/packages/hive_ce_flutter/versions/2.4.0 | `pubspec.yaml` dependencies |
| intl | Locale-aware number formatting (DEC-0026) | `0.20.3` (exact) | BSD-3-Clause | 2026-10-06 — https://pub.dev/packages/intl/versions/0.20.3 | `pubspec.yaml` dependencies |
| path_provider | Hive and local error-log paths (CR-0006) | `2.1.6` (exact) | BSD-3-Clause | 2026-10-06 — https://pub.dev/packages/path_provider/versions/2.1.6 | `pubspec.yaml` dependencies |
| share_plus | Export local error log (DEC-0025) | `13.3.1` (exact) | BSD-3-Clause | 2026-10-06 — https://pub.dev/packages/share_plus/versions/13.3.1 | `pubspec.yaml` dependencies |
| very_good_analysis | قواعد التحليل الساكن (DEC-0011) | `11.0.0` (exact) | MIT | 2026-10-05 — https://pub.dev/packages/very_good_analysis | `pubspec.yaml` dev_dependencies |

تبعيات غير مباشرة (تُستنتَج فعليًا من `pubspec.lock`):

| Package | License | Verified |
|---|---|---|
| riverpod | MIT | 2026-10-05 — https://pub.dev/packages/riverpod |
| state_notifier | MIT | 2026-10-05 — https://pub.dev/packages/state_notifier |
| collection | BSD-3-Clause | 2026-10-05 — https://pub.dev/packages/collection |
| meta | BSD-3-Clause | 2026-10-05 — https://pub.dev/packages/meta |

ملاحظة: القائمة الكاملة لجميع تبعيات `pubspec.lock` مع التراخيص تُوثَّق في `LICENSES.md` (المصدر الوحيد: `03-decisions.md` DEC-0014 … DEC-0018).