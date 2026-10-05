# Testing Strategy

| المستوى | ماذا | أمثلة |
|---|---|---|
| Unit | منطق نقي | مواقيت، قبلة، هجري، تطبيع بحث |
| Widget | شاشات | RTL/LTR، Dark، خط كبير |
| Integration | سيناريوهات | إعادة التشغيل، جدولة الإشعارات |
| Failure | فشل | Hive، asset مفقود، لا موقع، لا مساحة |
| Permission | صلاحيات | رفض الموقع/الإشعارات |
| Regression | بحث | 100 استعلام ثابت |
| Migration | بيانات | ترقية من آخر schema إنتاجي |
| Content | محتوى | schema + checksum + عدد آيات |
| Device | جهاز حقيقي | إشعارات بعد reboot، صوت، أداء |

## Reference Device
- في OD-0019.

## Coverage
- منطق حسابي ≥ 80%.