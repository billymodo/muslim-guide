# Adhan Player State Machine (Phase 04 Task 6)

OD-0023 policy: playback **stops** on call / audio-focus loss / user
silence, with **no automatic resume**. Manual restart from the in-app
controls is the only path back to `playing`.

```text
idle → loading → playing → (interruption) → interrupted
interrupted → (tap restart) → playing
playing → (natural end) → completed
playing → (user stop) → idle
```

## States (`lib/features/adhan/domain/adhan_state.dart`)

| State | Meaning | Restart offered? |
|---|---|---|
| `idle` | No audio loaded or playing | No (Play instead) |
| `loading` | Source loading/buffering | No |
| `playing` | Audio currently playing | No (Stop instead) |
| `paused` | Loaded but paused (legacy; interruptions use `interrupted`) | No |
| `completed` | Source finished naturally | No (Play replays from zero) |
| `error` | Loading/playback failed | No |
| `interrupted` | Stopped by interruption/noisy event — **no auto-resume** | **Yes** |

## Interruption handling (`audio_focus_watcher.dart`)

- Every interruption `begin` (pause/duck/unknown — call, competing
  session, permanent loss) while `playing` → `stopForInterruption()` →
  `interrupted`. Duck arrives as pause thanks to
  `AudioSessionConfiguration.speech()` + `willPauseWhenDucked: true` (M-1).
- Interruption `end` → deliberately nothing (M-3). No `play()` call exists
  on this path, so auto-resume is impossible by construction.
- `becomingNoisy` (headset/Bluetooth disconnect) while `playing` →
  `stopForInterruption()` → `interrupted` (stop, not pause).
- Interruptions while not `playing` are ignored (no flag, no state change).
- Manual `play()` / `stop()` clears the flag.

## Wiring

- `AudioPlayer(handleInterruptions: false)` (M-2) — `just_audio`'s default
  would pause-on-begin and resume-on-end, violating OD-0023. `audio_service`
  0.18.19 has no interruption auto-resume path of its own (verified:
  only `setActive(false)` in deprecated `onStop` + manual
  `androidResumeOnClick` for notification taps).
- `AudioServiceAdhanHandler.stopForInterruption()` stops the player, emits
  `interrupted`, and keeps the watcher's flag; trailing `just_audio`
  stop-transition events are suppressed while interrupted.
- Restart button (`AdhanPlayerControls`, M-4): visible **only** when the
  state is `interrupted`; tapping it calls `play()` (replays from zero if
  the source had completed).

## Known limit

System-level silence (silent mode / DND on `usage: media` audio) generates
no interruption event and is not detectable via `audio_session`
(`GAP-system-silence-not-detectable`). No custom MethodChannel is used.
