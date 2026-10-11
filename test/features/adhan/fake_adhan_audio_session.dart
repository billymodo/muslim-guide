import 'dart:async';

import 'package:audio_session/audio_session.dart';
import 'package:muslim_guide/features/adhan/data/audio_session_config.dart';

/// Controllable fake of [AdhanAudioSession] for Task 6 tests.
///
/// Emits interruption/noisy events on demand; no MethodChannel involved.
class FakeAdhanAudioSession implements AdhanAudioSession {
  final StreamController<AudioInterruptionEvent> _interruptions =
      StreamController<AudioInterruptionEvent>.broadcast();
  final StreamController<void> _noisy = StreamController<void>.broadcast();

  int configureCalls = 0;
  bool isClosed = false;

  @override
  Future<void> configure() async {
    configureCalls++;
  }

  @override
  Stream<AudioInterruptionEvent> get interruptionEvents =>
      _interruptions.stream;

  @override
  Stream<void> get becomingNoisyEvents => _noisy.stream;

  /// Emits an interruption `begin` event of [type].
  void beginInterruption([
    AudioInterruptionType type = AudioInterruptionType.pause,
  ]) {
    _interruptions.add(AudioInterruptionEvent(true, type));
  }

  /// Emits an interruption `end` event of [type].
  void endInterruption([
    AudioInterruptionType type = AudioInterruptionType.pause,
  ]) {
    _interruptions.add(AudioInterruptionEvent(false, type));
  }

  /// Emits a becoming-noisy event (headset/Bluetooth disconnect).
  void emitNoisy() {
    _noisy.add(null);
  }

  /// Closes the underlying controllers.
  Future<void> close() async {
    isClosed = true;
    await _interruptions.close();
    await _noisy.close();
  }
}
