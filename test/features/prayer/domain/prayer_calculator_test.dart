import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_guide/features/prayer/domain/models/asr_method.dart';
import 'package:muslim_guide/features/prayer/domain/models/calculation_method.dart';
import 'package:muslim_guide/features/prayer/domain/models/location_data.dart';
import 'package:muslim_guide/features/prayer/domain/services/prayer_calculator.dart';
import 'package:timezone/data/latest.dart' as tz_data;

typedef _City = ({
  String name,
  LocationData location,
  CalculationMethod method,
  int fajrMinutes,
  int dhuhrMinutes,
});

const _cities = <_City>[
  (
    name: 'Mecca',
    location: LocationData(
      latitude: 21.42,
      longitude: 39.83,
      timeZoneId: 'Asia/Riyadh',
    ),
    method: CalculationMethod.ummAlQura,
    fajrMinutes: 4 * 60 + 58,
    dhuhrMinutes: 12 * 60 + 9,
  ),
  (
    name: 'Cairo',
    location: LocationData(
      latitude: 30.04,
      longitude: 31.24,
      timeZoneId: 'Africa/Cairo',
    ),
    method: CalculationMethod.egyptian,
    fajrMinutes: 5 * 60 + 25,
    dhuhrMinutes: 12 * 60 + 43,
  ),
  (
    name: 'Riyadh',
    location: LocationData(
      latitude: 24.71,
      longitude: 46.68,
      timeZoneId: 'Asia/Riyadh',
    ),
    method: CalculationMethod.ummAlQura,
    fajrMinutes: 4 * 60 + 30,
    dhuhrMinutes: 11 * 60 + 41,
  ),
  (
    name: 'Karachi',
    location: LocationData(
      latitude: 24.86,
      longitude: 67.01,
      timeZoneId: 'Asia/Karachi',
    ),
    method: CalculationMethod.karachi,
    fajrMinutes: 5 * 60 + 10,
    dhuhrMinutes: 12 * 60 + 20,
  ),
  (
    name: 'Jakarta',
    location: LocationData(
      latitude: -6.21,
      longitude: 106.85,
      timeZoneId: 'Asia/Jakarta',
    ),
    method: CalculationMethod.mwl,
    fajrMinutes: 4 * 60 + 25,
    dhuhrMinutes: 11 * 60 + 41,
  ),
  (
    name: 'London',
    location: LocationData(
      latitude: 51.51,
      longitude: -0.13,
      timeZoneId: 'Europe/London',
    ),
    method: CalculationMethod.mwl,
    fajrMinutes: 5 * 60 + 20,
    dhuhrMinutes: 12 * 60 + 48,
  ),
  (
    name: 'Istanbul',
    location: LocationData(
      latitude: 41.01,
      longitude: 28.98,
      timeZoneId: 'Europe/Istanbul',
    ),
    method: CalculationMethod.mwl,
    fajrMinutes: 5 * 60 + 35,
    dhuhrMinutes: 12 * 60 + 52,
  ),
];

void main() {
  setUpAll(tz_data.initializeTimeZones);

  const calculator = PrayerCalculator();
  final date = DateTime(2026, 10, 7);

  group('PrayerCalculator ordinary-city method and Asr matrix', () {
    for (final city in _cities) {
      for (final method in CalculationMethod.values) {
        for (final asrMethod in AsrMethod.values) {
          test('${city.name}: $method, $asrMethod returns ordered times', () {
            final result = calculator.calculate(
              location: city.location,
              date: date,
              method: method,
              asrMethod: asrMethod,
            );

            final times = [
              result.fajr,
              result.sunrise,
              result.dhuhr,
              result.asr,
              result.maghrib,
              result.isha,
            ];
            expect(times, everyElement(isNotNull));
            for (var index = 1; index < times.length; index++) {
              expect(
                times[index]!.isAfter(times[index - 1]!),
                isTrue,
                reason:
                    '${city.name}, $method, $asrMethod: '
                    '${times[index - 1]} must precede ${times[index]}',
              );
            }
            expect(result.location, city.location);
            expect(result.method, method);
            expect(result.asrMethod, asrMethod);
          });
        }
      }
    }
  });

  // Secondary baselines from Aladhan's city endpoint, 2026-10-07. These
  // checks are not substitutes for the pending official-source verification.
  group('Aladhan secondary reference checks', () {
    for (final city in _cities) {
      test('${city.name}: Fajr is within the published two-minute margin', () {
        final result = calculator.calculate(
          location: city.location,
          date: date,
          method: city.method,
        );

        expect(
          _minutesOfDay(result.fajr!),
          closeTo(city.fajrMinutes, 2),
          reason:
              'Secondary source: '
              'https://api.aladhan.com/v1/timingsByCity/07-10-2026',
        );
      });

      test('${city.name}: Dhuhr is within the published one-minute margin', () {
        final result = calculator.calculate(
          location: city.location,
          date: date,
          method: city.method,
        );

        expect(
          _minutesOfDay(result.dhuhr!),
          closeTo(city.dhuhrMinutes, 1),
          reason:
              'Secondary source: '
              'https://api.aladhan.com/v1/timingsByCity/07-10-2026',
        );
      });
    }
  });
}

int _minutesOfDay(DateTime time) => time.hour * 60 + time.minute;
