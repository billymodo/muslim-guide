# State Management

## Status: APPROVED (DEC-0002)

## Framework
Riverpod (الإصدار في OD-0018).

## Rules
- لا provider يعتمد دائريًا على آخر.
- كل provider قابل للـoverride.
- لا حالة عامة في static variables.
- `autoDispose` افتراضيًا.
- `AsyncNotifier` للبيانات التي تُحمَّل.
- ممنوع `ChangeNotifier` بلا سبب موثق.