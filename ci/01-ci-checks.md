# CI Checks

> عمود **Phase** وفق DEC-0018 (CR-0001). الفحوصات غير المفعّلة في المرحلة الحالية لا تُشغَّل.

## On every PR

| Check | Description | Phase |
|---|---|---|
| CI-001 | Manifest validation | 05+ (مشروطًا بتحديث `legal/assets.yaml` إلى schema v2) |
| CI-002 | Asset scan (أساسي في Phase 00) | 00 |
| CI-003 | License validation | 05+ |
| CI-004 | Attribution validation | 05+ |
| CI-005 | Evidence validation | 05+ |
| CI-006 | Hash validation | 05+ |
| CI-007 | Review expiry | 05+ |
| CI-008 | Dependency validation | 05+ |
| CI-009 | `flutter analyze --fatal-infos` | 00 |
| CI-010 | `flutter test` | 00 |
| CI-011 | `flutter build apk --debug` | 00 |
| CI-012 | **الاختبارات لا تنقص** (مقارنة بعدد آخر مرحلة) | 00B (مفعّل 2026-10-06) |
| CI-013 | **ARB كامل** لكل لغة | 01 |
| CI-014 | **لا `print`** ولا `// ignore` غير موثق | 00B (مفعّل 2026-10-06) |
| CI-015 | **لا شبكة** قبل Phase 07 (INTERNET في Manifest) | 00B (مفعّل 2026-10-06) |
| CI-016 | **لا حزمة شبكة** خارج وحدة التلاوة | 00B (مفعّل 2026-10-06) |
| CI-017 | **placeholder في main** = FAIL | 00B (مفعّل 2026-10-06) |
| CI-018 | **إصدار Flutter مثبت** في workflow | 00 |

## On main
- build release
- asset checksum
- license scan
- generate THIRD_PARTY_NOTICES