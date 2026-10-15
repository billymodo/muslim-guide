import 'package:audio_session/audio_session.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_guide/features/adhan/application/audio_focus_watcher.dart';

import '../fake_adhan_audio_session.dart';

/// Builds a watcher bound to controllable fakes.
({AudioFocusWatcher watcher, FakeAdhanAudioSession session}) makeWatcher({
  required bool Function() isPlaying,
  required Future<void> Function() stopForInterruption,
  FakeAdhanAudioSession? session,
}) {
  final fake = session ?? FakeAdhanAudioSession();
  final watcher = AudioFocusWatcher(
    stopForInterruption: stopForInterruption,
    isPlaying: isPlaying,
    sessionProvider: () async => fake,
  );
  return (watcher: watcher, session: fake);
}

Future<void> pumpEventQueue() => Future<void>.delayed(Duration.zero);

void main() {
  test('start configures the session', () async {
    final env = makeWatcher(
      isPlaying: () => false,
      stopForInterruption: () async {},
    );
    addTearDown(() async {
      await env.watcher.stop();
      await env.session.close();
    });

    await env.watcher.start();

    expect(env.session.configureCalls, 1);
  });

  test('begin-pause while playing stops and flags interrupted', () async {
    var stops = 0;
    final env = makeWatcher(
      isPlaying: () => true,
      stopForInterruption: () async {
        stops++;
      },
    );
    addTearDown(() async {
      await env.watcher.stop();
      await env.session.close();
    });
    await env.watcher.start();

    env.session.beginInterruption();
    await pumpEventQueue();

    expect(stops, 1);
    expect(env.watcher.wasInterrupted, isTrue);
    expect(env.watcher.lastInterruptionReason, 'interruption-begin:pause');
  });

  test('begin-duck while playing is ignored', () async {
    var stops = 0;
    final env = makeWatcher(
      isPlaying: () => true,
      stopForInterruption: () async {
        stops++;
      },
    );
    addTearDown(() async {
      await env.watcher.stop();
      await env.session.close();
    });
    await env.watcher.start();

    env.session.beginInterruption(AudioInterruptionType.duck);
    await pumpEventQueue();

    expect(stops, 0);
    expect(env.watcher.wasInterrupted, isFalse);
    expect(env.watcher.lastInterruptionReason, 'duck-ignored');
  });

  test('begin-unknown while playing stops (permanent loss)', () async {
    var stops = 0;
    final env = makeWatcher(
      isPlaying: () => true,
      stopForInterruption: () async {
        stops++;
      },
    );
    addTearDown(() async {
      await env.watcher.stop();
      await env.session.close();
    });
    await env.watcher.start();

    env.session.beginInterruption(AudioInterruptionType.unknown);
    await pumpEventQueue();

    expect(stops, 1);
    expect(env.watcher.wasInterrupted, isTrue);
  });

  test('begin while idle does not stop', () async {
    var stops = 0;
    final env = makeWatcher(
      isPlaying: () => false,
      stopForInterruption: () async {
        stops++;
      },
    );
    addTearDown(() async {
      await env.watcher.stop();
      await env.session.close();
    });
    await env.watcher.start();

    env.session.beginInterruption();
    await pumpEventQueue();

    expect(stops, 0);
    expect(env.watcher.wasInterrupted, isFalse);
    expect(env.watcher.lastInterruptionReason, isNull);
  });

  test('end event never resumes (no play call)', () async {
    var stops = 0;
    final env = makeWatcher(
      isPlaying: () => true,
      stopForInterruption: () async {
        stops++;
      },
    );
    addTearDown(() async {
      await env.watcher.stop();
      await env.session.close();
    });
    await env.watcher.start();

    // begin → stop; then end must NOT trigger another stop (and the watcher
    // has no play path at all — no auto-resume by construction).
    env.session.beginInterruption();
    await pumpEventQueue();
    env.session.endInterruption();
    await pumpEventQueue();

    expect(stops, 1);
    expect(env.watcher.wasInterrupted, isTrue);
  });

  test('becoming-noisy while playing stops', () async {
    var stops = 0;
    final env = makeWatcher(
      isPlaying: () => true,
      stopForInterruption: () async {
        stops++;
      },
    );
    addTearDown(() async {
      await env.watcher.stop();
      await env.session.close();
    });
    await env.watcher.start();

    env.session.emitNoisy();
    await pumpEventQueue();

    expect(stops, 1);
    expect(env.watcher.wasInterrupted, isTrue);
    expect(env.watcher.lastInterruptionReason, 'becoming-noisy');
  });

  test('becoming-noisy while idle does not stop', () async {
    var stops = 0;
    final env = makeWatcher(
      isPlaying: () => false,
      stopForInterruption: () async {
        stops++;
      },
    );
    addTearDown(() async {
      await env.watcher.stop();
      await env.session.close();
    });
    await env.watcher.start();

    env.session.emitNoisy();
    await pumpEventQueue();

    expect(stops, 0);
    expect(env.watcher.wasInterrupted, isFalse);
  });

  test('clearInterrupted resets the flag (manual restart/stop)', () async {
    var stops = 0;
    final env = makeWatcher(
      isPlaying: () => true,
      stopForInterruption: () async {
        stops++;
      },
    );
    addTearDown(() async {
      await env.watcher.stop();
      await env.session.close();
    });
    await env.watcher.start();

    env.session.beginInterruption();
    await pumpEventQueue();
    expect(env.watcher.wasInterrupted, isTrue);

    env.watcher.clearInterrupted();
    expect(env.watcher.wasInterrupted, isFalse);
    expect(env.watcher.lastInterruptionReason, isNull);
    expect(stops, 1);
  });
}
