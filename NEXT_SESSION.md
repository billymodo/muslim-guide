# NEXT_SESSION — اقرأني أولاً

> آخر تحديث: 2026-10-13
> الحالة: Phase 05-A/B ✅ → Phase 05-C (Multi-Adhan) — للبدء

## المرحلة الحالية
- Phase 05-A: ✅ Audit & Cleanup
- Phase 05-B: ✅ Calculation Method UI
- Phase 05-C: ⏳ Multi-Adhan (CR-0015) — بانتظار البدء

## المتبقي
- CR-0015 Multi-Adhan (3 CC0).
- Task 11c real call.
- GAPs: task6-interruption (P2), layout-coupling (P2), in-call-adhan-fallback (P3), atomic-commit-gap (P3).

## Commit HEAD
33773c5 (أو أحدث)

## الجهاز
Oppo A95 (CPH2365, Android 13)

## دروس Phase 05
1. PowerShell `Set-Content` يُفسد UTF-8 (خاصة العربية) → محرر فقط.
2. `git add <explicit list>` قد يفوّت ملفات → `git status` قبل commit.
3. Widget tests: section-specific أفضل من mega-tests.
4. Test + production في نفس الـcommit (atomic).
5. ListView lazy: لا تطالب بأعلى+أسفل في نفس الاختبار.
6. Android in-call: audio focus blocks adhan (expected).

