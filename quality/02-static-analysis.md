# Static Analysis

## Required
- `flutter analyze --fatal-infos`
- `very_good_analysis` أو `flutter_lints` + قواعد إضافية
- `analysis_options.yaml` موحد

## Rules
- لا `// ignore` بلا تعليق يشرح السبب.
- لا `print`.
- لا APIs مهجورة.

## CI
- `--fatal-infos` إلزامي.