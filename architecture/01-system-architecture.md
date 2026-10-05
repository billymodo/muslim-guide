# System Architecture



## High-Level Layers

Presentation (features//presentation)

↓ providers

Application (features//application) ← Notifier / AsyncNotifier

↓

Domain (features//domain) ← نماذج + قواعد، بلا Flutter

↓

Data (features//data) ← repositories + مصادر (Hive / Assets)





## Rules

- لا تعتمد طبقة على ما فوقها.

- المنطق الحسابي (مواقيت، قبلة، هجري) في Domain نقي ومختبر بلا UI.

- Presentation لا يصل إلى التخزين مباشرة.

- Domain لا يعتمد على Flutter UI.

- Data implementations قابلة للاستبدال حيث يمكن.

- لا شبكة إلا في Phase 07 (وحدة معزولة).

- المحتوى الثابت وبيانات المستخدم منفصلان مفهوميًا.



## Related

- `architecture/00-architecture-principles.md`

- `architecture/02-flutter-architecture.md`

- `architecture/03-data-architecture.md`



