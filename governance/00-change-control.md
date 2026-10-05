# Change Control

## No Silent Changes

يتطلب تغييرًا موثقًا:

- requirements
- decisions
- architecture
- dependencies
- content sources
- licenses
- CI rules
- security rules
- release policy

## Process

1. Identify change.
2. Identify affected documents.
3. Identify affected requirements.
4. Identify affected architecture.
5. Identify affected tests.
6. Identify affected legal assets.
7. Record decision.
8. Update canonical documents.
9. Run CI.
10. Review.
11. Merge.

## Forbidden

- تغيير الكود أولًا والتوثيق لاحقًا.
- تجاوز CI.
- تعديل مرحلة سابقة بصمت.

## CR Template

```markdown
# CR-NNN — [عنوان]

- المرحلة المتأثرة:
- الوثيقة/الملف:
- قبل:
- بعد:
- السبب:
- أثره على مراحل أخرى / بيانات مخزنة:
- اختبارات إضافية مطلوبة:
- القرار: [موافق / مرفوض] — التاريخ:
```

## Related

- `governance/01-ai-development-rules.md`
- `governance/02-definition-of-done.md`
- `adr/README.md`
