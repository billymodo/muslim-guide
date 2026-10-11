/// Observable playback states of the in-app adhan player.
///
/// State machine (Task 6, OD-0023):
/// ```text
/// idle → loading → playing → (interruption) → interrupted
/// interrupted → (tap restart) → playing
/// playing → (natural end) → completed
/// playing → (user stop) → idle
/// ```
/// `interrupted` is entered only when playback stops due to an audio-focus
/// interruption or a noisy-device event; it is never resumed automatically.
/// Manual restart from the in-app controls is the only way back to `playing`.
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

  /// Playback was stopped by an audio-focus interruption or noisy event.
  ///
  /// No automatic resume; the user restarts manually from the in-app
  /// controls.
  interrupted,
}
