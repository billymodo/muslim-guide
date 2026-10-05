# Localization

## Status
APPROVED (DEC-0006)

## Languages
- `ar` — العربية (الافتراضية)
- `en` — English

## Onboarding Rule
- شاشة إلزامية عند أول تشغيل لاختيار اللغة.
- الاختيار يُحفظ في Hive.
- يمكن تغييره لاحقًا من الإعدادات.
- المرجع: `product/06-onboarding.md`

## RTL/LTR Rules
- العربية: RTL.
- الإنجليزية: LTR.
- **النص القرآني والأذكار: RTL ثابت** بغض النظر عن لغة الواجهة.
- اختبار bidi لكل شاشة تعرض عربيًا + إنجليزيًا.

## ARB Rules
- كل نص واجهة في ARB. لا نصوص مضمّنة في الكود.
- ملفات: `l10n/app_ar.arb`, `l10n/app_en.arb`.
- اختبار آلي يفشل عند مفتاح ناقص في أي لغة.
- CI-013 يفرض اكتمال المفاتيح.

## Numbering
- قرار OD-0012.

## Fonts
- الواجهة العربية: خط نظام أو خط مخصص.
- النص القرآني: `amiri-quran-font` (يُحمَّل من `assets/fonts/`).

## Folder
- `lib/app/localization/`
- `l10n/`

## Related
- DEC-0006
- REQ-L10N-001
- REQ-FOUND-001
- `product/06-onboarding.md`
- `phases/01.md`