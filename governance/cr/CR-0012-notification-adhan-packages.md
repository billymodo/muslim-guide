# CR-0012 — Notification & Adhan Packages

**Status:** APPROVED (conditional on publication-date verification) —
2026-10-10
**Date:** 2026-10-10
**Phase:** 04 (Notifications & Adhan)
**Related decisions:** DEC-0008, DEC-0009, DEC-0023
**Related phase document:** `phases/04.md`

## Decision

Decision: APPROVED (conditional on A) — 2026-10-10
Approved By: Abdo (Owner) + Director

Approved exact versions for Phase 04, subject to the recorded condition:

- `flutter_local_notifications: 22.3.1` (exact, BSD-3-Clause)
- `timezone: 0.11.1` (exact, BSD-2-Clause)
- `just_audio: 0.10.6` (exact, MIT)
- `audio_service: 0.18.19` (exact, MIT)

DEC-0008 lift: Phase 04 ONLY. Phase 07 retains original scope.

All versions above are exact pins, with no caret, per Rule 019. This CR does
not itself modify dependency manifests; implementation follows the approved
Phase 04 tasks and standard dependency registration process.

## Reason

DEC-0008 currently approves `audio_service + just_audio` for Phase 07 only.
Phase 04's proposed hybrid design requires a silent local notification and
an internal player capable of background playback at prayer time. This CR
requests a narrowly scoped lift of that restriction for Phase 04 only.

DEC-0009 already selects `flutter_local_notifications + timezone` for
notifications. The Spike tested `flutter_local_notifications 22.3.1`,
`timezone 0.11.1`, `just_audio 0.10.6`, and `audio_service 0.18.19`; it
provides useful integration evidence, but does not itself approve production
use or override DEC-0008.

## Scope

### Proposed
- Permit the four exact versions listed above as production dependencies
  for Phase 04, subject to Director approval and the project's dependency
  and legal registration process.
- Lift DEC-0008's Phase 07-only limitation for `audio_service` and
  `just_audio` in Phase 04 only. Phase 07 retains its existing scope; no
  wider change is implied.
- Require an abstraction around notification and audio plugins, test fakes,
  Android merged-manifest verification, and physical-device validation.
- Require manual declaration of `ScheduledNotificationReceiver` and
  `ScheduledNotificationBootReceiver` for
  `flutter_local_notifications 22.3.1`, per DEC-0023.

### Not proposed
- Adding any dependency as part of this document.
- Selecting an Adhan recording, or changing `legal/assets.yaml`.
- Adding `audioplayers`.
- Expanding the Android-only Phase 04 scope to iOS.
- Changing the Phase 07 production audio architecture.

## Verified

Pub.dev package metadata and package pages were checked on **2026-10-10**.
The versions below were the current latest versions returned by pub.dev at
that check. Publication dates are from pub.dev API metadata. License values
are recorded in the repository's `LICENSES.md` based on its archived package
license evidence; they remain subject to the normal legal review before
dependency approval.

| Package | Proposed exact version | License in `LICENSES.md` | pub.dev publication date | Maintenance / fit |
|---|---:|---|---|---|
| `flutter_local_notifications` | **22.3.1** | BSD-3-Clause | 2026-09-13 06:34:48.785139Z | Current latest at verification; published recently. Supports scheduled local notifications and Android permission APIs. Its documented minimum Flutter version is 3.38.1; project Flutter is pinned at 3.47.5. DEC-0023 requires manual receiver declarations and merged-manifest verification. |
| `timezone` | **0.11.1** | BSD-2-Clause | 2026-06-29 07:44:30.784613Z | Current latest at verification; maintained under dart-lang/labs with a published IANA database package. Used with local scheduling; it does not detect the device's current timezone, which remains the responsibility of the existing timezone-detection path. |
| `just_audio` | **0.10.6** | MIT (+ Apache-2.0 ExoPlayer) | 2026-06-29 13:36:46.318814Z | Current latest at verification; recent release and active repository. Provides asset playback; package documentation recommends pairing with `audio_service` for background audio. Android/native integration must be build-tested. |
| `audio_service` | **0.18.19** | MIT (+ Apache-2.0 ExoPlayer) | 2026-06-29 15:13:43.648839Z | Current latest at verification; recent release and active repository. Designed to wrap an audio player for background playback and media controls. Its extra lifecycle/service behavior is justified only if device testing proves it reliable for this Adhan use case. |

The pub.dev version metadata confirms package names, versions, publication
dates, repositories, descriptions, and SDK constraints; it does not replace
review of archived license texts or the Android/Google Play exact-alarm
policy. The proposed versions meet the documented SDK floor in the metadata
against the project's Flutter 3.47.5 / Dart 3.13.4, subject to dependency
resolution and build validation after approval.

### Individual pub.dev API date verification (2026-10-10)

Each package API was requested individually using
`https://pub.dev/api/packages/<package>` and its exact-version endpoint.
Three packages were indeed published on **2026-06-29**, but their individual
UTC timestamps differ; this is not a copied/shared date error:

| Package | Version | `published` (UTC) |
|---|---:|---|
| `flutter_local_notifications` | 22.3.1 | 2026-09-13T06:34:48.785139Z |
| `timezone` | 0.11.1 | 2026-06-29T07:44:30.784613Z |
| `just_audio` | 0.10.6 | 2026-06-29T13:36:46.318814Z |
| `audio_service` | 0.18.19 | 2026-06-29T15:13:43.648839Z |

All four proposed versions were the latest versions returned by their
individual pub.dev package APIs at verification time.

## Alternatives

| Option | Advantages | Trade-offs | Assessment |
|---|---|---|---|
| `flutter_local_notifications 22.3.1` vs an earlier 22.x release | Version tested by Phase 00B; current latest at verification; receiver behavior and desugaring requirement are documented in project evidence. | Must declare receivers manually; exact-alarm permissions and OEM background limits remain app responsibilities. | Proposed baseline. Recheck pub.dev and package documentation immediately before implementation; if a newer version appears, update this CR before changing the pin. |
| `flutter_local_notifications 22.3.1` vs a newer release | A newer release could contain fixes or policy changes. | No newer release appeared in pub.dev's current package metadata on 2026-10-10; upgrading would invalidate tested receiver assumptions until verified. | No newer release identified at verification. Do not infer compatibility or upgrade without renewed package review and merged-manifest test. |
| `just_audio 0.10.6` vs `audioplayers` (pub.dev latest observed: `6.8.1`) | `audioplayers` is actively published, supports asset playback and multiple simultaneous files, and lists a broad platform set. | No Phase 00B evidence for it; its package description focuses on playback, while the proposal needs a background-service integration. It does not remove the DEC-0008 question or prove background Adhan reliability. | Retain `just_audio`, already exercised in the Spike and explicitly paired with `audio_service` by its package documentation. Do not add `audioplayers` absent a separate evidence-based CR. |
| `audio_service 0.18.19` vs no background service | Omitting a service reduces Android lifecycle/native integration complexity. | A player alone may not reliably start/continue after app closure or expose notification actions for restart; that would conflict with the proposed hybrid behavior. | Keep in proposed set only if CR and device testing validate its need and behavior; otherwise return to Director with evidence before substituting an architecture. |
| `timezone 0.11.1` vs device-local `DateTime` alone | IANA timezone-aware scheduling supports local wall-clock schedules and timezone changes. | Timezone package data must be initialized and kept distinct from detecting the device's current timezone. | Retain per DEC-0009; test DST and timezone changes, and reuse the project's existing timezone detection. |

### Alternatives not adopted
- **`audioplayers`:** not selected; no project Spike evidence and no
  demonstrated advantage for this background-service design.
- **No `audio_service`:** reduces complexity but risks inability to start or
  control Adhan playback from a scheduled alarm when the app is closed.
  Validate this specific use case before final architecture approval.
- **Earlier notification plugin version:** lacks the Phase 00B evidence
  available for 22.3.1 and would not remove the explicit receiver requirement
  without contrary version-specific evidence.

## Special Section — DEC-0008 Lift Justification

### Current rule
DEC-0008 approves `audio_service + just_audio` for Phase 07 only.
CR-0004 authorized those packages inside the temporary `spike/` directory
for evaluation, then required deleting them with the Spike. CR-0004 did not
authorize production use in Phase 04.

### Requested narrow change
Allow the pair in the Phase 04 production app only, because the proposed
Phase 04 behavior is to deliver a silent notification and play the Adhan
through an internal background-capable audio handler. Phase 00B exercised
the audio asset loading/play/stop path, but did **not** verify Audio Focus
during a real call, reliable long-term ColorOS playback, or production
integration from a scheduled notification.

### Conditions
- No DEC-0008 change or production dependency addition until the Director
  approves this CR.
- Keep the scope restricted to Phase 04 Adhan playback; do not use this CR
  to pull Phase 07 recitation or its controls into Phase 04.
- Stop playback on call, competing audio session, or user silence; never
  resume automatically. Test real interruption behavior and manual restart.
- Verify background launch/playback, termination, reboot, and ColorOS
  behavior on Oppo A95. If it fails, report evidence and return for a
  decision; notification-sound fallback is a documented temporary exception,
  not an unrecorded implementation change.
- Keep an injected player/handler boundary so widget tests do not invoke
  MethodChannel or native plugin behavior.

## Implementation Notes and Constraints

- Exact pins only; preserve `pubspec.lock` reproducibility.
- `flutter_local_notifications 22.3.1` requires explicit
  `ScheduledNotificationReceiver` and
  `ScheduledNotificationBootReceiver` entries in the main app
  `AndroidManifest.xml` per DEC-0023. Verify both in the built merged
  manifest, and repeat after any plugin version change.
- Phase 00B reported the need for core library desugaring and
  `desugar_jdk_libs 2.1.4` with `flutter_local_notifications 22.3.1`.
  Recheck the selected release's setup documentation and actual app Gradle
  configuration; do not copy the Spike setting without validation.
- Android 12+ exact-alarm access uses `SCHEDULE_EXACT_ALARM`; direct users
  to the Alarms & reminders special access settings when needed. Do not use
  `USE_EXACT_ALARM` (rejected due to Google Play policy risk for a prayer app).
  Android 13+ `POST_NOTIFICATIONS` is required to show notifications.
- Any license/notice registrations must follow the project's legal workflow.
- Adhan audio remains `[PLACEHOLDER-ADHAN-AUDIO]` until the owner selects
  and reviews a specific recording. The generic CC0 record in
  `legal/assets.yaml` does not identify a specific file.

## Test Plan

- **Static and dependency:** `flutter analyze --fatal-infos`; exact version
  audit in `pubspec.yaml` and `pubspec.lock`; package license registration.
- **Automated:** unit tests for schedule computation, timezone/DST,
  rescheduling and cancellation; widget tests with injected fakes; permission
  and failure tests; audio handler tests for stop/no-resume/restart contract.
- **Android integration:** debug APK build, permission/settings lifecycle,
  scheduled notification handling, receiver registration, reboot recovery,
  and merged-manifest evidence.
- **Physical device:** Oppo A95 / Android 13 / ColorOS 13; ±1-minute timing;
  background at least 30 minutes, reboot and battery-optimization conditions;
  real incoming call and competing audio-session interruptions; explicit
  user silence; manual restart.
- **Failure behavior:** denied notification/exact-alarm access and background
  player failure produce visible diagnostics and no silent success fallback.
- **Test isolation:** widget tests must use fakes/injection and must not call
  MethodChannel.

## Risks

1. Background audio playback may not start from a scheduled event after the
   process is terminated or under ColorOS restrictions.
2. Receiver omissions previously caused accepted schedules not to deliver;
   manifest verification is a release-blocking criterion.
3. Users who deny `SCHEDULE_EXACT_ALARM` access may not receive delivery
   within the ±1-minute target; the app needs a clear diagnostic and degraded
   behavior.
4. OEM battery management can delay delivery; the Oppo result must not be
   generalized to MIUI, OneUI, or EMUI.
5. Audio Focus behavior needs a real call and competing-session test; Spike
   did not settle it.
6. Third-party audio player/service increases native integration surface
   and dependency/license obligations.

## Approval

- Decision: APPROVED (conditional on A) — 2026-10-10
- Approved By: Abdo (Owner) + Director
- Approval Date: 2026-10-10
- Approval Text: Approved for the four exact versions above. DEC-0008 lift
  is limited to Phase 04 only; Phase 07 retains original scope. Approval is
  conditional on the individual pub.dev publication-date verification,
  recorded above.

## Execution

- Added (2026-10-10): `flutter_local_notifications 22.3.1`, `timezone 0.11.1`,
  `just_audio 0.10.6`, `audio_service 0.18.19` — exact pins (Rule 019).
- Gradle: `isCoreLibraryDesugaringEnabled = true`, `multiDexEnabled = true`,
  Java 17, `desugar_jdk_libs 2.1.4`.
- `LICENSES.md` updated.
- `security/02-dependencies.md` updated.
- Native integration verified via `flutter build apk --debug`.
- Commit: `a331b78`.

## References

- `03-decisions.md` — DEC-0008, DEC-0009, DEC-0023.
- `governance/cr/CR-0004-audio-in-spike.md` — Spike-only audio exception.
- `phases/00b-spike.md` and `spike/RESULTS.md` — receivers, reboot,
  battery, desugaring, and deferred audio-focus/OEM evidence.
- `LICENSES.md` — archived exact-version license records for the Spike
  packages.
- Pub.dev package pages and version metadata checked 2026-10-10:
  - https://pub.dev/packages/flutter_local_notifications
  - https://pub.dev/packages/timezone
  - https://pub.dev/packages/just_audio
  - https://pub.dev/packages/audio_service
  - https://pub.dev/packages/audioplayers
