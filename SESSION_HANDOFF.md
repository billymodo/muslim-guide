# Session Handoff Log

> \*\*سجل تراكمي. آخر إدخال في الأعلى.\*\*
> لا تحذف الإدخالات القديمة — هي ذاكرة المشروع.

\---

## Session 7 — 2026-10-06 (Phase 00B: steps 1-3)

### ما نُفِّذ

**Step 1 — إنشاء `spike/`**

* مشروع Flutter مستقل داخل `spike/` (Android فقط)
* اسم: `muslim\_guide\_spike`
* 5 حزم exact (بلا `^`):

  * `flutter\_local\_notifications 22.3.1`
  * `timezone 0.11.1`
  * `hive\_ce 2.20.1`
  * `audio\_service 0.18.19`
  * `just\_audio 0.10.6`
* 8 صلاحيات Android في manifest الـspike فقط
* `analysis\_options.yaml` يستثني `spike/\*\*`
* إصلاح build error: `isCoreLibraryDesugaringEnabled=true` + `desugar\_jdk\_libs:2.1.4`
* `spike/README.md`, `RESULTS.md`, `evidence/.gitkeep`

**Step 2 — CR-0004 + phases update**

* `governance/cr/CR-0004-audio-in-spike.md` (معتمد)
* `phases/00b-spike.md`: حذف بند iOS (N/A — deferred to v2.0)
* `spike/RESULTS.md`: قسم Build Issues

**Step 3 — CI jobs جديدة**

* 5 سكربتات في `tool/`:

  * `check\_test\_count.sh` (CI-012)
  * `check\_no\_print.sh` (CI-014)
  * `check\_no\_internet.sh` (CI-015)
  * `check\_no\_network\_pkg.sh` (CI-016)
  * `check\_no\_placeholder.sh` (CI-017)
* `.github/workflows/ci.yml`: +5 jobs (SHA-pinned, ubuntu-24.04)
* `ci/01-ci-checks.md`: +عمود Phase
* `ci/00-ci-policy.md`: تحديث
* `legal/policy.yaml`: قسم `ci.exemptions`
* `.gitattributes`: `\*.sh text eol=lf`
* `tool/test\_count\_baseline.txt = 2`
* `governance/cr/CR-0005-ci-job-names-expanded.md` (pending push)

### ما توقف

* **بانتظار:** push + PR تجريبي للتحقق من CI
* **السبب:** يجب التأكد من نجاح كل الـ9 jobs قبل الانتقال للخطوة 4

### الملفات المتأثرة

جديد:

* `spike/` (35+ ملف من flutter create + main.dart + test)
* `tool/\*.sh` (5 سكربتات)
* `tool/test\_count\_baseline.txt`
* `governance/cr/CR-0004-\*.md`, `CR-0005-\*.md`
* `.gitattributes`

معدّل:

* `.github/workflows/ci.yml`
* `ci/00-ci-policy.md`, `ci/01-ci-checks.md`
* `legal/policy.yaml`
* `phases/00b-spike.md`
* `spike/android/app/src/main/AndroidManifest.xml`
* `spike/android/app/build.gradle.kts`
* `analysis\_options.yaml` (الجذر)

### القرارات المتخذة

* baseline = 2 (العدّاد يحسب testID فريدة)
* SHA pinning إلزامي (Rule 019) — اقتراحي بـ `@v4` رُفض
* CR-0005 موثق (توسيع عقد أسماء CI)
* `spike/` معفى من CI-015/016/017

### للجلسة القادمة

1. `git add -A \&\& git commit` + `git push`
2. افتح PR تجريبي (`test/ci-step-3`)
3. راقب CI (9 jobs كلها ✅)
4. ابدأ Step 4 — بناء Spike كامل

\---

## Session 6 — 2026-10-06 (Phase 00: closed)

### ما نُفِّذ

* تنفيذ كامل لـ Phase 00
* Flutter 3.47.5 مثبت, Dart 3.13.4
* `pubspec.yaml` + `pubspec.lock`
* `analysis\_options.yaml` (very\_good\_analysis 11.0.0)
* `.github/workflows/ci.yml` (4 jobs: asset-scan, analyze, test, build-debug)
* `LICENSES.md`
* هيكل مجلدات + `.gitkeep`
* DEC-0014..0018
* إغلاق OD-0001/0006/0018/0019
* `approvals.yaml` محدّث
* `phases/00-foundation.md` (Status: APPROVED)
* `docs/phase-00-output-report.md`
* CI run: 37384176239 (success)

### القرارات

* MIT License
* Android only, minSdk 24, targetSdk 34
* Riverpod 2.6.1 (exact)
* Pixel 6a reference device
* Phase-Aware CI Rollout (Option A)
* applicationId: `com.muslimguide.app`

### CRs

* CR-0001: CI rollout
* CR-0002: Phase A → 00
* CR-0003: minSdk 24

\---

## Session 5 — 2026-10-05/06 (MASTER\_SPEC finalized)

### ما نُفِّذ

* إصلاح 5 ملفات بترميز مزدوج (CP1256 → UTF-8)
* اختبار 5 جولات فحص
* تجهيز MASTER\_SPEC النهائي (70 ملف)

### القرارات

* Phase A = Phase 00 (توحيد التسمية)

\---

## Session 4 — 2026-10-05 (MASTER\_SPEC structure)

### ما نُفِّذ

* بناء هيكل `MASTER\_SPEC/` كامل (70 ملف)
* 10 مجلدات فرعية
* شجرة كاملة

\---

## Session 1-3 — 2026-10-04/05 (Planning)

### ما نُفِّذ

* تقييم `MASTER\_ROADMAP v3.0`
* مراجعة `Master Specification` المقترح
* Audit شامل
* دمج `CONTENT\_REGISTRY` مع `legal/assets.yaml`

### القرارات

* البنية الموزعة (لا وثيقة واحدة ضخمة)
* مصدر واحد لكل معلومة (Canonical Map)
* مراجع شرعي عبر HTML + JSON
* AR + EN مع اختيار عند التنصيب

\---

## قالب الإدخال (للجلسات القادمة)

```markdown
## Session N — YYYY-MM-DD (Phase XX step Y)

### ما نُفِّذ
- ...

### ما توقف
- \*\*بانتظار:\*\* ...
- \*\*السبب:\*\* ...

### الملفات المتأثرة
جديد:
- ...

معدّل:
- ...

### القرارات المتخذة
- ...

### للجلسة القادمة
1. ...
2. ...





\---



\## 🎯 خطوات الحفظ



\### 1. احفظ الملفات الثلاثة



افتح Notepad (بترميز UTF-8) واحفظ كل ملف في:

C:\\Users\\Abdo\\Desktop\\Muslim\_Guide

├── NEXT\_SESSION.md

├── PHASE\_PROGRESS.md

└── SESSION\_HANDOFF.md



text



\### 2. commit + push



```powershell

cd C:\\Users\\Abdo\\Desktop\\Muslim\_Guide

git add NEXT\_SESSION.md PHASE\_PROGRESS.md SESSION\_HANDOFF.md

git commit -m "governance: add session continuity protocol (3 files)"

git push

3\. تحقق من سلامة الملفات

powershell

\# عدد الأسطر

Write-Host "NEXT\_SESSION: $((Get-Content NEXT\_SESSION.md).Count) lines"

Write-Host "PHASE\_PROGRESS: $((Get-Content PHASE\_PROGRESS.md).Count) lines"

Write-Host "SESSION\_HANDOFF: $((Get-Content SESSION\_HANDOFF.md).Count) lines"



\# تأكد من عدم وجود تشويه عربي

Select-String -Path \*.md -Pattern 'ط¸|ط§|â€' | Select-Object -First 5

المتوقع:



كل ملف > 50 سطر



لا نتائج للبحث العربي المشوّه

