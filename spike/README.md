# Spike — Phase 00B (الإشعارات والصوت الخلفي)

> **تطبيق مؤقت** — يُحذف قبل اعتماد Phase 00B (`legal/policy.yaml` → `network_exception_spike`).
> الموقع: `spike/` (معفى من CI-015/CI-016 وفق `allowed_paths: ["spike/"]`).

## الحزم (exact — تحقق pub.dev 2026-10-06)

| الحزمة | الإصدار | الترخيص | دليل الترخيص |
|---|---|---|---|
| flutter_local_notifications | 22.3.1 | BSD-3-Clause | LICENSE داخل أرشيف pub.dev (نص BSD + بنود 3) |
| timezone | 0.11.1 | BSD-2-Clause | LICENSE — نص BSD **بشرطين فقط** (اطبع كاملًا 2026-10-06) |
| hive_ce | 2.20.1 | BSD-3-Clause (+ Apache-2.0 لجزء مدمج commit `4eb0dbc…`) | LICENSE — "Copyright 2025 Aaron DeLory" |
| audio_service | 0.18.19 | MIT (+ Apache-2.0 لـExoPlayer المدمج) | LICENSE — "MIT License / Ryan Heise" (CR-0004) |
| just_audio | 0.10.6 | MIT (+ Apache-2.0 لـExoPlayer المدمج) | LICENSE — "MIT License / Ryan Heise" (CR-0004) |

- `flutter` / `flutter_test`: BSD-3-Clause (Flutter SDK — `LICENSE` محلي).
- `flutter_lints`: MIT (dev فقط).
- **hive_ce**: إصدار exact بلا `^` (موافقة 2026-10-06) — الاختبار: كتابة من isolate خلفي → قراءة من رئيسي.

## الصلاحيات (معتمدة — spike/ فقط، 2026-10-06)

POST_NOTIFICATIONS, SCHEDULE_EXACT_ALARM, USE_EXACT_ALARM, RECEIVE_BOOT_COMPLETED,
WAKE_LOCK, FOREGROUND_SERVICE, FOREGROUND_SERVICE_MEDIA_PLAYBACK, VIBRATE

> ممنوع إضافتها إلى `lib/` أو Manifest الرئيسي للتطبيق الأساسي.

## سيناريوهات الاختبار

1. إشعار مجدول يصل بعد إغلاق التطبيق (جهاز فيزيائي).
2. إشعار بعد إعادة تشغيل الجهاز (جهاز حقيقي فقط).
3. exact alarms على Android 12+.
4. Hive: كتابة من isolate خلفي → قراءة من isolate رئيسي.
5. صوت في الخلفية + audio focus + مقاطعة (جهاز حقيقي).

## الاختبار (Testing)

- الاختبار الفعلي: جهاز Android فيزيائي (Pixel 6a).
- المحاكي: غير مستخدم (system image غير متوفر، والأداء لا يمثل الواقع).

## التشغيل

```text
cd spike
flutter pub get
flutter run
```

النتائج: `RESULTS.md` — الأدلة: `evidence/` — النسخة الدائمة: `docs/phase-00b/`.
