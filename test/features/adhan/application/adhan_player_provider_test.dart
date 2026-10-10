import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_guide/features/adhan/application/adhan_player_provider.dart';
import 'package:muslim_guide/features/adhan/domain/adhan_state.dart';

import '../fake_adhan_player_service.dart';

void main() {
  test('state provider reflects fake player state transitions', () async {
    final player = FakeAdhanPlayerService();
    final container = ProviderContainer(
      overrides: [adhanPlayerServiceProvider.overrideWithValue(player)],
    );
    final states = <AdhanPlayerState>[];
    final subscription = container.listen(
      adhanPlayerStateProvider,
      (_, value) => value.whenData(states.add),
    );
    addTearDown(subscription.close);
    addTearDown(container.dispose);

    await Future<void>.delayed(Duration.zero);
    await player.play();
    player
      ..pause()
      ..complete()
      ..fail();
    await Future<void>.delayed(Duration.zero);

    expect(
      states,
      containsAllInOrder([
        AdhanPlayerState.idle,
        AdhanPlayerState.loading,
        AdhanPlayerState.playing,
        AdhanPlayerState.paused,
        AdhanPlayerState.completed,
        AdhanPlayerState.error,
      ]),
    );
  });

  test('fake player supports init, play, stop, and dispose', () async {
    final player = FakeAdhanPlayerService();

    await player.init();
    await player.play();
    await player.stop();
    await player.dispose();

    expect(player.initCalls, 1);
    expect(player.playCalls, 1);
    expect(player.stopCalls, 1);
    expect(player.disposeCalls, 1);
  });
}
