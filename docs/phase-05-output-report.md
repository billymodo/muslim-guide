# Phase 05 — Output Report (DRAFT)

## Status
DRAFT — Task 11c + CR-0015 pending.

## Summary
Phase 05-A/B delivered: audit + governance + calculation method UI.

## Phase 05-A — Audit & Cleanup
- Governance rules: git discipline + CI discipline + test/production coupling + layout-coupling.
- GAPs closed: format-time-dup, all-prayers-disabled-hint, cr0013-missing-photo.
- CI fix: free disk space + cache Gradle (CI #84-90 fixed).

## Phase 05-B — Calculation Method UI
- `/settings/calculation` — 3 dropdowns (method, Asr, HLR).
- Country detection: ~30-50 mapping (EG→Egyptian, SA→UmmAlQura, ...).
- City picker hook: implicit → auto-apply + Undo; explicit → silent.
- SettingsRepository: markExplicit + isCalculationMethodExplicit.
- Deep link: `muslimguide://settings/calculation`.
- ARB: 22 keys (ar + en).
- Fajr دقيق (Egyptian: 5:34 بدل MWL 5:41 في الإسكندرية).

## Device Verified (Oppo A95, 2026-10-13)
- المواقيت مضبوطة (Egyptian).
- Country detection → auto-applied.
- Undo → MWL.
- الإشعار يعمل (2:34 كامل عند إغلاق التطبيق + لا مكالمة).
- In-call fallback: ding + prayer text (expected — Android audio focus).

## Tests
- flutter test: 511 passed (test count baseline: 584 testIDs — CI-012 fixed).
- CI: 9/9 green (#96, #97).

## Known Gaps (carried)
| GAP | Severity | Target |
|---|---|---|
| GAP-task6-device-interruption | P2 | Task 11c |
| GAP-widget-test-layout-coupling | P2 | Phase 06 |
| GAP-in-call-adhan-fallback | P3 | Phase 06 (optional) |
| GAP-atomic-commit-gap | P3 | Phase 06 (process) |
| GAP-calc-method-ui | — | CLOSED (05-B) |
| GAP-cr0013-missing-photo | — | CLOSED (05-A) |
| GAP-format-time-dup | — | CLOSED (05-A) |
| GAP-all-prayers-disabled-hint | — | CLOSED (05-A) |
| GAP-system-silence-not-detectable | P3 | Phase 04 (carried) |
| GAP-integration-player-race | P3 | Phase 04 (carried) |

## Deferrals to Phase 05-C+
- CR-0015 Multi-Adhan (3 CC0 options).
- Task 11c real call (audio focus).
- GAPs P2/P3.

## Next Phase
Phase 05-C — Multi-Adhan.
