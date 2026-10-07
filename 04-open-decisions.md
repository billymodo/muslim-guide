# Open Decisions

## OD-0001 — ترخيص الكود
- **Question**: MIT أم GPL؟
- **Blocking Phase**: قبل Phase 00
- **Status**: DECIDED — MIT License (DEC-0014، 2026-10-05)
- **Note**: يحدد توافق ترخيص المكتبات والمحتوى.

## OD-0002 — drift
- **Question**: هل نستخدم drift إلى جانب Hive؟
- **Blocking Phase**: قبل Phase 12
- **Status**: OPEN
- **Rule**: لا يُدخل drift قبل حسم هذا.

## OD-0003 — تنسيق تخزين القرآن
- **Question**: JSON واحد أم SQLite كـasset؟
- **Blocking Phase**: Phase 06
- **Status**: OPEN
- **Criterion**: cold start < 2.0s على الجهاز المرجعي.

## OD-0004 — تطبيع البحث العربي
- **Question**: قواعد التطبيع (تشكيل، همزات، ألف مقصورة، تاء مربوطة)؟
- **Blocking Phase**: قبل Phase 06
- **Status**: OPEN

## OD-0005 — التقويم الهجري
- **Question**: أم القرى / فلكي / خيار للمستخدم؟
- **Blocking Phase**: قبل Phase 08
- **Status**: OPEN

## OD-0006 — المنصات
- **Question**: Android min SDK؟ iOS ضمن v1؟
- **Blocking Phase**: قبل Phase 01
- **Status**: DECIDED — Android فقط في v1.0 (minSdk 24, compileSdk 36, targetSdk 34)؛ iOS مؤجل إلى v2.0+ → OD-0021 (DEC-0015، 2026-10-05؛ minSdk amended by CR-0003 وcompileSdk amended by CR-0007 on 2026-10-06)

## OD-0007 — مصدر صوت التلاوة
- **Question**: من القارئ؟ ما شروط ترخيصه؟
- **Blocking Phase**: قبل Phase 07
- **Status**: OPEN
- **Rule**: لا استخدام قبل ترخيص مكتوب.

## OD-0008 — ترحيل بيانات المستخدم
- **Question**: آلية schemaVersion وmigration؟
- **Blocking Phase**: Phase 01
- **Status**: DECIDED — simple versioned migrations (DEC-0024، 2026-10-06)

## OD-0009 — النشر على المتاجر
- **Question**: توقيع، Data Safety، سياسة خصوصية؟
- **Blocking Phase**: قبل Phase 09
- **Status**: OPEN

## OD-0010 — سجل الأخطاء المحلي
- **Question**: صيغة وتصدير؟
- **Blocking Phase**: Phase 01
- **Status**: DECIDED — JSON Lines in Documents with bounded rotation and manual share export (DEC-0025، 2026-10-06)

## OD-0011 — طريقة حساب المواقيت
- **Question**: الطريقة الافتراضية وخيارات المستخدم؟
- **Blocking Phase**: قبل Phase 02
- **Status**: DECIDED — MWL default, seven calculation methods, Standard/Hanafi Asr, and MiddleOfNight default (DEC-0028، 2026-10-07)

## OD-0012 — الأرقام
- **Question**: عربية هندية أم لاتينية؟
- **Blocking Phase**: Phase 01
- **Status**: DECIDED — Latin numerals in UI; Arabic-Indic numerals in Quranic text (DEC-0026، 2026-10-06)

## OD-0013 — تشفير Hive
- **Question**: اختياري؟ أين يُخزن المفتاح؟
- **Blocking Phase**: Phase 01
- **Status**: DECIDED — no encryption in v1; revisit through a new OD if data sensitivity changes (DEC-0027، 2026-10-06)

## OD-0014 — cache eviction للصوت
- **Question**: سياسة الحدود والتحميل؟
- **Blocking Phase**: قبل Phase 07
- **Status**: OPEN

## OD-0015 — ترجمات المحتوى
- **Question**: مصدر معتمد، تمييز النص عن الترجمة؟
- **Blocking Phase**: قبل Phase 19
- **Status**: OPEN

## OD-0016 — عدد اللغات بعد v1
- **Question**: ما الإضافات؟
- **Blocking Phase**: بعد v1
- **Status**: OPEN

## OD-0017 — home widgets
- **Question**: نعم أم لا؟ التكلفة مقابل التوقع؟
- **Blocking Phase**: قبل Phase 09
- **Status**: OPEN

## OD-0018 — إصدار Riverpod
- **Question**: 2.x أم 3.x؟
- **Blocking Phase**: قبل Phase 00
- **Status**: DECIDED — flutter_riverpod 2.6.1 (آخر إصدار 2.x ثابت، تحقق pub.dev 2026-10-05) → DEC-0016
- **Rule**: لا تثبيت قبل التحقق من pub.dev + استقرار + migration path.

## OD-0019 — الجهاز المرجعي
- **Question**: ما الطراز والمواصفات؟
- **Blocking Phase**: Phase 00
- **Status**: DECIDED (DEC-0017)
- **Decision**: Pixel 6a أساسي + Redmi Note 12 ثانوي
- **Date**: 2026-10-06
- **Proposal**: Pixel 6a أو Redmi Note 12.

## OD-0020 — Amiri Quran License
- **Question**: هل يسمح بالاستخدام التجاري؟ (التطبيق مجاني، لكن التوزيع تجاري بمعنى النشر على المتاجر)
- **Blocking Phase**: قبل Phase 06
- **Status**: OPEN

## OD-0021 — iOS بعد v1.0
- **Question**: متى يُضمّن iOS وما دعمه (الإصدار الأدنى، القناة)؟
- **Blocking Phase**: قبل v2.0
- **Status**: OPEN
- **Origin**: DEC-0015 (أُجّل iOS إلى v2.0+، 2026-10-05)

## OD-0022 — جهاز اختبار Phase 00B

**Question:** ما الجهاز المتاح لتنفيذ Step 5؟

**Why It Matters:** 60% من مخاطر الإشعارات لا تكتشف على المحاكي.

**Options:**
- A: Pixel 6a (المفضل — بلا تحسينات بطارية)
- B: أي Android 7+ (كافٍ للاختبار الأساسي)
- C: تأجيل إلى Phase 04

**Blocking Phase:** Phase 04 (الأذان)

**Status:** CLOSED — Step 5 completed on CPH2365 / Android 13 on 2026-10-06.

**Deadline:** قبل بدء Phase 04

## OD-0023 — Audio focus verification

**Question:** Does playback stop or resume correctly when an incoming phone call interrupts it?

**Blocking Phase:** 04

**Status:** OPEN

**Context:** Audio focus could not be tested without a real incoming call.

**Action:** Verify interruption and resume behavior during Phase 04 using a real call.

## OD-0024 — OEM long-term behavior

**Question:** Do notifications remain reliable under long-term ColorOS and other OEM background restrictions?

**Blocking Phase:** 04

**Status:** OPEN

**Context:** Step 5 verified foreground, background-with-exemption, and reboot delivery on one CPH2365 device, but did not run for 30+ minutes or test additional OEM devices.

**Action:** Run a 30+ minute test on multiple OEM devices during Phase 04 and document the required battery, background-running, and auto-launch guidance.

## OD-0025 — Automatic timezone detection

**Status:** DECIDED — use `flutter_timezone`, with `Asia/Riyadh` fallback and a local warning on failure (DEC-0029، 2026-10-07)
**Blocking Phase:** 02

**Question:** How should the user's timezone be detected automatically?

**Options:**
- A: `flutter_timezone` (reads the system timezone)
- B: `DateTime.now().timeZoneName` (may be inaccurate)
- C: User-configurable setting

**Current (Phase 01):** `Asia/Riyadh` is temporary and must be replaced before
production.

**Decision:** `flutter_timezone` (DEC-0029). CR-0010, package/license verification, and exact version pin are required before adding the dependency.