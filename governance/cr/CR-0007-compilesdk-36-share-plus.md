# CR-0007 — compileSdk 36 for share_plus

**Status:** APPROVED
**Date:** 2026-10-06

**المرحلة:** Phase 01
**الوثائق المتأثرة:** `03-decisions.md` (DEC-0015), `04-open-decisions.md`, `android/app/build.gradle.kts`

**قبل:** `compileSdk 35`.

**بعد:** `compileSdk 36`، مع الإبقاء على `minSdk 24` و`targetSdk 34`.

**السبب الأصلي:** يتطلب `share_plus 13.3.1` البناء باستخدام Android SDK 36 أو أحدث.

**التحقق قبل push (2026-10-06):**
- **الإصدار الحالي:** `share_plus 13.3.1` هو أحدث إصدار مستقر على pub.dev، نُشر في 2026-10-01: https://pub.dev/packages/share_plus/versions/13.3.1
- **بديل أحدث متوافق مع compileSdk 35:** لم يُعثر على بديل مناسب. `13.2.0` (نُشر 2026-06-26) فشل في AAR metadata ويتطلب SDK 36؛ `11.1.0` (نُشر 2025-08-11) فشل بناء التطبيق مع AGP 9.1 لأن `GeneratedPluginRegistrant` يشير إلى `SharePlusPlugin` غير موجود في ذلك الإصدار.
- **SDK محليًا:** Android SDK Platforms `android-35` و`android-36` مثبتة تحت `C:\AndroidSDK\platforms`.
- **نتيجة build:** APK debug بُني بنجاح مع `share_plus 13.3.1` و`compileSdk 36` (`flutter build apk --debug`).

**القرار:** موافق — 2026-10-06. لا تغيير على `minSdk 24` أو `targetSdk 34`.
