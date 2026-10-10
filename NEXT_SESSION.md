# NEXT_SESSION — اقرأني أولاً

## الحالة العاجلة (2026-10-10 ~23:00 EEST)

### P1 — BUG-7 (Adhan sound) — اختبار الجهاز معلّق
- تحويل OGG محفوظ محلياً في commit مستقل؛ `prayer_adhan_v2` مهيأة.
- اختبار الصوت على الجهاز لم يُنفّذ بعد؛ BUG-7 ما زال OPEN.
- آخر فحص ADB: `POST_NOTIFICATIONS` ممنوح للمستخدم الأساسي (`granted=true`)؛ ظهر أيضاً إدخال `granted=false` لمستخدم آخر. تحقّق من المستخدم الأساسي قبل الاختبار.

### اختبار الجهاز
- الوقت المخطط سابقاً: 01:38:36 EEST؛ إن فات، اختبر عند الصلاة القادمة.
- الإجراء: تأكد من المدينة والجدولة، انتظر الإشعار، واستمع إلى الأزيزات الثلاث؛ بعدها افحص logcat وdumpsys.

### Task 6 — Audio Focus
- موقوف حتى اكتمال P1.

### T-A — Task 4 Timing
- موقوف؛ القياس السابق كان +76 ثانية. Whitelist جاهز.
- يُستأنف بعد P1.

> لا push قبل موافقة صريحة. لا تبدأ Task 6 أو T-A قبل إغلاق P1.

> آخر تحديث: 2026-10-10
> الحالة: Phase 03 ✅ COMPLETED → Phase 04 — ACTIVE

## المرحلة الحالية

- Phase 03: ✅ COMPLETED (2026-10-10) — output report:
  [docs/phase-03-output-report.md](docs/phase-03-output-report.md)
- Phase 04: ACTIVE — P1 BUG-7 بانتظار اختبار صوت الإشعار على الجهاز.

## المتبقي القريب

- إكمال اختبار P1 BUG-7 وتحديث `06-defect-register.md` حسب النتيجة.
- بعد P1 فقط: Task 6 — Audio Focus، ثم T-A — Task 4 Timing.

## Phase 03 closeout

- Device evidence commit: `e9cbe6c`.
- Phase closeout commits follow this entry.
- Oppo A95 (CPH2365, Android 13) — OD-0029.
- تم مسح بيانات التطبيق أثناء اختبار no-location؛ لا توجد مدينة محفوظة حالياً.

## تنبيهات

- لا push دون موافقة صريحة.
- لا تعتبر OGG مُثبتاً على الجهاز قبل سماع الإشعار.
