import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:muslim_guide/features/adhan/application/audio_focus_watcher.dart';
import 'package:muslim_guide/features/adhan/data/adhan_player_service.dart';
import 'package:muslim_guide/features/adhan/domain/adhan_state.dart';

/// Audio-service handler backed by `just_audio`.
class AudioServiceAdhanHandler extends BaseAudioHandler
    implements AdhanPlayerService {
  /// Creates the handler.
  ///
  /// [player] can be supplied by focused tests. [_focusWatcher] can be
  /// supplied by tests to inject a fake session provider; when omitted, a
  /// watcher bound to this handler is created lazily in [init].
  new({AudioPlayer? player, this._focusWatcher})
    : _player =
          player ??
          // Intentional: interruptions handled by audio_focus_watcher
          // (M-2). just_audio's default handleInterruptions=true would
          // auto-resume after a call, violating OD-0023. audio_service
          // itself has no interruption auto-resume path (verified 0.18.19:
          // only setActive(false) in deprecated onStop + manual
          // androidResumeOnClick for notification taps).
          AudioPlayer(handleInterruptions: false);

  static const String _assetPath = 'assets/audio/adhan_placeholder.ogg';

  final AudioPlayer _player;
  AudioFocusWatcher? _focusWatcher;
  final StreamController<AdhanPlayerState> _states =
      StreamController<AdhanPlayerState>.broadcast();

  StreamSubscription<PlayerState>? _playerStateSubscription;
  StreamSubscription<PlayerException>? _errorSubscription;
  AdhanPlayerState _currentState = AdhanPlayerState.idle;
  bool _hasStarted = false;

  @override
  Stream<AdhanPlayerState> get stateStream =>
      Stream<AdhanPlayerState>.multi((controller) {
        controller.add(_currentState);
        final subscription = _states.stream.listen(
          controller.add,
          onError: controller.addError,
        );
        controller.onCancel = subscription.cancel;
      });

  @override
  Future<void> init() async {
    _playerStateSubscription ??= _player.playerStateStream.listen(
      _handlePlayerState,
    );
    _errorSubscription ??= _player.errorStream.listen((_) {
      _emit(AdhanPlayerState.error);
    });
    mediaItem.add(
      const MediaItem(id: 'adhan', title: 'Prayer audio'),
    );
    try {
      await _player.setAsset(_assetPath);
      _focusWatcher ??= AudioFocusWatcher(
        stopForInterruption: stopForInterruption,
        isPlaying: () => _currentState == AdhanPlayerState.playing,
      );
      await _focusWatcher!.start();
      _emit(AdhanPlayerState.idle);
    } on Object {
      _emit(AdhanPlayerState.error);
      rethrow;
    }
  }

  @override
  Future<void> play() async {
    try {
      if (_player.processingState == ProcessingState.completed) {
        await _player.seek(Duration.zero);
      }
      _hasStarted = true;
      _focusWatcher?.clearInterrupted();
      await _player.play();
    } on Object {
      _emit(AdhanPlayerState.error);
      rethrow;
    }
  }

  @override
  Future<void> stop() async {
    try {
      await _player.stop();
      _hasStarted = false;
      _focusWatcher?.clearInterrupted();
      _emit(AdhanPlayerState.idle);
      await super.stop();
    } on Object {
      _emit(AdhanPlayerState.error);
      rethrow;
    }
  }

  @override
  Future<void> dispose() async {
    await _focusWatcher?.stop();
    await _playerStateSubscription?.cancel();
    await _errorSubscription?.cancel();
    await _player.dispose();
    await _states.close();
  }

  /// Called by the focus watcher when an interruption/noisy stop occurs.
  ///
  /// Stops the player and emits [AdhanPlayerState.interrupted] without
  /// clearing the watcher's flag (manual restart clears it via [play],
  /// manual stop clears it via [stop]).
  Future<void> stopForInterruption() async {
    try {
      await _player.stop();
    } on Object {
      _emit(AdhanPlayerState.error);
      rethrow;
    }
    _hasStarted = false;
    _emit(AdhanPlayerState.interrupted);
    await super.stop();
  }

  void _handlePlayerState(PlayerState playerState) {
    // While interrupted, just_audio's own stop-transition events must not
    // overwrite the interrupted state (the trailing event after our
    // watcher-triggered stop()).
    if (_currentState == AdhanPlayerState.interrupted &&
        _focusWatcher?.wasInterrupted == true) {
      return;
    }
    final nextState = switch (playerState.processingState) {
      ProcessingState.loading || ProcessingState.buffering =>
        AdhanPlayerState.loading,
      ProcessingState.completed => AdhanPlayerState.completed,
      ProcessingState.ready when playerState.playing =>
        AdhanPlayerState.playing,
      ProcessingState.ready when _hasStarted => AdhanPlayerState.paused,
      ProcessingState.ready => AdhanPlayerState.idle,
      ProcessingState.idle => AdhanPlayerState.idle,
    };
    _emit(nextState);
    playbackState.add(
      PlaybackState(
        controls: [
          if (playerState.playing) MediaControl.stop else MediaControl.play,
        ],
        systemActions: const {MediaAction.play, MediaAction.stop},
        androidCompactActionIndices: const [0],
        processingState: switch (playerState.processingState) {
          ProcessingState.loading => AudioProcessingState.loading,
          ProcessingState.buffering => AudioProcessingState.buffering,
          ProcessingState.ready => AudioProcessingState.ready,
          ProcessingState.completed => AudioProcessingState.completed,
          ProcessingState.idle => AudioProcessingState.idle,
        },
        playing: playerState.playing,
      ),
    );
  }

  void _emit(AdhanPlayerState state) {
    _currentState = state;
    if (!_states.isClosed) _states.add(state);
  }
}
