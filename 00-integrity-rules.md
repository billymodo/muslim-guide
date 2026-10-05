# Master Specification — Integrity Rules

> هذه القواعد **فوق كل الوثائق**. أي تعارض بينها وبين أي ملف آخر = القاعدة تفوز.

## Rule 001 — Canonical Source
لكل حقيقة في المشروع مصدر رسمي واحد. لا نسخ متضاربة.

## Rule 002 — Traceability
كل متطلب جوهري يجب أن يُتتبع إلى: Decision → Architecture → Implementation → Test → CI → Release.

## Rule 003 — No Orphan Requirements
متطلب بلا تنفيذ أو اختبار = **فجوة**.

## Rule 004 — No Orphan Code
ميزة جوهربة بلا `REQ-XXX` = **خرق نطاق**.

## Rule 005 — No Orphan Asset
كل أصل خارجي له سجل في `legal/assets.yaml`.

## Rule 006 — No Orphan Decision
كل قرار معماري له `ADR` أو `DEC-XXXX`.

## Rule 007 — No Hidden Dependency
كل حزمة في `pubspec.yaml` موثقة في `security/02-dependencies.md` و`legal/assets.yaml` (إن كانت محتوى).

## Rule 008 — No Hidden Network
أي اتصال شبكي يحتاج `DEC-` صريح. الشبكة ممنوعة في v1 إلا في Phase 07 (التلاوة).

## Rule 009 — No Silent Content Change
أي تغيير في المحتوى الديني يحتاج: مصدر + إصدار + مراجعة + checksum جديد.

## Rule 010 — No Silent License Change
أي تغيير في الترخيص يحتاج مراجعة قانونية معتمدة.

## Rule 011 — Evidence Required
ادعاء النجاح يحتاج دليلًا حرفيًا (ناتج الأمر، لقطة، سجل CI).

## Rule 012 — CI Is Authoritative
فشل بوابة CI إلزامية = المستودع غير قابل للإصدار.

## Rule 013 — Phase Lock
المراحل المقفلة لا تُنفَّذ.

## Rule 014 — Change Propagation
عند تغيير قرار: تُحدَّد كل الوثائق والكود والاختبارات وCI المتأثرة وتُحدَّث.

## Rule 015 — Contradiction Prevention
لا يجوز أن يُدخل PR تعارضًا معروفًا.

## Rule 016 — Uncertainty
`UNKNOWN ≠ APPROVED`. المجهول = غير محسوم.

## Rule 017 — No Backward Documentation
لا يُخفى قرار تنفيذي حتى ما بعد التنفيذ.

## Rule 018 — Release Gate
لا إصدار مع فجوات مانعة غير محسومة.

## Rule 019 — Reproducibility
نتائج البناء والتحقق يجب أن تكون قابلة للتكرار (إصدارات مثبتة، لا `latest`).

## Rule 020 — Human Approval
القرارات القانونية والشرعية والمرحلية التي تحتاج اعتمادًا بشريًا لا يولّدها الـAI.