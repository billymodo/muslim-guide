/// A prayer or solar event with a calculated time.
enum PrayerTime {
  /// The dawn prayer.
  fajr,

  /// Sunrise, included as a reference time rather than a prayer.
  sunrise,

  /// The noon prayer.
  dhuhr,

  /// The afternoon prayer.
  asr,

  /// The sunset prayer.
  maghrib,

  /// The night prayer.
  isha,
}
