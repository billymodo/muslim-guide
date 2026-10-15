import 'dart:async';

import 'package:audio_session/audio_session.dart';

/// Injectable audio-session operations for Adhan playback (Task 6).
///
/// Abstracts [AudioSession] (a concrete singleton with a MethodChannel
/// backend) so unit and widget tests can use fakes without touching
/// platform channels.
abstract interface class AdhanAudioSession {
  /// Applies the Adhan session configuration.
  Future<void> configure();

  /// Emits focus-interruption events (call, competing session, duck/loss).
  Stream<AudioInterruptionEvent> get interruptionEvents;

  /// Emits an event on headset/Bluetooth disconnect.
  Stream<void> get becomingNoisyEvents;
}

/// Production [AdhanAudioSession] backed by the shared [AudioSession].
class RealAdhanAudioSession implements AdhanAudioSession {
  /// Creates the adapter around [session].
  const new(this.session);

  /// The shared platform audio session.
  final AudioSession session;

  @override
  Future<void> configure() => configureAdhanAudioSession(session);

  @override
  Stream<AudioInterruptionEvent> get interruptionEvents =>
      session.interruptionEventStream;

  @override
  Stream<void> get becomingNoisyEvents => session.becomingNoisyEventStream;
}

/// Configures the shared audio session for Adhan playback (Task 6).
///
/// Uses the `speech()` recipe: the Adhan is continuous human voice, closer
/// to speech than music. On Android, transient duck events remain `duck`
/// rather than being converted to `pause`, allowing the focus watcher to
/// ignore duck events while still stopping on pauses. Notification-panel
/// behavior remains unverified on ColorOS (BUG-8).
///
/// Verbatim recipe (`audio_session 0.2.4`):
/// `playback` category, `spokenAudio` mode, `usage: media`,
/// `contentType: speech`, `focus gain`; Android override:
/// `willPauseWhenDucked: false`.
///
/// Android-only scope (Phase 04 per DEC-0015); iOS fields are documented
/// but not exercised here.
Future<void> configureAdhanAudioSession(AudioSession session) {
  final configuration = const AudioSessionConfiguration.speech().copyWith(
    androidWillPauseWhenDucked: false,
  );
  return session.configure(configuration);
}
