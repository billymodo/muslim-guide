# Project Folder Structure



## Status

APPROVED STRUCTURE / subject to approved ADR changes



## App Structure

lib/

├── main.dart

├── app/ (router, theme, localization, bootstrap)

├── core/ (utils, errors, logging, constants)

├── shared/ (widgets مشتركة، design tokens)

└── features/

├── onboarding/

├── settings/

├── prayer/

├── qibla/

├── adhan/

├── azkar/

├── quran/

├── recitation/

├── hijri/

└── ...





## Assets Structure

assets/

├── content/

│ ├── quran/

│ ├── azkar/

│ ├── dua/

│ └── ...

├── audio/

├── images/

└── fonts/





## Tests Structure

test/

├── unit/

├── widget/

└── integration/







## Other Folders

tool/ (سكربتات مساعدة)

legal/ (نسخة محلية من legal للمرجعية)

docs/ (وثائق إضافية)



## Rule

لا يُغيَّر الهيكل جذريًا إلا عبر ADR.



## Related

- `adr/ADR-0002-state-management.md`

- `architecture/02-flutter-architecture.md`

