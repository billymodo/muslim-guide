/// A rule for adjusting twilight-based prayers at high latitudes.
enum HighLatitudeRule {
  /// Limits Fajr and Isha to the middle of the night.
  middleOfNight,

  /// Limits Fajr and Isha to one seventh of the night.
  seventhOfNight,

  /// Limits twilight using a fraction derived from its angle.
  twilightAngle,

  /// Applies no high-latitude adjustment.
  none,
}
