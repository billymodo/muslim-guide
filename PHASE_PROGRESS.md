\# Phase Progress — Snapshot



> \*\*آخر تحديث:\*\* 2026-10-06 (Phase 00B, step 4 — في التنفيذ)

> \*\*يُحدَّث:\*\* بعد كل خطوة (الوكيل مسؤول)



\---



\## المرحلة الحالية



\*\*Phase 00B — Spike: الإشعارات والصوت\*\*



| البند | القيمة |

|---|---|

| Status | 🟢 ACTIVE |

| Started | 2026-10-06 |

| Current Step | 4 / 6 ✅ — Step 5 مؤجّل (جهاز) |

| Blockers | Step 5 يحتاج جهاز فيزيائي — الحل: OD-0022 (Deadline: قبل Phase 04) |

| Exit Criteria | اختبار على جهاز حقيقي (Pixel 6a) + جدول نتائج |



\### الخطوات الست



| # | الخطوة | الحالة |

|---|---|---|

| 1 | إنشاء `spike/` كامل | ✅ |

| 2 | CR-0004 + تحديث phases | ✅ |

| 3 | CI jobs (CI-012/014/015/016/017) | ✅ PR #2 — 9/9 success |

| 4 | بناء Spike كامل | ✅ |

| 5 | اختبار وظيفي (جهاز فقط) | ⏳ مؤجّل — OD-0022 |

| 6 | توثيق النتائج + إغلاق 00B (سيُدمج مع Step 5) | ⏳ |

## Blockers

- Step 5: يحتاج جهاز Android فيزيائي
- **الحل:** OD-0022
- **Deadline:** قبل Phase 04



\---



\## المراحل المكتملة



| المرحلة | Status | التاريخ | Output Report |

|---|---|---|---|

| Phase 00 — Foundation | ✅ APPROVED | 2026-10-06 | `docs/phase-00-output-report.md` |



\### Phase 00 — ملخص ما تحقق



\- ✅ `flutter analyze --fatal-infos` (No issues)

\- ✅ `flutter test` (1/1 pass)

\- ✅ `flutter build apk --debug` (Built)

\- ✅ CI على PR تجريبي (run 37384176239 — success)

\- ✅ GitHub repo + push

\- ✅ 10 مخرجات أساسية



\---



\## المراحل القادمة



| المرحلة | الإصدار | Prerequisites | Blockers |

|---|---|---|---|

| Phase 01 — Foundation | v0.1 | 00B مكتملة | OD-0008, OD-0010, OD-0012, OD-0013 |

| Phase 02 — Prayer | v0.2 | 01 | OD-0011 |



\---



\## آخر 5 commits



\*(يُحدَّث من `git log --oneline -5`)\*

(git log --oneline -5 هنا)



text



\---



\## آخر 5 قرارات (DECs)



| DEC | التاريخ | الموضوع |

|---|---|---|

| DEC-0018 | 2026-10-06 | Phase-Aware CI Rollout |

| DEC-0017 | 2026-10-06 | Pixel 6a (reference device) |

| DEC-0016 | 2026-10-05 | Riverpod 2.6.1 (exact pin) |

| DEC-0015 | 2026-10-05 | Android only, minSdk 24 |

| DEC-0014 | 2026-10-05 | MIT License |



\---



\## Change Requests (CRs)



| CR | الموضوع | الحالة |

|---|---|---|

| CR-0001 | CI rollout (Phase-Aware) | ✅ APPROVED |

| CR-0002 | Phase A → Phase 00 (تسمية) | ✅ APPROVED |

| CR-0003 | minSdk 24 (تعديل DEC-0015) | ✅ APPROVED |

| CR-0004 | audio\_service + just\_audio في spike | ✅ APPROVED |

| CR-0005 | توسيع عقد أسماء CI jobs | ✅ APPROVED |



\---



\## Open Decisions المؤثرة الآن



\*\*لا OD تعطّل Phase 00B حالياً.\*\*



\### OD التالية للـPhase 01



| OD | الموضوع | Blocking |

|---|---|---|

| OD-0008 | ترحيل بيانات المستخدم (schemaVersion + migrations) | Phase 01 |

| OD-0010 | سجل الأخطاء المحلي (صيغة + تصدير) | Phase 01 |

| OD-0012 | الأرقام (عربية هندية أم لاتينية) | Phase 01 |

| OD-0013 | تشفير Hive (اختياري + تخزين المفتاح) | Phase 01 |



\---



\## ملفات مهمة



\### المرحلة الحالية

\- `phases/00b-spike.md`

\- `spike/` (مشروع تجريبي — سيُحذف بعد 00B)

\- `governance/cr/CR-0004-audio-in-spike.md`



\### بنية المشروع الرئيسي

\- `lib/` — الكود الرئيسي (لم يُلمس بعد)

\- `test/` — اختبارات الجذر

\- `tool/` — سكربتات CI (5 سكربتات جديدة)

\- `.github/workflows/ci.yml` — 9 jobs (4 أساسية + 5 جديدة)



\### الوثائق الأساسية

\- `README.md` — نقطة الدخول

\- `00-integrity-rules.md` — 20 قاعدة

\- `governance/01-ai-development-rules.md` — قواعد الوكيل

\- `03-decisions.md` + `04-open-decisions.md`

\- `05-conflicts-and-gaps.md`

\- `06-defect-register.md`



\---



\## ملاحظات حرجة



1\. \*\*لا تلمس `lib/` في Phase 00B\*\* — كل شيء داخل `spike/`.

2\. \*\*جهاز فيزيائي مطلوب\*\* — Pixel 6a أو Redmi Note 12 (DEC-0017).

3\. \*\*`spike/` معفى من CI-015/016\*\* — عبر `legal/policy.yaml`.

4\. \*\*baseline test count = 2\*\* — لا تنزل تحته (CI-012).

5\. \*\*SHA pinning إلزامي\*\* في GitHub Actions (Rule 019).



\---



\## مسار النجاح

Phase 00B step 3 → push + PR → راجع CI

↓

Phase 00B step 4 → بناء Spike كامل

↓

Phase 00B step 5 → اختبار وظيفي

↓

Phase 00B step 6 → جهاز فيزيائي

↓

Phase 00B مكتملة → Phase 01

