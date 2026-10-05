# CR-0003 — minSdk Adjustment

**المرحلة:** Phase 00
**الوثيقة:** 03-decisions.md (DEC-0015)
**قبل:** minSdk 23
**بعد:** minSdk 24
**السبب:** Flutter 3.47.5 يفرض 24 كحد أدنى فعلي (FlutterExtension.kt).
**أثره:** لا يوجد — APK كان يستخدم 24 فعلاً.
**القرار:** موافق — 2026-10-06

## الأدلة (2026-10-06)

- `FlutterExtension.kt` L26: `val minSdkVersion: Int = 24`
- `min_sdk_version_migration.dart`: regex يُهاجر القيم `16..23` → `flutter.minSdkVersion` عند كل `flutter build`
- `aapt2 dump badging app-debug.apk` → `minSdkVersion:'24'` (قبل أي تعديل)

## الأثر على الوثائق

- `03-decisions.md` → DEC-0015: `minSdk 24` + Note
- `android/app/build.gradle.kts` → `minSdk = 24`
- ملف سابق: أُلغي `CR-0003-minsdk-24-proposal.md` (استُبدل بهذا المعتمد)
