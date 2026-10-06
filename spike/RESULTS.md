# Spike 00B — جدول النتائج

> تم التوثيق فعليًا على جهاز Android فيزيائي في جلسة 2026-10-06.

- الطراز: `CPH2365`
- Android: `13`
- API level: `33`
- الجهاز: متصل ومصرّح (`device`)

| # | السيناريو | البيئة | الطراز + إصدار النظام | النتيجة | الدليل (لقطة/سجل) |
|---|---|---|---|---|---|
| 1 | إشعار مجدول في الـForeground | جهاز فيزيائي | CPH2365 / Android 13 / API 33 | ✅ نجح | ظهر `Spike 00B` في Android بعد جدولة 30 ثانية مع الـreceiver الصحيح. |
| 2 | إشعار بعد إغلاق التطبيق/الخلفية | جهاز فيزيائي | CPH2365 / Android 13 / API 33 | ✅ نجح مع Don't optimize | بعد تفعيل استثناء تحسين البطارية، ظهر الإشعار عند إرسال التطبيق للخلفية. |
| 3 | إشعار بعد إعادة التشغيل | جهاز فيزيائي | CPH2365 / Android 13 / API 33 | ✅ نجح | جُدول إشعار بعد 3 دقائق، أُعيد تشغيل الجهاز فورًا، لم يُفتح التطبيق، ثم ظهر `Spike 00B` في الإشعارات بعد الإقلاع. |
| 4 | Exact alarm على Android 12+ | جهاز فيزيائي | CPH2365 / Android 13 / API 33 | ✅ الحالة: مُمكنة / مرخصة | `dumpsys package com.muslimguide.app.muslim_guide_spike` يثبت: `SCHEDULE_EXACT_ALARM: granted=true`, `USE_EXACT_ALARM: granted=true`. لم تظهر رسالة طلب صلاحية أثناء الاختبار. |
| 5 | Audio Focus | جهاز فيزيائي | CPH2365 / Android 13 / API 33 | ⏭️ غير قابل للتنفيذ من هذه البيئة | لا توجد مكالمة واردة حقيقية من رقم آخر لإجراء اختبار المقاطعة الفعلي. |
| 6 | Hive: isolate خلفي → رئيسي | جهاز فيزيائي | CPH2365 / Android 13 / API 33 | ✅ نجح | LogViewer أكد `isolate→main OK` باستخدام IsolateNameServer + SendPort وACK. |
| 7 | سلوك OEM (OnePlus/OPPO) | جهاز OEM | CPH2365 / Android 13 / API 33 | ⏭️ مؤجل إلى Phase 04 | اختبار طويل 30+ دقيقة وعلى أجهزة OEM إضافية لم يُنفذ. |

> ملخص الإغلاق: 6 من 9 تحققّات ناجحة عند احتساب تشغيل الصوت منفصلًا عن Audio Focus،
> مع ثلاثة تحفظات مؤجلة: Audio Focus بمكالمة حقيقية، مراقبة OEM طويلة المدى،
> وتأكيد سمعي بشري للصوت (LogViewer أكد اكتمال التشغيل دون استثناء، لكن لا يمكن
> التحقق من سماع الصوت عبر ADB).

## ملاحظات واقعية

- تم تشغيل التطبيق على الجهاز بنجاح باستخدام Flutter.
- تم تسجيل واجهة التطبيق في [spike/evidence/ui.xml](./evidence/ui.xml) و[spike/evidence/ui_hive.xml](./evidence/ui_hive.xml).
- في الاختبار الأولي، لم يظهر إشعار Spike بسبب غياب receivers في merged manifest؛ تم حل ذلك لاحقًا بإضافتها يدويًا بعد الموافقة.
- اختبار Hive الأولي الذي فتح نفس Hive box من عزلتين فشل؛ النمط البديل بالجسر نجح على الجهاز.

### ColorOS/Oppo behavior

- أظهر LogViewer نجاح قبول جدولة الإشعار، لكن لم يُرصد وصوله في الاختبارات السابقة.
- التشخيص المرجح: Doze mode وقيود ColorOS قد تؤجل الإشعار؛ لم يُحسم ذلك باختبار foreground جديد بعد آخر تحديث.
- إرشاد المستخدم المقترح لـ Phase 04: تعطيل تحسين البطارية للتطبيق، والسماح بتشغيله في الخلفية والتشغيل التلقائي.
- القرار لـ Phase 04: تضمين إرشاد المستخدم كخطوة لازمة، مع التحقق على جهاز Oppo فعلي.

### Audio asset diagnosis (2026-10-06)

- `pubspec.yaml` يضمّن `assets/beep.wav`.
- الملف `spike/assets/beep.wav` موجود (132344 bytes)، والـAPK يحتوي `assets/flutter_assets/assets/beep.wav` بنفس الحجم.
- كان `audio_service_handler.dart` يطلب `setAsset('beep.wav')`؛ صُحح المفتاح إلى `assets/beep.wav`.
- أُعيد الاختبار على الجهاز وسجّل LogViewer نجاح تشغيل الصوت لمدة 10 ثوانٍ.

### Approved fixes — code validation (2026-10-06)

- Audio asset lookup now uses `assets/beep.wav`, matching `pubspec.yaml`.
- Hive no longer opens a box from the worker isolate. It sends a write request
  through `IsolateNameServer`/`SendPort`; the main isolate writes to Hive and
  sends an ACK. The request has a five-second timeout, and bridge disposal
  removes the port mapping.
- `flutter analyze --fatal-infos`: passed.
- `flutter test`: all tests passed, including the new Hive bridge write/ACK test.
- `flutter build apk --debug`: passed.
- Device retest was pending at this point; results are recorded in the connected-device retest sections below.

### Connected-device retest (2026-10-06 14:30–14:34)

- Device reconnected: CPH2365, Android 13 / API 33.
- Latest debug APK installed successfully.
- Audio: LogViewer reported `صوت خلفي | نجاح | beep.wav ×10s` after the button was pressed. This confirms the asset load/play/stop path completed without an exception; acoustic audibility was not independently measurable through ADB.
- Hive: LogViewer reported `Hive isolate | نجاح | isolate→main OK: ...`; the main-isolate bridge write and read-back succeeded on device.
- Foreground notification: LogViewer reported successful exact scheduling (`SCHEDULE-OK`); after more than 30 seconds, no notification record for the Spike package appeared in the notification service dump or notification shade. The installed package had `POST_NOTIFICATIONS`, `SCHEDULE_EXACT_ALARM`, and `USE_EXACT_ALARM` granted, and channel `spike_channel_main` existed with importance 5.
- At this initial retest, the pre-fix merged manifest did not contain `ScheduledNotificationReceiver` or `ScheduledNotificationBootReceiver`; the manifest was corrected later after approval. Evidence of the pre-fix state: [spike/evidence/merged_manifest_debug.xml](./evidence/merged_manifest_debug.xml).
- The cached `flutter_local_notifications` 22.3.1 README lists both scheduled-notification receiver declarations as required under `<application>`; the package's own Android manifest contributes permissions only. This contradicted the earlier assumption that manifest merging adds these components automatically.
- At this initial retest, the Spike package was not listed in `dumpsys deviceidle whitelist`; the exemption was enabled for the later background retest below.
- The app UI has only a 30-second notification button; the specifically requested 15-second interval was not tested.
- Receiver omission was the confirmed cause found for the initial missed notification. The receiver fix is recorded below.

Device evidence:

- [spike/evidence/step5_hive.xml](./evidence/step5_hive.xml)
- [spike/evidence/step5_audio.xml](./evidence/step5_audio.xml)
- [spike/evidence/step5_notification_after30.xml](./evidence/step5_notification_after30.xml)

### Receiver fix and final connected-device retest (2026-10-06 14:37–14:42)

- Following approval, added the plugin-documented `ScheduledNotificationReceiver`
  and `ScheduledNotificationBootReceiver` declarations to the Spike manifest.
- The rebuilt merged manifest now includes both receivers.
- Final merged-manifest evidence: [spike/evidence/merged_manifest_with_receivers.xml](./evidence/merged_manifest_with_receivers.xml).
- `flutter analyze --fatal-infos`, `flutter test`, `flutter build apk --debug`,
  and device install all passed.
- Foreground notification: ✅ delivered and visible in Android notification data
  after a 30-second schedule.
- Audio: ✅ LogViewer reports successful 10-second playback after loading
  `assets/beep.wav`; independent human confirmation of audibility is still needed.
- Hive isolate: ✅ on-device LogViewer reports
  `isolate→main OK: 2026-10-06T14:30:42.136450`.
- Battery condition: added the app to Android's user device-idle whitelist
  (`Don't optimize` equivalent). A fresh notification was scheduled at
  `14:41:07` for `14:41:37`, the app was sent to the background, and `Spike 00B`
  appeared in the notification service and shade. The exemption remains active.
- 15-second interval was not tested because the current Spike UI only exposes
  a 30-second schedule button.

Additional evidence:

- [spike/evidence/step5_after_receiver_wait.xml](./evidence/step5_after_receiver_wait.xml)
- [spike/evidence/battery_scheduled.xml](./evidence/battery_scheduled.xml)

## Evidence files

- [spike/evidence/ui.xml](./evidence/ui.xml)
- [spike/evidence/ui_hive.xml](./evidence/ui_hive.xml)
- [spike/evidence/merged_manifest_with_receivers.xml](./evidence/merged_manifest_with_receivers.xml)
- [spike/evidence/reboot_test_summary.txt](./evidence/reboot_test_summary.txt)

## Build Issues

### 1) core library desugaring (2026-10-06)
- **العطل:** `Execution failed for task ':app:checkDebugAarMetadata'` — `Dependency ':flutter_local_notifications' requires core library desugaring to be enabled for :app.`
- **الحل:** `isCoreLibraryDesugaringEnabled = true` داخل `compileOptions` + `coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")` — الإصدار **2.1.4 حرفيًا** من README الرسمي لـ flutter_local_notifications 22.3.1.
- **الملاحظة:** **سيتكرر في Phase 04** عند إضافة flutter_local_notifications إلى `lib/` (نفس الإعداد سيلزم التطبيق الرئيسي).

## Step 5 — النتائج النهائية (2026-10-06)

الجهاز: CPH2365 / Android 13 / API 33.

| # | الاختبار | النتيجة | ملاحظات |
|---|---|---|---|
| 1 | Foreground notification | ✅ | وصل بعد جدولة 30 ثانية عقب إضافة receiver الجدولة. |
| 2 | Background notification | ✅ | وصل في الخلفية مع استثناء Don't optimize مفعلًا. |
| 3 | Reboot persistence | ✅ | إشعار 3 دقائق بقي بعد إعادة تشغيل الجهاز، وظهر دون فتح التطبيق. |
| 4 | Exact alarm Android 13+ | ✅ | `SCHEDULE_EXACT_ALARM` و`USE_EXACT_ALARM` granted. |
| 5 | Audio focus during call | ⏭️ | مؤجل إلى Phase 04؛ لم تتوفر مكالمة واردة حقيقية للاختبار. |
| 6 | Hive isolate | ✅ | `IsolateNameServer` + `SendPort` + ACK؛ نجاح على الجهاز. |
| 7 | OEM ColorOS long-term | ⏭️ | مؤجل إلى Phase 04؛ لم يُنفذ اختبار 30+ دقيقة أو أجهزة أخرى. |

### Découvertes clés

1. يلزم التصريح صراحةً بـ`ScheduledNotificationReceiver` و
   `ScheduledNotificationBootReceiver` في Manifest مع نسخة الحزمة المستخدمة؛
   لم يظهرا في merged manifest قبل إضافتهما يدويًا، وبعد الإضافة وصلت الإشعارات
   واستعادها اختبار reboot.
2. اختبار الخلفية على هذا الجهاز نجح بعد تفعيل استثناء تحسين البطارية. يلزم
   إرشاد المستخدم إلى إعدادات التشغيل التلقائي والخلفية على ColorOS في Phase 04.
3. جسر `IsolateNameServer` + `SendPort` أبقى Hive في الـmain isolate ونجح
   بالاختبار الآلي وعلى الجهاز.

### Deferred to Phase 04

- Audio focus أثناء مكالمة واردة حقيقية (OD-0023).
- سلوك OEM طويل المدى (30+ دقيقة وأجهزة إضافية) (OD-0024).
- تأكيد سمعي بشري لتشغيل الصوت؛ LogViewer أكد اكتمال التشغيل دون استثناء، لكن لا يمكن التحقق من الصوت عن بعد.
- مشاكل قد تظهر على أجهزة/إصدارات Android أخرى.

### Reboot test evidence

- تمت الجدولة بعد 3 دقائق، ثم أعيد تشغيل الجهاز فورًا.
- لم يُفتح التطبيق بعد إعادة التشغيل.
- بدأ Android تشغيل `ScheduledNotificationBootReceiver` الخاص بالتطبيق بعد
  الإقلاع، ثم ظهر إشعار `Spike 00B` في notification shade و`dumpsys notification`.
- الدليل المنقح: [reboot_test_summary.txt](./evidence/reboot_test_summary.txt).
