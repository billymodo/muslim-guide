# CR-0010 — flutter_timezone package

**Status:** APPROVED
**Date:** 2026-10-09
**Phase:** 02 closeout follow-up (تحضير لـ Phase 03 — يُغلق DEC-0029)

**Decision:** إضافة `flutter_timezone 5.1.1` (Apache-2.0) كتبعية مباشرة
بإصدار exact (Rule 019).

**Reason:** تنفيذ **DEC-0029 / OD-0025** وإزالة `TODO(phase-02)` من
`bootstrap_provider.dart` — قراءة المنطقة الزمنية الفعلية للجهاز وضبط
`tz.local`؛ عند الفشل → `Asia/Riyadh` مع تحذير في السجل المحلي (DEC-0025 /
`LocalErrorLog`). أمر تنفيذي من المدير 2026-10-09 (§3) — أول مهمة تحضيرية
لـ Phase 03 قبل أي عمل Qibla.

**Scope:**
- `FlutterTimezone.getLocalTimezone()` → `TimezoneInfo.identifier` (IANA)
  لضبط `tz.local` عبر `tz.setLocalLocation`
- Fallback ثابت `Asia/Riyadh` عند أي فشل + تسجيل `warning` في
  `LocalErrorLog` (يجب ألا يكسر bootstrap أبداً)
- **لا تغيير** لحساب المواقيت: يظل `timezone 0.11.1` + city timezone
  (CR-0008) — هذه الحزمة تغذي `tz.local` فقط
- لا يُستخدم في background isolates

**Verified (pub.dev API + صفحة الحزمة، 2026-10-09):**
- Package/version: `flutter_timezone **5.1.1**` (latest — exact pin)
- License: **Apache-2.0** ⚠️ (المتوقع كان MIT — Apache-2.0 ترخيص permissive
  معتمد OSI؛ الاعتماد كـ dependency لا يغيّر ترخيص المشروع (MIT)؛
  **مُبلَّغ للإدارة كانحراف** في تقرير التنفيذ)
- Published: 5.1.1 = **2026-10-03**؛ 5.1.0 = 2026-05-28؛ 5.0.2 = 2026-03-15
- Dart SDK: `>=3.4.0 <4.0.0` ✅ (المشروع `sdk: ^3.13.4`)
- Flutter SDK: `>=3.22.0` ✅ (المشروع Flutter 3.47.5)
- Dependencies: `equatable`, `flutter`, `flutter_web_plugins`, `meta`
- API (breaking change منذ 5.0.0):
  `static Future<TimezoneInfo> FlutterTimezone.getLocalTimezone([String? locale])`
  — `TimezoneInfo.identifier: String` = المعرّف IANA (مثل
  `America/Los_Angeles`)؛ `localizedName` اختياري (لا نستخدمه)
- Publisher: wolverinebeach.net · Repository: github.com/tjarvstrand/flutter_timezone
- SHA256 للأرشيف (من pub.dev API): `7830bc64bef0b003468fc1f58fc3f3faf54817f8cd6e68fa818b306560410d68`

**Alternatives considered:**
- `flutter_native_timezone` (الأصل) — بلا صيانة؛ هذه الحزمة هي forkه الرسمي ❌
- إصدارات `flutter_timezone < 5.0.0` — API قديم يعيد String فقط، وبدون
  دعم Linux/Windows/Wasm ❌
- قراءة `persist.sys.timezone` عبر MethodChannel خاص — غير موثق عبر
  الإصدارات، تكرار لمنطق الحزمة ❌

**Test plan:** وحدة بحزمة مزيّفة (fake) — مسار النجاح (identifier صحيح →
`tz.local` = الجهاز) + مسار الفشل (استثناء → `Asia/Riyadh` + تحذير في
`LocalErrorLog` ب مجلد مؤقت).

**Approved By:** Director — أمر تنفيذي مباشر 2026-10-09 (§3 في تعليمات
الجلسة)
