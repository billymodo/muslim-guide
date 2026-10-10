/// Observable playback states of the in-app adhan player.
enum AdhanPlayerState {
  /// No audio is loaded or playing.
  idle,

  /// The audio source is loading or buffering.
  loading,

  /// Audio is currently playing.
  playing,

  /// Audio is loaded but paused.
  paused,

  /// The audio source finished playing.
  completed,

  /// Audio loading or playback failed.
  error,
}
