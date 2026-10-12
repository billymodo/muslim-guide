# NEXT_SESSION — اقرأني أولاً

## الحالة (2026-10-11 ~16:00 EEST)

### Phase 04 — ACTIVE (~85%)
- Tasks 1-10 ✅ (489 unit/widget PASS, 4 integration files, build ✅)
- Task 11a ✅ (T-A +44.888s, within ±60s)
- Task 11b 🟡 (partial — background/reboot, Task 4 partial)
- Task 11c ⏸️ (real call — PENDING, GAP-task6-device-interruption)
- Task 12 ⏸️ (Owner selects adhan audio — placeholder in code)
- Output report: DRAFT ([docs/phase-04-output-report.md](docs/phase-04-output-report.md))

### الجلسة القادمة
1. Task 11c — device test (مكالمة حقيقية لمقاطعة الصوت)
2. Task 12 — Owner: مرشحي الأذان (3-5, Rule 020)
3. Phase 04 closeout (output report DRAFT → APPROVED)
4. فتح Phase 05 (TBD)

### main HEAD
430f6aa

### تنبيهات
- لا push دون موافقة صريحة.
- اختبارات audio integration على ColorOS: force-stop قبل كل run + إعادة تثبيت بعده (الدرس في docs/phase-04-device-testing.md).
- ملفات `*_hang_log.txt` + `int_test_output.txt` مؤرشفة في .gitignore.

## Phase 05+ — CR-0015 Multi-Adhan (مُسجَّل، لا تنفيذ)
- 3 خيارات CC0:
  1. Beautiful_adhan.ogg (CC0) — default
  2. Mecca 2013 (CC-BY 3.0، Seyfula Islam) — يحتاج استخراج + attribution
  3. Madinah CC0 (يُبحث ويتحقق في CR-0015)
- UI: Dropdown في `/settings/notifications` + معاينة.
- معمارية: قناة ديناميكية + إعادة إنشاء عند التغيير.
- سبب التأجيل: حجم APK + channel immutability complexity.
