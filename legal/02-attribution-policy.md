# Attribution Policy

- **Status**: DRAFT (v2)
- **Owner**: Project owner
- **Related Files**: `legal/assets.yaml`, `legal/schema/asset.schema.yaml`, `legal/policy.yaml`, `legal/00-licensing-policy.md`
- **Related CI**: CI-004 (Attribution validation)
- **Related Requirements**: يحتاج `REQ-LEGAL-001` (انظر Gaps أدناه)

## Purpose

ضمان أن كل شرط إسناد (attribution) مفروض بترخيص أصل مشحون:
1. مسجَّل بصيغة قابلة للقراءة آليًا.
2. يظهر للمستخدم داخل التطبيق.
3. يُتحقق منه في CI، ولا يعتمد على ذاكرة المطوّر.

> هذه السياسة تقنية وتنظيمية، وليست استشارة قانونية. صياغة الإسناد الحرفية تُؤخذ من نص كل ترخيص، وتُراجَع بشريًا (Rule 010, Rule 020).

## Source of Truth

| العنصر | المصدر |
|---|---|
| شروط الإسناد لكل أصل | `legal/assets.yaml` (حقول الإسناد أدناه) |
| إشعارات الطرف الثالث (مولَّد) | `legal/generated/THIRD_PARTY_NOTICES.md` |
| صفحة الإسناد داخل التطبيق (مولَّدة) | `assets/legal/attributions.json` |

الملفان المولَّدان **لا يُعدَّلان يدويًا**. الاختلاف بين المولَّد ومصدره = **CI FAIL** (Rule 009 / Documentation Drift).

## Attribution Record (machine-readable)

كل أصل له `attribution_required` في `assets.yaml`. عندما تكون قيمته `true` يلزم وجود كتلة `attribution`:

```yaml
attribution:
  credit_name: "Tanzil.net"                 # الاسم الواجب ذكره
  credit_url: "https://tanzil.net"          # إن اشترط الترخيص رابطًا
  license_name: "..."                       # اسم الترخيص كما في نصه
  license_url: "..."
  license_text_ref: "legal/licenses/<asset_id>.txt"   # نسخة محفوظة من النص
  notice_text:                              # الصيغة الحرفية المطلوبة إن وُجدت
    ar: "..."
    en: "..."
  modification_notice: null                 # إشعار التعديل إن سمح الترخيص بالتعديل
  placement: [settings_licenses_page, third_party_notices]
  verbatim_required: false                  # هل يلزم عرض نص الترخيص كاملًا
```

قواعد:
- `attribution_required: UNKNOWN` في أصل مشحون = **BLOCK**.
- `attribution_required: false` لا يعني عدم التسجيل؛ يبقى الأصل في الإشعارات المولَّدة ما لم يمنع الترخيص ذلك (مثل CC0، يُسجَّل اختياريًا).
- لا تُكتب `notice_text` من الذاكرة؛ تُنقل من نص الترخيص المحفوظ في `license_text_ref`.

## Placement Rules

| نوع الأصل | الحد الأدنى للإسناد |
|---|---|
| text (قرآن، ترجمة، تفسير، حديث، أذكار) | صفحة التراخيص + إشعار المصدر في شاشة العرض إن اشترطه الترخيص |
| audio | صفحة التراخيص + اسم القارئ/المؤذن والمصدر |
| font | صفحة التراخيص + نص الترخيص (OFL يستلزم إرفاق نصه عند التوزيع) |
| data | صفحة التراخيص |
| code (حزم Dart) | صفحة التراخيص (انظر Dependencies) |

- المحتوى الديني يُعرض **حرفيًا** بلا تعديل بسبب الإسناد؛ الإسناد يُضاف حوله لا داخله.
- شرط «عدم التعديل» (مثل Tanzil) يُسجَّل في `conditions` ويُتحقق منه في CI عبر checksum (CI-006).

## In-App Page

- الموقع: الإعدادات → «التراخيص والإسناد».
- تُولَّد من `assets.yaml` أثناء البناء، وتعمل **دون اتصال**.
- تعرض لكل أصل: الاسم، الجهة، الترخيص، رابط المصدر، نص الإسناد الحرفي، وزرًا لعرض نص الترخيص كاملًا.
- عناوين الصفحة وعناصر الواجهة عبر ARB (REQ-L10N-001)، أما نصوص التراخيص فتُعرض بلغتها الأصلية ولا تُترجم.
- قابلة للوصول: Semantics، أهداف لمس ≥ 48dp، تكبير خط حتى 200%.
- رابط المصدر الخارجي يُعرض كنص قابل للنسخ فقط، ولا يفتح متصفحًا إلا بقرار موثق (Rule 008: لا شبكة مخفية، وفتح الروابط خارج التطبيق يحتاج DEC).

## Dependencies (حزم الكود)

- كل حزمة في `pubspec.yaml` يلزم لها سجل في `LICENSES.md` (انظر `security/02-dependencies.md`)، وتُضاف تراخيصها إلى صفحة الإسناد.
- يُستخدم سجل تراخيص Flutter (`LicenseRegistry`) كمصدر لتراخيص الحزم، ويُضاف إليه ترخيص الأصول غير البرمجية (خطوط، محتوى، صوت) عبر `LicenseRegistry.addLicense`.
- حزم LGPL (مثل PrayTimes) تحتاج فحصًا خاصًا لشروط الربط والتوزيع وتوافقها مع ترخيص الكود (OD-0001).

## Generation

- سكربت `tool/generate_notices` يقرأ `assets.yaml` ويولّد:
  - `legal/generated/THIRD_PARTY_NOTICES.md`
  - `assets/legal/attributions.json`
- يعمل في CI على كل PR ويقارن الناتج بالمُلتزَم؛ أي اختلاف = FAIL.
- يفشل السكربت إذا وجد أصلًا مشحونًا بلا بيانات إسناد كاملة.

## CI Checks

| الفحص | الشرط للفشل |
|---|---|
| CI-004 (توسيع) | `attribution_required: true` بلا كتلة `attribution` كاملة |
| CI-004 | `attribution_required: UNKNOWN` لأصل مشحون |
| CI-004 | `license_text_ref` غير موجود أو hash مختلف |
| CI-004 | `notice_text` فارغ حيث `verbatim_required: true` |
| Drift | `THIRD_PARTY_NOTICES.md` أو `attributions.json` لا يطابق المولَّد |
| Coverage | أصل مشحون غير ظاهر في الصفحة المولَّدة |

## Change Triggers

يستلزم تحديث الإسناد (ومراجعة ترخيص حسب `legal/03-review-policy.md`):
- تغيّر المصدر أو الإصدار أو نص الترخيص.
- تغيّر شروط الإسناد.
- إضافة أصل أو حزمة جديدة.
- تعديل المحتوى (مع شرط عدم التعديل = ممنوع أصلًا).

## Release Checklist Link

في `quality/05-release-checklist.md`: «Notices generated» و«THIRD_PARTY_NOTICES current» يجب أن تمر عبر هذه الفحوصات.

## Known Gaps (تحتاج إجراء)

1. **REQ مفقود**: لا يوجد متطلب لصفحة التراخيص والإسناد؛ يُقترح `REQ-LEGAL-001` (MUST).
2. **المخطط**: `asset.schema.yaml` (v2) لا يعرّف كتلة `attribution` بعد؛ يلزم تحديثه إلى v3 قبل تفعيل CI-004 الموسَّع.
3. **مجلد `legal/licenses/`**: غير موجود بعد، ويحوي نسخ نصوص التراخيص.
4. **فتح الروابط الخارجية**: يحتاج قرارًا (DEC/OD) لأنه يلامس سياسة الشبكة.
