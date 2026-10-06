# Phase 00B — Spike: الإشعارات والصوت الخلفي

## Status
APPROVED — Steps 1-5 completed on a physical device (2026-10-06), with audio-focus, long-term OEM/cross-device, and independent audible confirmation deferred to Phase 04.

## Blockers
- لا يوجد blocker لإغلاق Phase 00B.
- Audio focus, long-term OEM/cross-device, and independent audible confirmation remain deferred to Phase 04 (OD-0023/OD-0024).

## Objective
اكتشاف سلوك الإشعارات والصوت في الخلفية **قبل** بناء أي شيء عليه.

## Scope
- تطبيق تجريبي صغير (يُحذف لاحقًا).
- إشعار مجدول يصل بعد **إغلاق التطبيق**.
- نفس الإشعار بعد **إعادة تشغيل الجهاز**.
- exact alarms على Android 12+.
- سلوك أجهزة OEM (Xiaomi، Huawei، …).
- iOS: N/A — deferred to v2.0 (DEC-0015, OD-0021).
- نمط الكتابة من الخلفية بدون مشاكل Hive عبر isolates.
- تشغيل صوت في الخلفية + audio focus + المقاطعات.

## Out of Scope
- تصميم UI نهائي.
- أذان فعلي.

## Dependencies
- CR-0004: audio_service + just_audio (مسموح داخل spike/)

## Exit Criteria
- جدول نتائج على **جهاز حقيقي** (طراز + إصدار نظام + النتيجة).
- قرار موثق في `03-decisions.md`.
- تحديد نمط Hive عبر isolates.

## Evidence Required
- سجل الإشعارات (لقطات).
- سجل الأخطاء.
- قرار موثق.
- Build Issues في spike/RESULTS.md (desugaring)
- Audio focus is deferred to Phase 04 (OD-0023).

## Deviations from Specification
(يُملأ عند التنفيذ)

## Human Review Points
- هل النتائج كافية لـ Phase 04؟

## Step 5 Results

- [x] Foreground notification
- [x] Background notification (with battery-optimization exemption)
- [x] Reboot persistence (scheduled notification restored after boot)
- [x] Exact alarm on Android 13+
- [x] Hive isolate write pattern (`IsolateNameServer` + `SendPort` + ACK)
- [ ] Audio focus during an incoming call — deferred to Phase 04 (OD-0023)
- [ ] Long-term OEM behavior — deferred to Phase 04 (OD-0024)

Detailed results and evidence: `spike/RESULTS.md` § Step 5 — النتائج النهائية.