import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_guide/features/prayer/domain/exceptions/prayer_calculation_exception.dart';
import 'package:muslim_guide/features/prayer/domain/models/location_data.dart';
import 'package:muslim_guide/features/prayer/domain/services/prayer_calculator.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;

void main() {
  setUpAll(tz_data.initializeTimeZones);

  const calculator = PrayerCalculator();
  final date = DateTime(2026, 10, 7);

  group('Input validation', () {
    final invalidLocations = [
      (
        label: 'latitude below -90 degrees',
        location: const LocationData(
          latitude: -90.01,
          longitude: 0,
          timeZoneId: 'Etc/UTC',
        ),
      ),
      (
        label: 'latitude above 90 degrees',
        location: const LocationData(
          latitude: 90.01,
          longitude: 0,
          timeZoneId: 'Etc/UTC',
        ),
      ),
      (
        label: 'non-finite latitude',
        location: const LocationData(
          latitude: double.nan,
          longitude: 0,
          timeZoneId: 'Etc/UTC',
        ),
      ),
      (
        label: 'longitude below -180 degrees',
        location: const LocationData(
          latitude: 0,
          longitude: -180.01,
          timeZoneId: 'Etc/UTC',
        ),
      ),
      (
        label: 'longitude above 180 degrees',
        location: const LocationData(
          latitude: 0,
          longitude: 180.01,
          timeZoneId: 'Etc/UTC',
        ),
      ),
      (
        label: 'non-finite longitude',
        location: const LocationData(
          latitude: 0,
          longitude: double.infinity,
          timeZoneId: 'Etc/UTC',
        ),
      ),
      (
        label: 'negative elevation',
        location: const LocationData(
          latitude: 0,
          longitude: 0,
          timeZoneId: 'Etc/UTC',
          elevationMeters: -1,
        ),
      ),
      (
        label: 'non-finite elevation',
        location: const LocationData(
          latitude: 0,
          longitude: 0,
          timeZoneId: 'Etc/UTC',
          elevationMeters: double.infinity,
        ),
      ),
    ];

    for (final scenario in invalidLocations) {
      test('${scenario.label} is rejected explicitly', () {
        expect(
          () => calculator.calculate(location: scenario.location, date: date),
          throwsA(isA<PrayerCalculationException>()),
          reason: 'Invalid geographic input must not produce prayer times.',
        );
      });
    }

    test('unknown IANA timezone is reported as a domain exception', () {
      expect(
        () => calculator.calculate(
          location: const LocationData(
            latitude: 0,
            longitude: 0,
            timeZoneId: 'Invalid/Unknown',
          ),
          date: date,
        ),
        throwsA(isA<PrayerCalculationException>()),
        reason: 'An unknown timezone must not silently use a fallback.',
      );
    });
  });

  test('leap-day calculations return ordered local prayer times', () {
    final result = calculator.calculate(
      location: const LocationData(
        latitude: 21.42,
        longitude: 39.83,
        timeZoneId: 'Asia/Riyadh',
      ),
      date: DateTime(2024, 2, 29),
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
        reason: 'Leap-day prayer times must remain in chronological order.',
      );
      expect(
        times[index]!.day,
        29,
        reason: 'Each prayer time must remain on the requested leap day.',
      );
    }
  });
}
