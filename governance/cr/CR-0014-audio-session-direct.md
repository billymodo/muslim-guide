# CR-0014 — audio_session Direct Dependency (Phase 04 Task 6)

**Status:** APPROVED — 2026-10-11
**Date:** 2026-10-11
**Phase:** 04 (Notifications & Adhan — Task 6 Audio Focus)
**Related decisions:** CR-0012, DEC-0008 (Phase 04 lift)
**Related phase document:** `phases/04.md`

## Decision

Decision: APPROVED — 2026-10-11
Approved By: Abdo (Owner) + Director

Approved exact version for Phase 04:

- `audio_session: 0.2.4` (exact, MIT)

Per Rule 019: exact pin, no caret. This CR declares an already-present
transitive dependency (via `just_audio 0.10.6` + `audio_service 0.18.19`)
as a direct dependency; no behavior change by itself.

## Reason

Task 6 needs `AudioSession.instance` + `interruptionEventStream` +
`becomingNoisyEventStream` + `AudioSessionConfiguration.speech()` to
implement the OD-0023 stop/no-resume policy. `just_audio`'s default
`handleInterruptions: true` auto-resumes after interruptions, which
violates the approved policy; Task 6 disables it
(`AudioPlayer(handleInterruptions: false)`) and handles interruptions
manually via `audio_session`.

## Verified

Checked 2026-10-11 via `https://pub.dev/api/packages/audio_session`:

| Package | Version | License | `published` (UTC) | Publisher |
|---|---|---|---|---|
| `audio_session` | **0.2.4** | MIT | 2026-06-29T13:10:31.881382Z | ryanheise.com |

- License: MIT (package page + cached `LICENSE` — "Copyright (c) 2020
  Ryan Heise and the project contributors").
- Publisher: ryanheise.com (same author as `just_audio`/`audio_service`).
- `archive_sha256`: `f9e7711a0e24ca8b40f5d7ac374c3c6e55016f3157912badd18199cdbbca5c4d`
  (matches `pubspec.lock` transitive entry — declaration only).
- SDK floor from metadata: Dart `^3.6.0`, Flutter `>=3.27.0`;
  project uses Flutter 3.47.5 / Dart 3.13.4.
- No new native permissions; plugin already registered
  (`GeneratedPluginRegistrant.java` — `AudioSessionPlugin`).

## Scope

### Proposed
- Declare `audio_session: 0.2.4` (exact) as a direct dependency.
- Register MIT license in `LICENSES.md` + `security/02-dependencies.md`.
- Use in Task 6: `configure(speech())`, interruption/noisy watchers.

### Not proposed
- Any other package addition or version change.
- Behavior change by this CR alone (implementation follows in Task 6).
- iOS scope change (Phase 04 is Android-only per DEC-0015).

## Test Plan

- `flutter analyze --fatal-infos` (import must resolve as direct).
- `flutter pub get --enforce-lockfile` consistency; `pubspec.lock`
  marks `audio_session` as `direct main` with unchanged sha256.
- Task 6 unit/widget/integration tests (see Task 6 plan).

## Risks

1. Transitive→direct promotion is metadata-only; behavior unchanged.
2. Forgetting `handleInterruptions: false` re-enables auto-resume —
   covered by a Task 6 no-resume unit test.

## Approval

- Decision: APPROVED — 2026-10-11
- Approved By: Abdo (Owner) + Director
- Approval Text: Task 6 requires direct `AudioSession` access;
  declaration only, no behavior change.

## Execution

- Added (2026-10-11): `audio_session 0.2.4` — exact pin (Rule 019).
- `LICENSES.md` + `security/02-dependencies.md` updated.
