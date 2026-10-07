# NEXT\_SESSION — اقرأني أولاً

> \*\*آخر تحديث:\*\* 2026-10-06
> \*\*الحالة:\*\* Phase 01 — ACTIVE (Data layer مكتمل؛ UI layer قيد البدء)

\---

## أنت الآن

وكيل تنفيذي جديد لمشروع «دليل المسلم».
هذا المشروع موجود في هذا المجلد. أنت **لا تعرف عنه شيئاً بعد**.

## مهمتك الأولى (إلزامية — قبل أي كود)

اقرأ الملفات التالية **بالترتيب الإلزامي**:

1. `PHASE\_PROGRESS.md` — أين نحن الآن (لقطة شاملة)
2. `docs/DIRECTOR_PLAYBOOK.md` — أسلوب التوجيه
3. `SESSION\_HANDOFF.md` — سجل الجلسات السابقة (أول 3 إدخالات)
4. `README.md` — نظرة عامة على المشروع
5. `00-integrity-rules.md` — القواعد فوق كل شيء (Rules 001-020)
6. `governance/01-ai-development-rules.md` — قواعدك أنت
7. `03-decisions.md` — القرارات المعتمدة (DECs)
8. `04-open-decisions.md` — القرارات المفتوحة (ODs)
9. `phases/<current-phase>.md` — المرحلة الحالية
10. `05-conflicts-and-gaps.md` — ما هو معلّق

## بعد القراءة — أجب

قبل أي كود أو تعديل، أرسل لي:

1. ما المرحلة الحالية وحالتها؟
2. ما آخر خطوة نُفِّذت؟
3. ما المطلوب الآن بالضبط؟
4. هل هناك blockers أو قرارات مفتوحة تعطّل العمل؟
5. هل جميع القرارات المطلوبة محسومة؟

**لا تكتب كوداً.** انتظر ردّي.

## قواعدك الصارمة

* التزم بـ `governance/01-ai-development-rules.md` **حرفياً**
* عند أي التباس: **توقف وأبلغ** — لا تخمّن
* لا تقل "منجز" إلا بناتج أمر فعلي (Stop Rule 17)
* لا تتجاوز فشل اختبار — أبلغني (Stop Rule 09)
* بعد كل تعديل: `flutter analyze --fatal-infos` + `flutter test`
* لا تلمس ملفاً خارج نطاق المرحلة الحالية

## عند نهاية كل جلسة

أضف إدخالاً في `SESSION\_HANDOFF.md` وفق القالب الموجود فيه:

* ما نُفِّذ
* ما توقف ولماذا
* الملفات المتأثرة
* القرارات
* ما للجلسة القادمة

ثم حدّث `PHASE\_PROGRESS.md` (اللقطة الشاملة).

## حالة Phase 01

- **Phase 01:** ACTIVE
- **Data layer:** ✅ مكتمل
- **UI layer:** قيد البدء

## معلومات المشروع الأساسية

|البند|القيمة|
|-|-|
|المسار|`C:\\Users\\Abdo\\Desktop\\Muslim\_Guide`|
|المنصة|Flutter (Android only في v1)|
|Flutter|3.47.5|
|Dart|3.13.4|
|minSdk|24|
|targetSdk|34|
|compileSdk|36|
|Riverpod|2.6.1|
|Hive CE|2.20.1 (user data only)|
|GitHub|`billymodo/muslim-guide`|
|اللغات|ar (افتراضي) + en|
|الترخيص|MIT|
|Business Model|مجاني تماماً، بلا إعلانات/تبرعات/اشتراكات|

## الملفات المرتبطة بهذه اللحظة

* **المرحلة النشطة:** `phases/01.md` — UI layer قيد البدء
* **آخر CR:** `governance/cr/CR-0005-ci-job-names-expanded.md` — APPROVED ومرفوع (PR #2: 9/9 success)
* **آخر DEC:** DEC-0018 (Phase-Aware CI Rollout)
* **آخر commit:** (سيُحدَّث في PHASE\_PROGRESS.md)

## مسار بدء سريع



اقرأ PHASE\_PROGRESS.md


اقرأ docs/DIRECTOR_PLAYBOOK.md


اقرأ SESSION\_HANDOFF.md (أول 3 إدخالات)



اقرأ الملفات 3-10



أجب على الأسئلة الخمسة



انتظر "ابدأ"



text



\---



\*\*مرحباً بك في المشروع. عندما تكون جاهزاً، أرسل الأسئلة الخمسة.\*\*
