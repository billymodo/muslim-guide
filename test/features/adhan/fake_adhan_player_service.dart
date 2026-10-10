import 'dart:async';

import 'package:muslim_guide/features/adhan/data/adhan_player_service.dart';
import 'package:muslim_guide/features/adhan/domain/adhan_state.dart';

class FakeAdhanPlayerService implements AdhanPlayerService {
  final StreamController<AdhanPlayerState> _states =
      StreamController<AdhanPlayerState>.broadcast();
  AdhanPlayerState _state = AdhanPlayerState.idle;
  int initCalls = 0;
  int playCalls = 0;
  int stopCalls = 0;
  int disposeCalls = 0;

  @override
  Stream<AdhanPlayerState> get stateStream =>
      Stream<AdhanPlayerState>.multi((controller) {
        controller.add(_state);
        final subscription = _states.stream.listen(
          controller.add,
          onError: controller.addError,
        );
        controller.onCancel = subscription.cancel;
      });

  @override
  Future<void> init() async {
    initCalls++;
    _emit(AdhanPlayerState.idle);
  }

  @override
  Future<void> play() async {
    playCalls++;
    _emit(AdhanPlayerState.loading);
    _emit(AdhanPlayerState.playing);
  }

  @override
  Future<void> stop() async {
    stopCalls++;
    _emit(AdhanPlayerState.idle);
  }

  @override
  Future<void> dispose() async {
    disposeCalls++;
    await _states.close();
  }

  void pause() => _emit(AdhanPlayerState.paused);

  void complete() => _emit(AdhanPlayerState.completed);

  void fail() => _emit(AdhanPlayerState.error);

  void _emit(AdhanPlayerState state) {
    _state = state;
    if (!_states.isClosed) _states.add(state);
  }
}
