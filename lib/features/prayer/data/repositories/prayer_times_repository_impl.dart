import 'package:muslim_guide/features/prayer/domain/models/asr_method.dart';
import 'package:muslim_guide/features/prayer/domain/models/calculation_method.dart';
import 'package:muslim_guide/features/prayer/domain/models/high_latitude_rule.dart';
import 'package:muslim_guide/features/prayer/domain/models/location_data.dart';
import 'package:muslim_guide/features/prayer/domain/models/prayer_times_result.dart';
import 'package:muslim_guide/features/prayer/domain/repositories/prayer_times_repository.dart';
import 'package:muslim_guide/features/prayer/domain/services/prayer_calculator.dart';

/// Delegates prayer-time calculation to the pure [PrayerCalculator].
class PrayerTimesRepositoryImpl implements PrayerTimesRepository {
  /// Creates a repository backed by the pure calculator.
  const new();

  static const PrayerCalculator _calculator = PrayerCalculator();

  @override
  PrayerTimesResult calculate({
    required LocationData location,
    required DateTime date,
    CalculationMethod method = CalculationMethod.mwl,
    AsrMethod asrMethod = AsrMethod.standard,
    HighLatitudeRule highLatRule = HighLatitudeRule.middleOfNight,
  }) {
    return _calculator.calculate(
      location: location,
      date: date,
      method: method,
      asrMethod: asrMethod,
      highLatRule: highLatRule,
    );
  }
}
