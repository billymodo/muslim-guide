# Requirements — دليل المسلم

## ID Format
`REQ-[DOMAIN]-[NUMBER]` — مثال: `REQ-QURAN-001`

## Template

### REQ-XXX-000
- **Title**:
- **Description**:
- **Priority**: MUST / SHOULD / MAY
- **Source**:
- **Acceptance Criteria**:
- **Dependencies**:
- **Constraints**:
- **Related Architecture**:
- **Related Tests**:
- **Status**: PROPOSED / APPROVED / IMPLEMENTED / VERIFIED / DEPRECATED

---

## المتطلبات الأساسية (v1.0)

### REQ-FOUND-001 — اختيار اللغة عند أول تشغيل
- **Description**: يُعرض على المستخدم عند أول تشغيل شاشة لاختيار لغة الواجهة (ar/en)، ويُحفظ الاختيار.
- **Priority**: MUST
- **Acceptance Criteria**:
  - تُعرض الشاشة قبل أي شاشة أخرى.
  - الاختيار يُحفظ في Hive ويُستعاد بعد إعادة التشغيل.
  - يمكن تغيير اللغة لاحقًا من الإعدادات.
- **Related Architecture**: `architecture/07-localization.md`
- **Status**: PROPOSED

### REQ-PRAYER-001 — حساب مواقيت الصلاة Offline
- **Description**: حساب مواقيت الصلوات الخمس محليًا بلا شبكة.
- **Priority**: MUST
- **Acceptance Criteria**:
  - ≥ 5 مدن مرجعية، مطابقة لمرجع رسمي بهامش موثق.
  - يعمل في وضع الطيران.
  - يدعم حالات حدّية (خطوط عرض عالية، مناطق زمنية مختلفة، DST).
- **Related Architecture**: Domain نقي في `features/prayer/domain`
- **Status**: PROPOSED

### REQ-QIBLA-001 — اتجاه القبلة
- **Description**: عرض اتجاه القبلة بدقة مقبولة مع بديل عند غياب المغناطيسية.
- **Priority**: MUST
- **Acceptance Criteria**:
  - معايرة واضحة للمستخدم.
  - بديل نصي/رقمي عند غياب الحساس.
  - اختبار حساب نقي بقيم مرجعية.
- **Status**: PROPOSED

### REQ-ADHAN-001 — إشعارات الأذان
- **Description**: إشعار محلي لكل صلاة مع صوت أذان معتمد.
- **Priority**: MUST
- **Acceptance Criteria**:
  - إشعار يصل بعد إغلاق التطبيق.
  - إشعار يصل بعد إعادة تشغيل الجهاز.
  - إعادة الجدولة عند تغيير المنطقة الزمنية أو الموقع.
  - شاشة تشخيص للصلاحيات.
- **Status**: PROPOSED

### REQ-AZKAR-001 — الأذكار
- **Description**: عرض أذكار الصباح/المساء/النوم وغيرها من pack معتمد.
- **Priority**: MUST
- **Status**: PROPOSED

### REQ-QURAN-001 — قراءة القرآن
- **Description**: عرض 114 سورة من نص معتمد، مع تحميل كسول.
- **Priority**: MUST
- **Acceptance Criteria**:
  - نص مطابق للمصدر (checksum).
  - خط Amiri Quran بلا قص.
  - cold start < 2.0s على الجهاز المرجعي.
- **Status**: PROPOSED

### REQ-RECITE-001 — التلاوة الصوتية
- **Description**: تشغيل تلاوة معتمدة مع تحكم كامل (تقديم، إيقاف، سرعة).
- **Priority**: MUST
- **Acceptance Criteria**:
  - يعمل مع قارئ واحد بترخيص مكتوب.
  - مقاطعات المكالمات، audio focus، إشعار المشغل.
  - سياسة retry وtimeout مكتوبة.
- **Note**: الشبكة الوحيدة المسموحة — وحدة معزولة.
- **Status**: PROPOSED

### REQ-HIJRI-001 — التقويم الهجري
- **Description**: عرض التاريخ الهجري مع إمكانية تعديل يدوي بيوم.
- **Priority**: MUST
- **Status**: PROPOSED

### REQ-SEARCH-001 — البحث العربي
- **Description**: بحث موحد (قرآن، أذكار، أدعية) مع تطبيع عربي.
- **Priority**: SHOULD (v1.5)
- **Acceptance Criteria**:
  - 100 استعلام انحداري.
  - p95 < 150ms على الجهاز المرجعي.
- **Status**: PROPOSED

### REQ-L10N-001 — دعم AR/EN كامل
- **Description**: كل نصوص الواجهة في ARB، لا نصوص مضمّنة.
- **Priority**: MUST
- **Acceptance Criteria**:
  - اختبار ARB يفشل عند مفتاح ناقص.
  - RTL/LTR سليمان بلا overflow.
- **Status**: PROPOSED

### REQ-A11Y-001 — الوصولية
- **Description**: التطبيق قابل للاستخدام مع TalkBack وتكبير الخط حتى 200%.
- **Priority**: MUST
- **Acceptance Criteria**:
  - أهداف لمس ≥ 48dp.
  - تباين ألوان AA على الأقل.
  - Semantics لكل عنصر تفاعلي.
- **Status**: PROPOSED

### REQ-PRIVACY-001 — الخصوصية
- **Description**: لا telemetry، لا analytics، لا إرسال بيانات.
- **Priority**: MUST
- **Acceptance Criteria**:
  - لا حزمة tracking في `pubspec.yaml`.
  - CI يتحقق من عدم وجود `INTERNET` في Manifest قبل Phase 07.
- **Status**: PROPOSED