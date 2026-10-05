# Spike 00B — جدول النتائج

> يُملأ أثناء الاختبار. النسخة الدائمة بعد الحذف: `docs/phase-00b/`.

| # | السيناريو | البيئة | الطراز + إصدار النظام | النتيجة | الدليل (لقطة/سجل) |
|---|---|---|---|---|---|
| 1 | إشعار مجدول بعد إغلاق التطبيق | جهاز فيزيائي | | | |
| 2 | إشعار بعد إعادة التشغيل | جهاز فيزيائي | | | |
| 3 | exact alarm على Android 12+ | جهاز فيزيائي | | | |
| 4 | Hive: isolate خلفي → رئيسي | جهاز فيزيائي | | | |
| 5 | صوت خلفي + audio focus + مقاطعات | جهاز فيزيائي | | | |
| 6 | سلوك OEM (Xiaomi/Huawei) | جهاز OEM | | | |

## Build Issues

### 1) core library desugaring (2026-10-06)
- **العطل:** `Execution failed for task ':app:checkDebugAarMetadata'` — `Dependency ':flutter_local_notifications' requires core library desugaring to be enabled for :app.`
- **الحل:** `isCoreLibraryDesugaringEnabled = true` داخل `compileOptions` + `coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")` — الإصدار **2.1.4 حرفيًا** من README الرسمي لـ flutter_local_notifications 22.3.1.
- **الملاحظة:** **سيتكرر في Phase 04** عند إضافة flutter_local_notifications إلى `lib/` (نفس الإعداد سيلزم التطبيق الرئيسي).

