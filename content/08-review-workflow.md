# Content Review Workflow (HTML + JSON)

- **Status**: DRAFT (v2)
- **Owner**: Project owner
- **Related Decisions**: DEC-0013
- **Related Files**: `content/reviewers.yaml`, `legal/assets.yaml`, `legal/schema/asset.schema.yaml`

## Purpose

كل pack محتوى ديني يمر بمسار مراجعة موثق، والاعتماد مكتوب ومربوط بـ checksum وإصدار محدد.
لا اعتماد شفهي، ولا اعتماد بلا checksum.

## Roles

| الدور | المسؤولية |
|---|---|
| المطوّر | الاستيراد، الفحوصات الآلية، توليد HTML/JSON، دمج التعديلات |
| المراجع الشرعي | مراجعة محتوى pack ضمن نطاقه فقط (`reviewers.yaml`) |
| مراجع الترخيص | قرار بشري بشأن الترخيص (Rule 020) |

قواعد الإسناد:
- المراجع يُعرَّف بمعرّفه في `reviewers.yaml` (مثل `shaykh-1`)، وهو نفسه المستخدم في JSON و`assets.yaml`.
- لا يعتمد مراجع pack خارج نطاقه.
- محتوى الترجمة الإنجليزية يحتاج مراجعًا متمكنًا من الإنجليزية (تُسجَّل مراجعته في `reviewers.yaml`).
- يُنصح بمراجع احتياطي لكل نطاق لتفادي الاعتماد على شخص واحد.

## Steps

1. **استلام الحزمة** من المصدر المعتمد: رابط + تاريخ + نسخة (version).
2. **التحقق من الترخيص**: مراجعة مطوّر + قرار بشري، وحفظ الدليل (snapshot + sha256) في `evidence`. بلا ذلك يتوقف المسار.
3. **الاستيراد** بسكربت قابل لإعادة التشغيل إلى JSON منظم، دون أي تطبيع أو تعديل للنص.
4. **الفحوصات الآلية (CI)**:
   - صحة schema.
   - checksum مطابق (انظر Checksum Rules).
   - القرآن: 114 سورة + عدد الآيات لكل سورة.
   - لا اختلاف عن المصدر.
   - لا placeholder.
5. **توليد ملف HTML للمراجعة** (انظر HTML Template).
6. **إرسال HTML + JSON** للمراجع المختص عبر قناة آمنة (بريد آمن أو ملف مشفر).
7. **المراجع يراجع** ويُعيد ملف القرارات (JSON).
8. **المطوّر يدمج القرارات** ويُعيد الفحص الآلي (الخطوة 4).
9. **توقيع الاعتماد**: الاسم (الدور) + التاريخ + رقم إصدار الحزمة + checksum النهائي.
10. **تحديث `legal/assets.yaml`**: `status`، `reviewed_at`، `review_expires_at`، `checksum`، `evidence`، `reviewer`.
11. **قفل الحزمة**: أي تغيير لاحق = العودة إلى الخطوة 3.

## Rules

- لا اعتماد شفهي.
- لا اعتماد بلا checksum.
- لا اعتماد بلا ترخيص محسوم (الخطوة 2).
- أي تعديل لاحق على المحتوى = إعادة من الخطوة 3.
- مراجعة منتهية (`review_expires_at` في الماضي) = **BLOCK**.
- النص القرآني: ممنوع تعديله من نتيجة المراجعة. أي ملاحظة عليه تُحوَّل إلى مقارنة مع المصدر ومراسلة صاحب المصدر، لا إلى تعديل مباشر.
- الحالة `edited` لا تُطبَّق تلقائيًا: يلزم أن يذكر المراجع مصدر التعديل، ويُحفَظ النص الأصلي والمقترح معًا.
- المطوّر لا يكتب أي نص ديني من الذاكرة لإكمال تعديل.

## Checksum Rules

- الخوارزمية: `sha256`.
- يُحسب على **ملف JSON المنسَّق قانونيًا (canonical)**: ترميز UTF-8 بلا BOM، ترتيب مفاتيح ثابت، فواصل ثابتة، نهاية سطر `\n`.
- ممنوع أي تطبيع Unicode (NFC/NFD) صامت على النص العربي؛ يُحفَظ النص كما ورد من المصدر.
- يُسجَّل اسم الطريقة في `checksum_method` ضمن `assets.yaml`.
- حقل `approval` وحقول `review` لا تدخل في حساب checksum المحتوى (checksum للمحتوى فقط).

## HTML Template

الملف مستقل بذاته (لا موارد خارجية، لا شبكة)، ويعمل دون اتصال.

```html
<!DOCTYPE html>
<html dir="rtl" lang="ar">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>مراجعة: azkar-hisn v0.3</title>
</head>
<body>
  <h1>حزمة: azkar-hisn — v0.3</h1>
  <p>المصدر: حصن المسلم — ص 12-15</p>
  <p>checksum المحتوى: <code>sha256:...</code></p>

  <div class="item" data-id="azkar-001">
    <h3>الذكر #1</h3>
    <p class="arabic">...</p>
    <p class="source">رواه مسلم (2723)</p>
    <div class="actions">
      <button onclick="decide('azkar-001','approved')">موافق</button>
      <button onclick="decide('azkar-001','edited')">تعديل</button>
      <button onclick="decide('azkar-001','rejected')">رفض</button>
    </div>
    <textarea data-notes="azkar-001" placeholder="ملاحظات / مصدر التعديل..."></textarea>
  </div>

  <button onclick="exportDecisions()">حفظ القرارات (JSON)</button>

  <script>
    const decisions = {};
    function decide(id, status) { decisions[id] = status; }
    function exportDecisions() {
      const out = Object.entries(decisions).map(([id, status]) => ({
        id,
        status,
        notes: document.querySelector('[data-notes="' + id + '"]').value,
        decided_at: new Date().toISOString()
      }));
      const blob = new Blob([JSON.stringify(out, null, 2)], { type: 'application/json' });
      const a = document.createElement('a');
      a.href = URL.createObjectURL(blob);
      a.download = 'decisions.json';
      a.click();
    }
  </script>
</body>
</html>
```

## JSON Schema (مثال)

```json
{
  "pack_id": "azkar-hisn",
  "version": "0.3",
  "source": {
    "name": "حصن المسلم",
    "author": "د. سعيد بن علي بن وهف القحطاني",
    "pages": "12-15",
    "url": "..."
  },
  "items": [
    {
      "id": "azkar-001",
      "arabic": "...",
      "translation_en": "...",
      "source_ref": "مسلم (2723)",
      "review": {
        "status": "pending",
        "reviewer_id": "shaykh-1",
        "notes": "",
        "proposed_text": null,
        "edit_source": null,
        "decided_at": null
      }
    }
  ],
  "checksum": "sha256:...",
  "checksum_method": "canonical-json-sha256-v1",
  "approval": {
    "reviewer_id": "shaykh-1",
    "reviewer_role": "مراجع شرعي",
    "approved_at": null,
    "version_approved": null,
    "checksum_approved": null
  }
}
```

## Review States

| الحالة | المعنى |
|---|---|
| `pending` | لم تُراجَع بعد |
| `approved` | معتمدة كما هي |
| `edited` | يقترح المراجع تعديلًا مع مصدره، ولا تُطبَّق قبل تحقق المطوّر وإعادة المراجعة |
| `rejected` | مرفوضة، لا تدخل الإنتاج |

الاعتماد النهائي للحزمة لا يتم إلا إذا كانت **كل** العناصر `approved`.

## Evidence

يُحفَظ لكل دورة مراجعة:
- ملف HTML المُرسَل وJSON المُرسَل (مع sha256).
- ملف القرارات المُستلَم.
- سجل CI للفحوصات الآلية بعد الدمج.
- سجل التوقيع (الاسم، التاريخ، الإصدار، checksum).
