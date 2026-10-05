# Phase 00B — Spike: الإشعارات والصوت الخلفي

## Status
PLANNED (يبدأ بعد اعتماد Phase 00)

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
- اختبار audio focus (مكالمة + تشغيل خلفي)

## Deviations from Specification
(يُملأ عند التنفيذ)

## Human Review Points
- هل النتائج كافية لـ Phase 04؟