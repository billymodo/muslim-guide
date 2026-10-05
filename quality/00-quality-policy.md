# Quality Policy

## Definition
الميزة ليست مكتملة لأن الكود يُترجم.
الميزة مكتملة فقط عندما:
`Requirement → Implementation → Test → Review → CI → Documentation`
كلها موجودة.

## Gates
- `flutter analyze --fatal-infos`
- `flutter test`
- `flutter build apk --debug`
- فحوصات المشروع (CI)

## Non-Negotiable
- لا اختبار محذوف.
- لا `// ignore` بلا سبب.
- لا `print`.
- لا APIs مهجورة.