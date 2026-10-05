# Data Architecture

## User Data
Hive CE. أمثلة:
- الإعدادات
- حالة Onboarding
- آخر قراءة
- المفضلة

## Religious Content
- لا يوضع في DB المستخدم.
- يُشحن كـ `assets/` للقراءة فقط.
- له schema في `SCHEMAS.md` وchecksum في `legal/assets.yaml`.

## Index for Search
- يُبنى عند التشغيل الأول أو يُشحن كـasset.
- لا يُكتب في DB المستخدم.

## Network
- لا شبكة إلا Phase 07 (التلاوة).
- وحدة معزولة، CI يمنع استيراد مكتبات الشبكة خارجها.

## Hive IDs
- سجل مركزي لـ`typeId` لا يُعاد استخدام أي رقم.
- `schemaVersion` في كل box.

## Hive & Isolates
- Hive غير آمن عبر isolates.
- نمط الكتابة من الخلفية يُحدد في Phase 00B.