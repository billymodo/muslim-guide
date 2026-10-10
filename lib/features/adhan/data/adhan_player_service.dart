import 'package:muslim_guide/features/adhan/domain/adhan_state.dart';

/// Injectable playback operations for the in-app adhan player.
abstract interface class AdhanPlayerService {
  /// Loads the placeholder audio and prepares playback.
  Future<void> init();

  /// Starts or resumes playback.
  Future<void> play();

  /// Stops playback.
  Future<void> stop();

  /// Playback-state updates.
  Stream<AdhanPlayerState> get stateStream;

  /// Releases the underlying audio resources.
  Future<void> dispose();
}
