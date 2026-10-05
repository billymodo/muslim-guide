# Screens



## Screen Template

SCREEN-XXX



Name:

Purpose:

Entry Points:

UI Requirements:

States:

Loading:

Empty:

Error:

Success:

Accessibility:

Localization:

Related Requirements:

Related Flow:

Related Tests:





---



## SCREEN-001 — Splash



- **Name**: Splash

- **Purpose**: تهيئة التطبيق (Hive، l10n، theme).

- **Entry Points**: بدء التطبيق.

- **UI Requirements**: شعار، مؤشر تحميل.

- **States**: Loading, Error.

- **Accessibility**: نص بديل للشعار.

- **Localization**: AR/EN.

- **Related Requirements**: REQ-FOUND-001

- **Related Flow**: FLOW-001



## SCREEN-002 — Language Selection



- **Name**: Language Selection

- **Purpose**: اختيار اللغة عند أول تشغيل.

- **Entry Points**: بعد Splash (أول تشغيل فقط).

- **UI Requirements**: بطاقتان (AR / EN)، زر "متابعة".

- **States**: Normal.

- **Accessibility**: أزرار ≥ 48dp، Semantics واضح.

- **Localization**: يعرض نفسه بلغتين.

- **Related Requirements**: REQ-FOUND-001

- **Related Flow**: FLOW-001



## SCREEN-003 — Welcome / Onboarding Shell



- **Name**: Welcome / Onboarding Shell

- **Purpose**: عرض موجز للميزات قبل الدخول.

- **Entry Points**: بعد اختيار اللغة.

- **UI Requirements**: بطاقات تعريفية بالميزات.

- **States**: Normal.

- **Accessibility**: نص واضح، Semantics لكل بطاقة.

- **Localization**: AR/EN.

- **Related Requirements**: REQ-FOUND-001

- **Related Flow**: FLOW-001



## SCREEN-004 — Settings



- **Name**: Settings

- **Purpose**: ضبط الإعدادات.

- **Entry Points**: الرئيسية، أو من Onboarding.

- **UI Requirements**: قائمة إعدادات.

- **States**: Normal.

- **Accessibility**: أهداف لمس ≥ 48dp.

- **Localization**: AR/EN.

- **Related Requirements**: REQ-L10N-001

- **Related Flow**: FLOW-001



