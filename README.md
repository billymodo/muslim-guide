# دليل المسلم — Master Specification

## الغرض
هذا المجلد هو **مصدر الحقيقة الوحيد** لمتطلبات وقرارات ومعمارية وسياسات مشروع «دليل المسلم».
لا يُعتبر أي شيء خارج هذه المواصفات قرارًا معتمدًا.

## الحالة الحالية
- Current Phase: **Phase 00 (Foundation)**
- Phase B Status: **LOCKED**
- لا تبدأ Phase B إلا بالعبارة الصريحة: **«اعتماد المرحلة A»**

## الرؤية
تطبيق Flutter إسلامي، يعمل **Offline بالكامل**، بلا حسابات ولا تتبع، بمحتوى معتمد،
باللغتين **العربية والإنجليزية**، مع اختيار اللغة عند أول تشغيل.

## قواعد أساسية (Anti-Conflict Rules)

1. **No Guessing** — إذا لم توجد معلومة معتمدة: `UNKNOWN`، وليس "قرر الـAI".
2. **No Silent Decisions** — كل قرار جديد يدخل `03-decisions.md`.
3. **Open Decision Blocks Implementation** — إذا كان التنفيذ يعتمد على `OD-XXXX` مفتوح: التنفيذ = **BLOCKED**.
4. **Conflict Blocks Release** — إذا وُجد `CON-XXXX` مفتوح يؤثر على الكود/المحتوى/الترخيص: الإصدار = **BLOCKED**.
5. **Requirement Without Test** — كل `MUST` له اختبار أو مبرر موثق.
6. **Code Without Requirement** — أي ميزة جديدة يجب أن تشير إلى `REQ-XXX`.
7. **External Asset Without License Record** — أصل بلا سجل في `legal/assets.yaml` = **BLOCK**.
8. **License Without Evidence** — ادعاء ترخيص بلا دليل = **BLOCK**.
9. **Documentation Drift** — اختلاف ملف مولّد عن مصدره = **CI FAIL**.
10. **Phase Lock** — Phase B بلا العبارة الصريحة = **LOCKED**.

## قاعدة الأولوية عند التعارض

1. Security / Legal constraints
2. Explicit approved decisions (`03-decisions.md`)
3. Project charter
4. Requirements
5. Architecture
6. Phase specification
7. Implementation details
8. AI suggestions

أي تعارض غير محسوم = **OPEN CONFLICT**، ولا يُسمح للـAI بالتخمين.

## مصدر واحد لكل معلومة (Canonical Map)

| المعلومة | المصدر الرسمي |
|---|---|
| قواعد التكامل | `00-integrity-rules.md` |
| قرارات المشروع | `03-decisions.md` |
| قرارات لم تُحسم | `04-open-decisions.md` |
| تعارضات وفجوات | `05-conflicts-and-gaps.md` |
| سجل العيوب | `06-defect-register.md` |
| المتطلبات | `01-requirements.md` |
| النطاق | `02-scope-and-boundaries.md` |
| المعمارية | `architecture/` |
| خصائص المنتج | `product/` |
| المحتوى | `content/` |
| التراخيص | `legal/` |
| الأصول | `legal/assets.yaml` |
| اعتمادات المراحل | `approvals.yaml` |
| الجودة | `quality/` |
| الأمن | `security/` |
| CI | `ci/` |
| المراحل | `phases/` |
| قرارات معمارية | `adr/` |
| قواعد الـAI | `governance/01-ai-development-rules.md` |
| تقرير المخرجات | `governance/05-output-report-template.md` |

## إحصائيات المستودع

- إجمالي الملفات: **73 ملفًا** (وثائق MASTER_SPEC — تُستثنى ملفات التطبيق و `build/` outputs)
- إجمالي المجلدات: **12 مجلدًا** (بجانب المجلد الجذر)

## الوثائق المرجعية (فهرس)

- `00-integrity-rules.md` — قواعد التكامل 001–020
- `00-project-charter.md` — هوية المشروع وحدوده
- `docs/PROJECT_STORY.md` — خلفية المشروع ورؤيته ودروس 
- `docs/UI_VISION.md` — رؤية تصميم الواجهات (طويلة المدى)
التنفيذ
- `docs/DIRECTOR_PLAYBOOK.md` — أسلوب توجيه الوكيل
- `01-requirements.md` — المتطلبات
- `02-scope-and-boundaries.md` — النطاق
- `03-decisions.md` — القرارات المعتمدة
- `04-open-decisions.md` — القرارات المفتوحة
- `05-conflicts-and-gaps.md` — التعارضات والفجوات
- `06-defect-register.md` — سجل العيوب (D-01…D-25)
- `approvals.yaml` — اعتمادات المراحل