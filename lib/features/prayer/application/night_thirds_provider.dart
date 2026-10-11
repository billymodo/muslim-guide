import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muslim_guide/features/prayer/application/asr_method_provider.dart';
import 'package:muslim_guide/features/prayer/application/calculation_method_provider.dart';
import 'package:muslim_guide/features/prayer/application/high_latitude_rule_provider.dart';
import 'package:muslim_guide/features/prayer/application/prayer_times_provider.dart';
import 'package:muslim_guide/features/prayer/domain/models/location_data.dart';
import 'package:muslim_guide/features/prayer/domain/models/night_thirds.dart';
import 'package:timezone/timezone.dart' as tz;

/// Calculates the night thirds (first + last) for the selected location.
///
/// Watches [prayerTimesProvider] for today's Maghrib (reusing its location,
/// methods, and cities resolution) and recalculates only tomorrow's Fajr via
/// the shared repository. Returns `null` while no location is selected, and
/// [NightThirds.unavailable] for polar or inconsistent inputs (the row hides
/// itself).
///
/// Performance note (GAP-night-thirds-2x-calc): recalculates tomorrow's times
/// per refresh on top of today's provider. Acceptable for a daily schedule;
/// revisit only if a perf issue is observed.
final AutoDisposeAsyncNotifierProvider<
  NightThirdsNotifier,
  NightThirds?
>
nightThirdsProvider =
    AsyncNotifierProvider.autoDispose<NightThirdsNotifier, NightThirds?>(
  NightThirdsNotifier.new,
);

/// Loads today's Maghrib and tomorrow's Fajr, then derives the thirds.
class NightThirdsNotifier extends AutoDisposeAsyncNotifier<NightThirds?> {
  /// Pure calculator (injectable for tests via override if needed).
  static const NightThirdsCalculator _calculator = NightThirdsCalculator();

  @override
  Future<NightThirds?> build() async {
    final today = await ref.watch(prayerTimesProvider.future);
    if (today == null) {
      return null;
    }
    final maghrib = today.maghrib;
    if (maghrib == null) {
      return NightThirds.unavailable;
    }
    final method = ref.watch(calculationMethodProvider);
    final asrMethod = ref.watch(asrMethodProvider);
    final highLatRule = ref.watch(highLatitudeRuleProvider);
    final location = today.location;
    final timezone = tz.getLocation(location.timeZoneId);
    final tomorrowDate = tz.TZDateTime(
      timezone,
      today.date.year,
      today.date.month,
      today.date.day,
    ).add(const Duration(days: 1));
    final tomorrow = ref.read(prayerTimesRepositoryProvider).calculate(
          location: LocationData(
            latitude: location.latitude,
            longitude: location.longitude,
            timeZoneId: location.timeZoneId,
            elevationMeters: location.elevationMeters,
          ),
          date: tomorrowDate,
          method: method,
          asrMethod: asrMethod,
          highLatRule: highLatRule,
        );

    return _calculator.compute(
      maghrib: maghrib,
      fajrNextDay: tomorrow.fajr,
    );
  }
}
