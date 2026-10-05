# Onboarding

## Purpose
تهيئة المستخدم عند أول تشغيل، مع اختيار اللغة.

## Screens
1. **SCREEN-001 — Splash**
2. **SCREEN-002 — Language Selection**
3. **SCREEN-003 — Welcome / Onboarding Shell**
4. **SCREEN-004 — Settings** (اختياري)

## Flow
Splash → Language Selection → Welcome → Main.

## Rules
- اختيار اللغة إلزامي.
- لا يمكن تجاوز الشاشة.
- يمكن العودة لتغيير اللغة من الإعدادات.
- Onboarding shell يعرض شرحًا موجزًا للميزات.

## Persistence
- `Hive box: settings`, `key: language`, `value: "ar" | "en"`.
- `key: onboarding_completed` = `true`.