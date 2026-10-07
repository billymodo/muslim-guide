import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_guide/features/prayer/domain/models/calculation_method.dart';
import 'package:muslim_guide/features/prayer/domain/models/location_data.dart';
import 'package:muslim_guide/features/prayer/domain/services/prayer_calculator.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;

const _london = LocationData(
  latitude: 51.51,
  longitude: -0.13,
  timeZoneId: 'Europe/London',
);

void main() {
  setUpAll(tz_data.initializeTimeZones);

  const calculator = PrayerCalculator();
  final transitions = [
    (date: DateTime(2026, 3, 29), offset: const Duration(hours: 1)),
    (date: DateTime(2026, 10, 25), offset: Duration.zero),
  ];

  group('Europe/London DST transitions', () {
    for (final transition in transitions) {
      for (final method in CalculationMethod.values) {
        test('${transition.date} preserves local date and BST/GMT offset', () {
          final result = calculator.calculate(
            location: _london,
            date: transition.date,
            method: method,
          );

          for (final time in [
            result.fajr,
            result.sunrise,
            result.dhuhr,
            result.asr,
            result.maghrib,
            result.isha,
          ]) {
            expect(time, isNotNull);
            expect(time!.year, transition.date.year);
            expect(time.month, transition.date.month);
            expect(time.day, transition.date.day);
            expect(
              time.timeZoneOffset,
              transition.offset,
              reason: '$method must use the offset at each prayer instant',
            );
          }
          expect(
            result.dhuhr!.hour,
            inInclusiveRange(11, 13),
            reason: '$method Dhuhr should remain near local solar noon',
          );
        });
      }
    }
  });
}
