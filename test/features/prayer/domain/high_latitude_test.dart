import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_guide/features/prayer/domain/models/calculation_method.dart';
import 'package:muslim_guide/features/prayer/domain/models/high_latitude_rule.dart';
import 'package:muslim_guide/features/prayer/domain/models/location_data.dart';
import 'package:muslim_guide/features/prayer/domain/models/prayer_times_result.dart';
import 'package:muslim_guide/features/prayer/domain/services/prayer_calculator.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;

const _tromso = LocationData(
  latitude: 69.65,
  longitude: 18.96,
  timeZoneId: 'Europe/Oslo',
);

void main() {
  setUpAll(tz_data.initializeTimeZones);

  const calculator = PrayerCalculator();
  const rules = HighLatitudeRule.values;
  final polarDates = [
    (date: DateTime(2026, 6, 21), state: PolarState.polarDay),
    (date: DateTime(2026, 12, 21), state: PolarState.polarNight),
  ];

  group('Tromso polar conditions', () {
    for (final scenario in polarDates) {
      for (final rule in rules) {
        test(
          '${scenario.date} with $rule leaves absent events unavailable',
          () {
            final unadjustedResult = calculator.calculate(
              location: _tromso,
              date: scenario.date,
              highLatRule: HighLatitudeRule.none,
            );
            final result = calculator.calculate(
              location: _tromso,
              date: scenario.date,
              highLatRule: rule,
            );

            expect(result.polarState, scenario.state);
            expect(result.sunrise, isNull);
            expect(result.maghrib, isNull);
            expect(result.fajr, unadjustedResult.fajr);
            expect(result.isha, unadjustedResult.isha);
            expect(result.dhuhr, isNotNull);
            expect(result.hasPolarAnomaly, isTrue);
          },
        );
      }
    }
  });

  group('High-latitude twilight adjustments', () {
    for (final date in [DateTime(2026, 5), DateTime(2026, 8)]) {
      for (final rule in rules) {
        test('$date applies $rule only when twilight is unavailable', () {
          final result = calculator.calculate(
            location: _tromso,
            date: date,
            highLatRule: rule,
          );

          expect(result.polarState, PolarState.normal);
          expect(result.sunrise, isNotNull);
          expect(result.maghrib, isNotNull);
          if (rule == HighLatitudeRule.none) {
            expect(result.fajr, isNull);
            expect(result.isha, isNull);
          } else {
            expect(result.fajr, isNotNull);
            expect(result.isha, isNotNull);
          }
        });
      }
    }
  });

  group('Umm al-Qura fixed Isha interval', () {
    for (final rule in rules) {
      test('$rule preserves the 90-minute interval on short summer nights', () {
        final result = calculator.calculate(
          location: _tromso,
          date: DateTime(2026, 8),
          method: CalculationMethod.ummAlQura,
          highLatRule: rule,
        );

        expect(result.maghrib, isNotNull);
        expect(result.isha, isNotNull);
        expect(
          result.isha!.difference(result.maghrib!).inMinutes,
          90,
          reason: 'Umm al-Qura Isha is a fixed interval, not a twilight angle.',
        );
      });
    }
  });

  group('Polar-state classification by hemisphere and latitude', () {
    final cases = [
      (
        label: '60N on June solstice remains normal',
        latitude: 60.0,
        date: DateTime(2026, 6, 21),
        expected: PolarState.normal,
      ),
      (
        label: '75N on June solstice is polar day',
        latitude: 75.0,
        date: DateTime(2026, 6, 21),
        expected: PolarState.polarDay,
      ),
      (
        label: '75N on December solstice is polar night',
        latitude: 75.0,
        date: DateTime(2026, 12, 21),
        expected: PolarState.polarNight,
      ),
      (
        label: '69.65S on June solstice is polar night',
        latitude: -69.65,
        date: DateTime(2026, 6, 21),
        expected: PolarState.polarNight,
      ),
      (
        label: '69.65S on December solstice is polar day',
        latitude: -69.65,
        date: DateTime(2026, 12, 21),
        expected: PolarState.polarDay,
      ),
      (
        label: 'equatorial location on either season has sunrise and sunset',
        latitude: 0.0,
        date: DateTime(2026, 12, 21),
        expected: PolarState.normal,
      ),
    ];

    for (final scenario in cases) {
      test(scenario.label, () {
        final result = calculator.calculate(
          location: LocationData(
            latitude: scenario.latitude,
            longitude: 0,
            timeZoneId: 'Etc/UTC',
          ),
          date: scenario.date,
        );

        expect(result.polarState, scenario.expected);
        expect(result.sunrise != null, scenario.expected == PolarState.normal);
        expect(result.maghrib != null, scenario.expected == PolarState.normal);
      });
    }
  });
}
