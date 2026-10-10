import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:muslim_guide/features/adhan/data/adhan_player_service.dart';
import 'package:muslim_guide/features/adhan/domain/adhan_state.dart';

/// Audio-service handler backed by `just_audio`.
class AudioServiceAdhanHandler extends BaseAudioHandler
    implements AdhanPlayerService {
  /// Creates the handler; [player] can be supplied by focused tests.
  new({AudioPlayer? player}) : _player = player ?? AudioPlayer();

  static const String _assetPath = 'assets/audio/adhan_placeholder.ogg';

  final AudioPlayer _player;
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
      _emit(AdhanPlayerState.idle);
      await super.stop();
    } on Object {
      _emit(AdhanPlayerState.error);
      rethrow;
    }
  }

  @override
  Future<void> dispose() async {
    await _playerStateSubscription?.cancel();
    await _errorSubscription?.cancel();
    await _player.dispose();
    await _states.close();
  }

  void _handlePlayerState(PlayerState playerState) {
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
