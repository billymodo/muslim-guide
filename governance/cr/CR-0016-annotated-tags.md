# CR-0016 — Allow annotated tags for approvals

**Status:** APPROVED
**Date:** 2026-10-16

**Decision:** تعديل `approvals.yaml` ليقبل:
- GPG/SSH-signed tag (كما هو)
- أو annotated tag + `approved_commit` (بديل)

**Reason:**
- Solo developer لا يملك GPG على الجهاز
- Annotated tag = موثّق (tagger + date)
- التحقق يتم عبر `approved_commit` (SHA في `approvals.yaml`)
- CI يتحقق من الـSHA + مرور الـchecks
- لا فرق أمني حقيقي في هذا السياق

**Consequences:**
- تعديل `rules` في `approvals.yaml`
- لا تغيير في سياسة Phase-lock

**Approved By:** Abdo (Owner)