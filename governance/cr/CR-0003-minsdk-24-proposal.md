# CR-0003 — minSdk الفعلي (24) مقابل DEC-0015 (23) — بانتظار القرار

- المرحلة المتأثرة: Phase 00 (DEC-0015)
- الوثيقة/الملف: `03-decisions.md` (DEC-0015)، `android/app/build.gradle.kts`
- قبل: DEC-0015 ينص على `minSdk 23`.
- بعد (المقترح): `minSdk 24` — مع بقاء `compileSdk 35` و`targetSdk 34` و`applicationId com.muslimguide.app` كما هي.
- السبب (أدلة تقنية، 2026-10-05/06):
  1. Flutter 3.47.5 يفرض `flutter.minSdkVersion = 24` (`FlutterExtension.kt` L26) و`minSdkVersionInt = 24` (`gradle_utils.dart`).
  2. أداة Flutter تُهاجر أي قيمة حرفية `minSdk = 16..23` إلى `flutter.minSdkVersion` تلقائيًا عند كل `flutter build` (`min_sdk_version_migration.dart` — regex `(?<=^\s*)minSdk(Version)?\s*=\s*(1[6789]|2[0123])...`).
  3. APK الناتج فعليًا: `minSdkVersion:'24'` (aapt2 dump badging).
  4. `DependencyVersionChecker.kt`: خطأ إذا < 23، تحذير إذا < 24.
- أثره على مراحل أخرى / بيانات مخزنة: إسقاط دعم أجهزة Android 6 (API 23)؛ لا أثر على بيانات مخزنة.
- اختبارات إضافية مطلوبة: لا يوجد.
- القرار: **بانتظار القرار البشري** — (موافقة/رفض) — التاريخ: —
- المرتبط: DEC-0015، Output Report (الانحرافات)
