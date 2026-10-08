import 'package:muslim_guide/features/prayer/domain/models/asr_method.dart';
import 'package:muslim_guide/features/prayer/domain/models/calculation_method.dart';
import 'package:muslim_guide/features/prayer/domain/models/high_latitude_rule.dart';
import 'package:muslim_guide/features/prayer/domain/models/location_data.dart';
import 'package:muslim_guide/features/prayer/domain/models/prayer_times_result.dart';

/// Domain contract for calculating prayer times.
abstract class PrayerTimesRepository {
  /// Calculates local prayer times for [date] and [location].
  ///
  /// Times that cannot be determined astronomically remain `null`.
  PrayerTimesResult calculate({
    required LocationData location,
    required DateTime date,
    CalculationMethod method = CalculationMethod.mwl,
    AsrMethod asrMethod = AsrMethod.standard,
    HighLatitudeRule highLatRule = HighLatitudeRule.middleOfNight,
  });
}
