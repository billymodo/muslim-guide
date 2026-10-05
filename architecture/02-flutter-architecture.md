# Flutter Architecture

## Principles
- Feature-oriented organization
- فصل UI عن Data
- منطق قابل للاختبار
- حدود اعتماد صريحة
- اقتران أدنى

## Package Rule
لا تُدخل حزمة إلا إذا:
1. يوجد متطلب.
2. الغرض موثق.
3. الترخيص متوافق.
4. حالة الصيانة مُراجعة.
5. الأمن مُراجع.
6. البديل دُرِس عند الجوهر.

## State Management
Riverpod (DEC-0002). الإصدار في OD-0018.
- `Notifier` للحالة المتزامنة.
- `AsyncNotifier` للبيانات.
- `autoDispose` افتراضيًا، `keepAlive` بقرار موثق.
- كل provider قابل للـoverride في الاختبار.

## Localization
انظر `architecture/07-localization.md`.

## Code Style
- `very_good_analysis` + قواعد إضافية.
- `flutter analyze --fatal-infos`.
- لا `print`، لا `// ignore` غير موثق.