# Asset Policy



## Principle

كل أصل خارجي (نص، صوت، خط، صورة، بيانات، كود) يُعامل كتبعية مُتحكَّم بها.

لا يدخل الإنتاج بلا سجل في `legal/assets.yaml`.



## Lifecycle

PROPOSED

↓

SOURCE_IDENTIFIED

↓

LICENSE_REVIEW

↓

CONTENT_REVIEW

↓

TECHNICAL_REVIEW

↓

APPROVED

↓

INTEGRATED

↓

VERIFIED_IN_BUILD





## Failure States

- `BLOCKED` — مانع قانوني/شرعي.

- `REJECTED` — مرفوض نهائيًا.

- `NEEDS_REVIEW` — يحتاج قرارًا بشريًا.



## Rules

- كل أصل له `asset_id` فريد.

- كل أصل له `provider` و`source_url`.

- كل أصل له `license_type` موثق.

- `redistribution_allowed` صريح (true/false).

- `evidence` مطلوب عند الاعتماد.

- `reviewer` مطلوب لأصول المحتوى الديني.

- `phase` يحدد أول مرحلة تستخدمه.



## Schema

- `legal/schema/asset.schema.yaml`



## Registry

- `legal/assets.yaml`



## Related

- `legal/00-licensing-policy.md`

- `legal/02-attribution-policy.md`

- `legal/03-review-policy.md`

