# Content Policy



## Principle



المحتوى الديني يجب أن يكون:

1. مُحدد الهوية

2. مُحدد المصدر

3. مُرقَّم الإصدار

4. مُراجَع شرعيًا

5. مُراجَع قانونيًا

6. مُتحقق تقنيًا



## No Unverified Religious Content



لا يدخل الإنتاج لمجرد أنه:

- متاح أونلاين

- مشهور

- تستخدمه تطبيقات أخرى

- يوفره API

- موجود على GitHub

- موصوف بأنه مجاني/مفتوح/عام



## Content Changes



كل تغيير يحدد:

- المصدر

- الإصدار/الطبعة

- المراجع

- الدليل

- التاريخ

- الأصول المتأثرة



## Forbidden



- كتابة أي نص قرآني/حديث/دعاء من الذاكرة.

- استخدام placeholders في الإنتاج.

- تعديل النص بلا مصدر + مراجعة + checksum جديد.



## Placeholders in Development



يُسمح بـ`[PLACEHOLDER-AYAH]` في مرحلة التطوير فقط.

CI يفشل إذا وُجد placeholder في `main`.



## Registered Content Packs



### النص القرآني والترجمة

- `quran-uthmani` (Tanzil)

- `quran-translation-en` (Saheeh International)

- `quran-tafsir-ar` (التفسير الميسر)

- `quran-tafsir-en` (QuranEnc)



### الأذكار والأدعية

- `azkar-hisn` (حصن المسلم)

- `azkar-json-dataset`



### الحديث

- `hadith-dorar`

- `hadith-hadeethenc`



### بيانات مساعدة

- `cities-major`

- `prayer-methods`



### الصوت

- `adhan-audio-cc0`

- `quran-recitation` (BLOCKED حتى OD-0007)



### الخطوط

- `amiri-quran-font`



> **ملاحظة:** كل pack مسجّل في `legal/assets.yaml`. لا pack بلا سجل.



## Review Workflow



- المسار الكامل: `content/08-review-workflow.md`

- المراجعون: `content/reviewers.yaml`

✅ قائمة التحقق بعد النسخ



[ ] حذفت: architecture/ADR.txt

[ ] حذفت: هيكل المجلد.txt

[ ] أعدت تسمية: open-decisions.md → 04-open-decisions.md

[ ] أعدت تسمية: conflicts-and-gaps.md → 05-conflicts-and-gaps.md

[ ] أعدت تسمية: defect-register.md → 06-defect-register.md

[ ] أنشأت: architecture/07-localization.md

[ ] أنشأت: content/reviewers.yaml

[ ] أنشأت: legal/01-asset-policy.md

[ ] أنشأت: adr/ADR-0001-flutter-version.md

[ ] استبدلت: architecture/01-system-architecture.md

[ ] استبدلت: architecture/06-folder-structure.md

[ ] استبدلت: adr/README.md

[ ] استبدلت: governance/00-change-control.md

[ ] استبدلت: governance/01-ai-development-rules.md

[ ] استبدلت: governance/03-traceability.md

[ ] استبدلت: governance/04-documentation-rules.md

[ ] استبدلت: governance/05-output-report-template.md

[ ] استبدلت: ci/03-release-pipeline.md

[ ] استبدلت: phases/README.md

[ ] استبدلت: legal/assets.yaml

[ ] استبدلت: 06-defect-register.md

[ ] استبدلت: README.md

[ ] استبدلت: product/02-screens.md

[ ] استبدلت: content/00-content-policy.md



