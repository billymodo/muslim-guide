# NEXT_SESSION — Phase 06 Quran

> Updated: 2026-10-16
> Canonical phase mapping: `phases/README.md`
> Current status: Phase 05 Azkar skeleton completed; Phase 06 Quran active.

## Current state

- `assets/content/quran/` and `lib/features/quran/` contain `.gitkeep` placeholders only.
- No Quran text dataset, feature implementation, or Quran tests are present.
- The Phase 05 Azkar content pack remains deferred beyond v1.0. The received content is not approved for production.
- Do not treat any source license or rights status as verified without recording its evidence.

## Phase 06 tasks

1. **Verify the source and license**
   - Review the exact Tanzil source/export and its current terms.
   - Record the source URL, version, required attribution, and permitted use/modification in the legal registry before downloading content for production.
   - Stop if the terms or permitted transformations are unclear.

2. **Obtain and validate Quran text**
   - After the rights gate is satisfied, obtain the selected Arabic text without modifying the source text.
   - Record provenance and a SHA-256 checksum.
   - Validate the source's surah/ayah structure, completeness, and text integrity before integrating it.

3. **Plan the data integration**
   - Inspect the existing Quran feature and loader expectations; currently they are placeholders.
   - Define the data format and attribution display consistent with the verified source terms.
   - Keep the dataset outside production assets until licensing and validation are complete.

4. **Implement and verify**
   - Only after the source and data are approved, implement the smallest required Quran reading flow and focused tests.
   - Run the relevant analysis, tests, and build; verify the experience on a device before marking Phase 06 complete.

## Constraints

- Do not claim a license or source approval without evidence.
- Do not modify source Quran text unless the verified terms explicitly allow it.
- Do not mark Phase 06 complete while the dataset, feature, and validation remain outstanding.
- Keep Phase 07 as Recitation and Phase 08 as Calendar, per `phases/README.md`.

## Other deferred work

- Multi-Adhan (CR-0015) remains deferred pending a verified source license.
- Azkar content rebuilding is tracked separately in `docs/azkar-rebuild-plan.md`.
