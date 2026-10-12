# NEXT_SESSION — اقرأني أولاً

> آخر تحديث: 2026-10-12
> الحالة: Phase 04 ✅ COMPLETED → Phase 05 — بانتظار spec

## المرحلة الحالية
- Phase 04: ✅ COMPLETED (2026-10-12) — output report: docs/phase-04-output-report.md
- Phase 05: ⏳ NOT STARTED — بانتظار تحديد النطاق

## المتبقي
- CR-0015 Multi-Adhan (Phase 05+).
- Task 11c — real call device test (Phase 05 device session).
- GAPs: task6-interruption (P2), boot-no-recalc, format-time-dup, night-thirds-2x-calc, all-prayers-disabled-hint, license-page, cr0013-photo, integration-player-race, deeplink-host-loss (كلها P3).

## Commit HEAD
a7d52cd

## الجهاز المرجعي
Oppo A95 (CPH2365, Android 13) — OD-0029

## دروس رئيسية (Phase 04)
1. Android notification sound: WAV لا يعمل → OGG.
2. Flutter default deep linking → path-only (solution A+).
3. integration_test على ColorOS: force-stop إلزامي قبل كل run.
4. Never amend pushed commits → reset --hard origin/main + forward commit.
5. Notification channels: immutability → v2 عند تغيير sound.
6. Notification 2:34 adhan plays fully — لا truncation على Oppo A95.

## Phase 05+ — CR-0015 Multi-Adhan (مُسجَّل، لا تنفيذ)
- 3 خيارات CC0:
  1. Beautiful_adhan.ogg (CC0) — default
  2. Mecca 2013 (CC-BY 3.0، Seyfula Islam) — يحتاج استخراج + attribution
  3. Madinah CC0 (يُبحث ويتحقق في CR-0015)
- UI: Dropdown في `/settings/notifications` + معاينة.
- معمارية: قناة ديناميكية + إعادة إنشاء عند التغيير.
- سبب التأجيل: حجم APK + channel immutability complexity.
