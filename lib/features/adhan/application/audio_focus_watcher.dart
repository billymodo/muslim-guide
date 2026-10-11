import 'dart:async';

import 'package:audio_session/audio_session.dart';
import 'package:muslim_guide/features/adhan/data/audio_session_config.dart';

/// Watches audio-focus interruptions and noisy-device events for Task 6.
///
/// Policy (OD-0023, M-3):
/// - On every interruption `begin` (call, competing session, duck, or
///   permanent loss): invokes the stop callback if the player was playing,
///   recording the reason. Duck arrives as pause thanks to
///   `willPauseWhenDucked: true`.
/// - On interruption `end`: deliberately nothing — no play call, which
///   prevents automatic resume.
/// - On `becomingNoisy` (headset/Bluetooth disconnect): same as begin.
///
/// The watcher reads the latest player state via [isPlaying] so the
/// interruption decision is synchronous. It exposes [wasInterrupted] so the
/// handler can emit the interrupted state; manual restart or manual stop
/// clears it. State is in-memory only: if the process dies there is no
/// playback to restart.
class AudioFocusWatcher {
  /// Creates a watcher.
  ///
  /// [stopForInterruption] stops playback and emits the interrupted state
  /// (it must NOT clear [wasInterrupted]). [isPlaying] reports whether the
  /// player is currently playing. [sessionProvider] supplies the injectable
  /// session (defaults to the real shared session) — tests inject fakes.
  new({
    required this.stopForInterruption,
    required this.isPlaying,
    Future<AdhanAudioSession> Function()? sessionProvider,
  }) : _sessionProvider =
           sessionProvider ??
           (() async => RealAdhanAudioSession(await AudioSession.instance));

  /// Stops playback for an interruption (provided by the handler).
  final Future<void> Function() stopForInterruption;

  /// Whether the player is currently playing (provided by the handler).
  final bool Function() isPlaying;

  final Future<AdhanAudioSession> Function() _sessionProvider;

  StreamSubscription<AudioInterruptionEvent>? _interruptionSubscription;
  StreamSubscription<void>? _noisySubscription;

  /// Whether playback was stopped by an interruption/noisy event and the
  /// user has not restarted or stopped manually since.
  bool wasInterrupted = false;

  /// Reason of the last interruption stop (for logging/diagnostics).
  String? lastInterruptionReason;

  /// Configures the session and subscribes to interruption streams.
  Future<void> start() async {
    final session = await _sessionProvider();
    await session.configure();
    _interruptionSubscription ??= session.interruptionEvents.listen(
      _onInterruption,
    );
    _noisySubscription ??= session.becomingNoisyEvents.listen(
      _onBecomingNoisy,
    );
  }

  /// Cancels subscriptions.
  Future<void> stop() async {
    await _interruptionSubscription?.cancel();
    await _noisySubscription?.cancel();
    _interruptionSubscription = null;
    _noisySubscription = null;
  }

  /// Clears the interrupted flag (after manual restart or manual stop).
  void clearInterrupted() {
    wasInterrupted = false;
    lastInterruptionReason = null;
  }

  Future<void> _onInterruption(AudioInterruptionEvent event) async {
    if (!event.begin) {
      // M-3: on end — deliberately nothing. No play call → no auto-resume.
      return;
    }
    // M-3: on every begin (pause/duck/unknown — call, competing session,
    // or permanent loss): stop if playing.
    lastInterruptionReason = 'interruption-begin:${event.type.name}';
    await _stopIfPlaying();
  }

  Future<void> _onBecomingNoisy(void _) async {
    // M-3: headset/Bluetooth disconnect → stop (not pause) if playing.
    lastInterruptionReason = 'becoming-noisy';
    await _stopIfPlaying();
  }

  Future<void> _stopIfPlaying() async {
    // Only interruptions during actual playback count; idle and other
    // states are left untouched.
    if (!isPlaying()) {
      lastInterruptionReason = null;
      return;
    }
    await stopForInterruption();
    wasInterrupted = true;
  }
}
