# Project Charter — دليل المسلم

## Project
دليل المسلم

## Product Type
Flutter mobile application (Android first، iOS قرار مفتوح OD-0006).

## Languages
- **العربية (ar)** — اللغة الافتراضية
- **الإنجليزية (en)**
- **الاختيار عند أول تشغيل** إلزامي (شاشة Onboarding).
- النص القرآني والأذكار: **RTL ثابت** بغض النظر عن لغة الواجهة.

## Business Model
التطبيق **مجاني بالكامل**:
- بلا إعلانات
- بلا تبرعات
- بلا اشتراكات
- بلا مشتريات داخل التطبيق
- بلا تحقيق دخل من طرف ثالث
- التطوير/النشر: تمويل ذاتي

## Core Principles
- correctness (الصحة قبل السرعة)
- reliability
- privacy (لا تتبع، لا telemetry)
- maintainability
- content integrity (المحتوى الديني أولوية مطلقة)
- licensing compliance
- accessibility
- offline-first

## Technical Constraints
- Flutter + Dart (إصدار مثبت عبر FVM)
- GitHub + GitHub Actions
- Hive CE لبيانات المستخدم فقط
- لا اتصال شبكي (إلا Phase 07 التلاوة، باستثناء مسجل)
- لا telemetry، لا analytics
- لا اعتماد على خدمات طرف ثالث

## Content Governance
- **مراجعو المحتوى الشرعي**: فريق شيوخ، كل واحد مسؤول عن جزء محدد.
- المراجعة عبر ملف **HTML** (للعرض) + **JSON** (للبيانات).
- الاعتماد يُوثّق: الاسم + التاريخ + رقم الإصدار + checksum.
- لا يدخل المحتوى الإنتاج بلا اعتماد مكتوب.

## Phase Rule
- المراحل مقسمة (00 → 27C).
- **Phase B لا تبدأ قبل العبارة الصريحة: «اعتماد المرحلة A»**.
- لا يمكن للـAI تفسير أي عبارة أخرى كاعتماد.

## Change Rule
لا تغيير صامت في: متطلب، قرار، معمارية، حزمة، مصدر محتوى، ترخيص، قاعدة CI، قاعدة أمن.
كل تغيير جوهري يُوثَّق عبر `Change Request`.