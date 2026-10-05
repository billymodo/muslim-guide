# LICENSES — دليل المسلم

> المصدر: `03-decisions.md` (DEC-0014 … DEC-0018). حزمة غير مدرجة هنا = **BLOCK** (`security/02-dependencies.md`).
> تاريخ التحقق: **2026-10-05** (و2026-10-06 لبعض بنود SDK).
> سجل التبعيات المفصّل: `security/02-dependencies.md` + `pubspec.lock` (مُلتزم به).

## 1. ترخيص التطبيق

- **MIT** — الكود المكتوب في هذا المستودع (`lib/`, `test/`, `tool/`, `android/`, سكربتات CI).
- القرار: DEC-0014 (2026-10-05، حسم OD-0001).

## 2. الأدوات / SDK (طُوّرت به، لا تُشحن كحزم)

| المكوّن | الإصدار | الترخيص | الدليل |
|---|---|---|---|
| Flutter SDK | 3.47.5 (stable) | BSD-style (BSD-3-Clause text) | `C:\src\flutter\LICENSE` — "Redistribution and use in source and binary forms…" (قرأ 2026-10-06) |
| Dart SDK | 3.13.4 | BSD-style (BSD-3-Clause text) | `C:\src\flutter\bin\cache\dart-sdk\LICENSE` (قرأ 2026-10-06) |

## 3. حزم مباشرة (pubspec.yaml)

| الحزمة | الإصدار | السبب (DEC) | الترخيص | أداة التحقق |
|---|---|---|---|---|
| flutter_riverpod | 2.6.1 (exact) | إدارة الحالة — DEC-0002، DEC-0016 | MIT | pub.dev صفحة الإصدار + API — https://pub.dev/packages/flutter_riverpod/versions/2.6.1 |
| very_good_analysis | 11.0.0 (exact, dev) | قواعد التحليل الساكن — DEC-0011 | MIT | pub.dev — https://pub.dev/packages/very_good_analysis |

## 4. تبعيات `pubspec.lock` (كلها — غير مباشرة)

أُكدت من ملف `LICENSE` داخل أرشيف كل حزمة على `https://pub.dev/api/archives/<p>-<v>.tar.gz` (توقيع النص: BSD-text / Apache-2.0 text / MIT text)، إلا ما أُكّد من صفحة pub.dev مباشرة:

| الحزمة | الإصدار | الترخيص | التحقق |
|---|---|---|---|
| async | 2.13.1 | BSD-3-Clause | أرشيف LICENSE (2026-10-06) |
| boolean_selector | 2.1.2 | BSD-3-Clause | أرشيف LICENSE (2026-10-06) |
| characters | 1.4.1 | BSD-3-Clause | أرشيف LICENSE (2026-10-06) |
| clock | 1.1.3 | Apache-2.0 | أرشيف LICENSE — "Apache License Version 2.0" (2026-10-06) |
| collection | 1.19.1 | BSD-3-Clause | pub.dev (2026-10-05) |
| fake_async | 1.3.3 | Apache-2.0 | أرشيف LICENSE — "Apache License Version 2.0" (2026-10-06) |
| leak_tracker | 11.0.2 | BSD-3-Clause | أرشيف LICENSE (2026-10-06) |
| leak_tracker_flutter_testing | 3.0.10 | BSD-3-Clause | أرشيف LICENSE (2026-10-06) |
| leak_tracker_testing | 3.0.2 | BSD-3-Clause | أرشيف LICENSE (2026-10-06) |
| matcher | 0.12.20 | BSD-3-Clause | أرشيف LICENSE (2026-10-06) |
| material_color_utilities | 0.13.0 | Apache-2.0 | أرشيف LICENSE — "Apache License Version 2.0" (2026-10-06) |
| meta | 1.18.3 | BSD-3-Clause | pub.dev (2026-10-05) |
| path | 1.9.1 | BSD-3-Clause | أرشيف LICENSE (2026-10-06) |
| riverpod | 2.6.1 | MIT | pub.dev (2026-10-05) |
| source_span | 1.10.2 | BSD-3-Clause | أرشيف LICENSE (2026-10-06) |
| stack_trace | 1.12.2 | BSD-3-Clause | أرشيف LICENSE (2026-10-06) |
| state_notifier | 1.0.0 | MIT | pub.dev (2026-10-05) |
| stream_channel | 2.1.4 | BSD-3-Clause | أرشيف LICENSE (2026-10-06) |
| string_scanner | 1.4.1 | BSD-3-Clause | أرشيف LICENSE (2026-10-06) |
| term_glyph | 1.2.2 | BSD-3-Clause | أرشيف LICENSE (2026-10-06) |
| test_api | 0.7.12 | BSD-3-Clause | أرشيف LICENSE (2026-10-06) |
| vector_math | 2.4.0 | BSD-3-Clause | أرشيف LICENSE (2026-10-06) |
| vm_service | 15.3.0 | BSD-3-Clause | أرشيف LICENSE (2026-10-06) |

حزم من المصدر `sdk` (جزء من Flutter SDK — انظر §2): `flutter`، `flutter_test`، `sky_engine`.

سلامة النسخ: sha256 لكل حزمة مسجّل في `pubspec.lock` (يتحقق منه `flutter pub get --enforce-lockfile` في CI).

## 5. الأصول (محتوى/خطوط/صور)

- **لا أصول مُشحونة في Phase 00** — `assets/` فارغ عدا `.gitkeep` (يتحقق منه CI-002).
- سجل الأصول الكامل: `legal/assets.yaml` (يُحدَّث إلى schema v2 قبل تفعيل CI-001/003–008 — DEC-0018).

## 6. حزم حُذفت من قالب `flutter create` (غير مدرجة في أي DEC)

- `cupertino_icons` — لا استخدام لها ولا قرار بـها.
- `flutter_lints` — استُبدلت بـ `very_good_analysis` (DEC-0011).

## 7. ملاحظات

- توليد `THIRD_PARTY_NOTICES` الكامل عند الإصدار (ci/01 — On main، Phase 09).
- لا حزمة شبكة (لا `http`/`dio`/…) — الشبكة ممنوعة حتى Phase 07 (Rule 008).
