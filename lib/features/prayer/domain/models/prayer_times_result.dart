import 'package:muslim_guide/features/prayer/domain/models/asr_method.dart';
import 'package:muslim_guide/features/prayer/domain/models/calculation_method.dart';
import 'package:muslim_guide/features/prayer/domain/models/high_latitude_rule.dart';
import 'package:muslim_guide/features/prayer/domain/models/location_data.dart';

/// A calculated prayer schedule, including unavailable astronomical events.
enum PolarState {
  /// Sunrise and sunset are both astronomically possible.
  normal,

  /// The sun does not set at the location on this date.
  polarDay,

  /// The sun does not rise at the location on this date.
  polarNight,
}

/// Calculated local times and the inputs used to produce them.
class PrayerTimesResult {
  /// Creates a result for a location, date, and calculation configuration.
  const new({
    required this.fajr,
    required this.sunrise,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
    required this.polarState,
    required this.location,
    required this.date,
    required this.method,
    required this.asrMethod,
    required this.highLatRule,
  });

  /// Fajr as a timezone-aware local time, or `null` if unavailable.
  final DateTime? fajr;

  /// Sunrise as a timezone-aware local time, or `null` if unavailable.
  final DateTime? sunrise;

  /// Solar transit as a timezone-aware local time, or `null` if unavailable.
  final DateTime? dhuhr;

  /// Asr as a timezone-aware local time, or `null` if unavailable.
  final DateTime? asr;

  /// Maghrib as a timezone-aware local time, or `null` if unavailable.
  final DateTime? maghrib;

  /// Isha as a timezone-aware local time, or `null` if unavailable.
  final DateTime? isha;

  /// Whether the day has ordinary sunrise and sunset, polar day, or polar
  /// night.
  final PolarState polarState;

  /// The coordinates and timezone used for this calculation.
  final LocationData location;

  /// The local calendar date used for this calculation.
  final DateTime date;

  /// The selected calculation convention.
  final CalculationMethod method;

  /// The selected Asr shadow convention.
  final AsrMethod asrMethod;

  /// The selected high-latitude adjustment rule.
  final HighLatitudeRule highLatRule;

  /// Whether the twilight and horizon-dependent times are all available.
  bool get isComplete =>
      fajr != null && sunrise != null && maghrib != null && isha != null;

  /// Whether the calculation encountered polar-day or polar-night conditions.
  bool get hasPolarAnomaly => polarState != PolarState.normal;
}
