import 'package:meta/meta.dart';

/// The first and last thirds of the night between Maghrib and next-day Fajr.
///
/// All fields are `null` when Maghrib or next-day Fajr is unavailable
/// (polar conditions) or inconsistent (Fajr not after Maghrib).
@immutable
class NightThirds {
  /// Creates the night-thirds boundaries.
  ///
  /// Pass all-`null` values for polar or inconsistent inputs; [isAvailable]
  /// is then `false` and the row hides itself.
  const new({
    required this.firstThirdStart,
    required this.firstThirdEnd,
    required this.lastThirdStart,
    required this.lastThirdEnd,
  });

  /// An unavailable result (polar or inconsistent inputs).
  static const NightThirds unavailable = NightThirds(
    firstThirdStart: null,
    firstThirdEnd: null,
    lastThirdStart: null,
    lastThirdEnd: null,
  );

  /// Start of the first third (= Maghrib).
  final DateTime? firstThirdStart;

  /// End of the first third (= Maghrib + night duration / 3).
  final DateTime? firstThirdEnd;

  /// Start of the last third (= Maghrib + night duration * 2 / 3).
  final DateTime? lastThirdStart;

  /// End of the last third (= next-day Fajr).
  final DateTime? lastThirdEnd;

  /// Whether both thirds are available for display.
  bool get isAvailable =>
      firstThirdStart != null &&
      firstThirdEnd != null &&
      lastThirdStart != null &&
      lastThirdEnd != null;
}

/// Pure calculator for the night thirds (no Flutter dependencies).
class NightThirdsCalculator {
  /// Creates a stateless night-thirds calculator.
  const new();

  /// Computes the first and last thirds of the night.
  ///
  /// Returns [NightThirds.unavailable] when [maghrib] or [fajrNextDay] is
  /// `null` (polar), or when [fajrNextDay] is not strictly after [maghrib].
  /// Uses [DateTime] (not time-of-day) so midnight crossings keep their
  /// calendar dates; division keeps microsecond precision.
  NightThirds compute({
    required DateTime? maghrib,
    required DateTime? fajrNextDay,
  }) {
    if (maghrib == null || fajrNextDay == null) {
      return NightThirds.unavailable;
    }
    if (!fajrNextDay.isAfter(maghrib)) {
      return NightThirds.unavailable;
    }
    final night = fajrNextDay.difference(maghrib);
    final third = night ~/ 3;
    return NightThirds(
      firstThirdStart: maghrib,
      firstThirdEnd: maghrib.add(third),
      lastThirdStart: maghrib.add(third * 2),
      lastThirdEnd: fajrNextDay,
    );
  }
}
