# CR-0015 — Multi-Adhan Sound Selection (Phase 05-C)

**Status:** DEFERRED — 2026-10-13
**Date:** 2026-10-13
**Phase:** 05 (Calculation & Settings — Multi-Adhan)
**Related decisions:** CR-0012 (notification/adhan packages); Rule 020 (owner content approval — REFUSE recorded 2026-10-13)
**Related registers:** `06-defect-register.md` → `GAP-multi-adhan-deferred`; `legal/assets.yaml` → `adhan-audio-cc0`
**Related phase document:** `NEXT_SESSION.md`

## Decision

Decision: DEFERRED — 2026-10-13
Decided By: Abdo (Owner) + Director

Multi-Adhan (user-selectable prayer adhan sound) is deferred indefinitely
pending a verified CC0/CC-BY source. **DEFERRED, not WITHDRAWN** — the
requirement stays open and re-opens as **CR-0016** once a source is
verified. `Beautiful_adhan.ogg` (CC0, 2:34, Adam-synagda —
`legal/assets.yaml` `adhan-audio-cc0`, APPROVED) remains the sole approved
adhan source, device-verified on channel `prayer_adhan_v2`.

## Reason

Stage 0 license verification produced one candidate that passed the paper
check and failed the owner listen:

- **Mecca 2013** (`File:Adhan, Great Mosque of Mecca - Jan 21, 2013.webm`,
  Seyfula Islam, CC BY 3.0 — Commons license review 2018-07-19): audio
  extracted (WebM → OGG Vorbis, full 3:17, SHA-256 recorded) and listened
  by the owner on 2026-10-13 — **REFUSED**: YouTube compression artifacts,
  ambient mosque noise, long intro. Not acceptable for religious content
  (Rule 020). The extracted file and its `legal/assets.yaml` /
  `LICENSES.md` entries were reverted; no residue ships in the repo.
- **AI enhancement** of that recording: **REJECTED** — lost quality cannot
  be restored; enhancement adds distortion/artifacts and is unsuitable for
  religious content.
- **archive.org** candidates: no documented license — unusable.
- No other high-quality adhan with a verifiable CC0/CC-BY license was
  found (Wikimedia Commons `Category:Adhan`, Commons media search,
  Freesound spot-check).

## Scope

### Planned (now on hold — nothing implemented)
- `AdhanSound` enum + `adhan_sound` settings key + provider.
- Selection UI (Radio + preview) in `/settings/notifications`.
- Per-sound notification channels + rescheduling; Gradle raw-resource copy.
- Preview player (isolated `just_audio`).

### Not proposed by this CR
- Any code, asset, channel, or UI change (Stage 1–5 never started).
- Any dependency addition.
- Any change to `prayer_calculator.dart` or Task 11c.

## Resumption

- Open **CR-0016** when a source is verified.
- Accepted paths to a source (owner-selected):
  1. Local mosque recording with explicit written permission.
  2. Licensed source from SBA (Saudi TV) or another institution.
  3. High-quality CC0/CC-BY recording on Wikimedia Commons or Freesound
     (license page snapshot + sha256 evidence required before any merge).
- Every candidate must pass: paper license check → extraction → owner
     listen (Rule 020) → only then integration.

## Approval

- Decision: DEFERRED — 2026-10-13
- Approved By: Abdo (Owner) + Director
- Approval Text: Multi-Adhan deferred indefinitely pending verified
  license; Beautiful_adhan.ogg stays the sole source; re-open as CR-0016.

## Audit Trail

- Stage 0 (2026-10-13): source downloaded and verified against Commons
  metadata (9,359,941 bytes; SHA-1 matched), audio extracted, temporary
  registry entries written — all reverted after owner REFUSE.
- GAP registered: `GAP-multi-adhan-deferred` (P3, OPEN (deferred)),
  commit `fc60dc9`.

