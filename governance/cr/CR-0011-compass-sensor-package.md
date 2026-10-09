# CR-0011 — Compass sensor package (Qibla)

**Status:** APPROVED (E-11) — 2026-10-09
**Date:** 2026-10-09
**Phase:** 03 (القبلة)

**Decision:** **APPROVED: `flutter_compass 0.8.1`** (MIT, exact pin) —
E-9 · المبرر: MIT يطابق ترخيص المشروع + heading جاهز 0–360 (سطح خطأ
أصغر) + الـ abstraction يحمي من توقف صيانة الحزمة.

**Reason:** REQ-QIBLA-001 (MUST) يتطلب قراءة اتجاه الجهاز لحساب القبلة
offline. لا حزمة مضافة بعد؛ UI_VISION وصفة 5 يتوقع `compassProvider`
(Stream). لا CR سابق للحساسات.

**Scope (بعد الاعتماد):**
- تبعية مباشرة واحدة فقط، بـ exact pin (Rule 019) + sha256 في lock.
- استخدام محلي خلف abstraction قابل للاختبار (فِيَك كامل — دروس
  Phase 02: لا MethodChannel مباشر في التطبيق).
- Android فقط (DEC-0015) — ملاحظة iOS في الحزمتين لا تخصنا.
- لا صلاحيات جديدة متوقعة على Android (magnetometer لا يحتاج صلاحية)؛
  **ملاحظة flutter_compass README** (Manifest permissions) ستُفحص عند
  التنفيذ — إن ثبت حاجة موقع فعلاً → إعادة اعتماد CR.
- تحديث `LICENSES.md` + `security/02-dependencies.md` (سياسة legal).

**Verified (pub.dev، 2026-10-09 — الصفحة الرسمية للحزمتين):**

| البند | flutter_compass **0.8.1** | sensors_plus **7.1.1** |
|---|---|---|
| License | **MIT** (مطابق لترخيص المشروع) | **BSD-3-Clause** (permissive — متوافق) |
| نُشر | قبل **~23 شهراً** (≈نوفمبر 2024) | قبل **7 أيام** |
| الصيانة | ⚠️ متوقف عملياً | ✅ نشط (fluttercommunity.dev) |
| API | **heading جاهز 0–360** (0 = شمال) عبر stream | **خام**: `magnetometerEvents` — حساب heading مطلوب (معايرة + tilt-compensation) |
| لا حساس | يعيد `null` heading (Android) — يتطلب معالجة | `onError` على stream — يتطلب معالجة |
| Platforms | Android + iOS | Android + iOS + macOS + web |
| Stats | 191 likes / 89.8k downloads | 1.0k likes / 664k downloads |
| SDK | flutter فقط | Flutter ≥3.19 ✅ (المشروع 3.47.5) |
| publisher | hemanthraj.in | fluttercommunity.dev |

**Alternatives (بما فيها المرفوض):**
- **flutter_compass** — أبسط بمسار مباشر للنتيجة («دقة مقبولة» يوفّرها
  النظام نفسه مع معايرته)، MIT، مطابق لشكل `compassProvider` المتوقع؛
  مقابل خطر توافق مستقبلي (صيانة متوقفة) ومنصات أقل.
- **sensors_plus** — صيانة نشطة ومجتمع أكبر؛ مقابل تعقيد حساب heading
  من خام (خطر دقة REQ + معايرة + معادلات tilt) وسعة عمل أكبر في domain.
- **MethodChannel خاص بـ SensorManager** — تكرار وصيانة ذاتية ❌.
- **الحزمتان معاً** — تعقيد بلا مكسب ❌.

**Decision guidance (توصية غير ملزمة — للمدير):**
المسار الأقصر نحو REQ «دقة مقبولة» هو **flutter_compass** (heading جاهزة
+ Android يعيد null عند غياب الحساس = مسار «لا حساس» الطبيعي). إن كان
القلق صيانة/توافق مستقبلي فهو **sensors_plus** + خوارزمية heading في
domain النقي (بديل هجين — عمل أكبر لكن بلا اعتمادية على حزمة متوقفة).

**Test plan:**
- **Unit**: حساب bearing (domain — بلا الحزمة) بقيم مرجعية موثقة.
- **Widget**: فِيَك stream heading (نجاح / خطأ / لا حساس) عبر الـ
  abstraction — بلا حزمة حقيقية في الاختبارات.
- **Device**: Oppo A95 حقيقي — قراءات فعلية + مسار معايرة + مقارنة
  اتجاه معروف بصرية + توثيق قراءات.
- **CI**: الـ 9 jobs الحالية (build-debug يتحقق من التكامل native).
- **Failure**: انقطاع/خطأ stream → حالة Error + لا crash.

**Approved By:** Abdo (Owner) + Director — 2026-10-09 (E-10)

## Execution
- Added: `flutter_compass: 0.8.1` (exact pin) — 2026-10-09
- LICENSES.md updated ✅
- security/02-dependencies.md updated ✅
- Native integration verified via `flutter build apk --debug` ✅
- commit: this commit (Task 4)
