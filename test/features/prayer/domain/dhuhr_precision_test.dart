import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_guide/features/prayer/domain/models/location_data.dart';
import 'package:muslim_guide/features/prayer/domain/services/prayer_calculator.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;

typedef _SolarNoonCase = ({String name, LocationData location, DateTime date});

final _cases = <_SolarNoonCase>[
  (
    name: 'Mecca',
    location: const LocationData(
      latitude: 21.42,
      longitude: 39.83,
      timeZoneId: 'Asia/Riyadh',
    ),
    date: DateTime(2026, 10, 7),
  ),
  (
    name: 'Cairo',
    location: const LocationData(
      latitude: 30.04,
      longitude: 31.24,
      timeZoneId: 'Africa/Cairo',
    ),
    date: DateTime(2026, 10, 7),
  ),
  (
    name: 'Riyadh',
    location: const LocationData(
      latitude: 24.71,
      longitude: 46.68,
      timeZoneId: 'Asia/Riyadh',
    ),
    date: DateTime(2026, 10, 7),
  ),
  (
    name: 'Karachi',
    location: const LocationData(
      latitude: 24.86,
      longitude: 67.01,
      timeZoneId: 'Asia/Karachi',
    ),
    date: DateTime(2026, 10, 7),
  ),
  (
    name: 'Jakarta',
    location: const LocationData(
      latitude: -6.21,
      longitude: 106.85,
      timeZoneId: 'Asia/Jakarta',
    ),
    date: DateTime(2026, 10, 7),
  ),
  (
    name: 'London',
    location: const LocationData(
      latitude: 51.51,
      longitude: -0.13,
      timeZoneId: 'Europe/London',
    ),
    date: DateTime(2026, 10, 7),
  ),
  (
    name: 'Istanbul',
    location: const LocationData(
      latitude: 41.01,
      longitude: 28.98,
      timeZoneId: 'Europe/Istanbul',
    ),
    date: DateTime(2026, 10, 7),
  ),
  (
    name: 'London on DST start',
    location: const LocationData(
      latitude: 51.51,
      longitude: -0.13,
      timeZoneId: 'Europe/London',
    ),
    date: DateTime(2026, 3, 29),
  ),
];

void main() {
  setUpAll(tz_data.initializeTimeZones);

  const calculator = PrayerCalculator();

  for (final testCase in _cases) {
    test('${testCase.name}: Dhuhr agrees with Meeus solar transit ±30s', () {
      final result = calculator.calculate(
        location: testCase.location,
        date: testCase.date,
      );
      final expectedTransit = _solarTransitUtc(
        testCase.date,
        testCase.location.longitude,
      );
      final actualTransit = result.dhuhr!.toUtc();

      expect(
        actualTransit.difference(expectedTransit).inSeconds.abs(),
        lessThanOrEqualTo(30),
        reason:
            'Meeus solar transit formula as documented by NOAA; '
            'the calculator Dhuhr is astronomical solar noon.',
      );
    });
  }
}

DateTime _solarTransitUtc(DateTime date, double longitude) {
  final utcDate = DateTime.utc(date.year, date.month, date.day);
  var transit = utcDate.add(const Duration(hours: 12));
  for (var iteration = 0; iteration < 3; iteration++) {
    final equationOfTime = _equationOfTimeMinutes(transit);
    final minutesAfterUtcMidnight = 720 - 4 * longitude - equationOfTime;
    transit = utcDate.add(
      Duration(seconds: (minutesAfterUtcMidnight * 60).round()),
    );
  }
  return transit;
}

double _equationOfTimeMinutes(DateTime instant) {
  final julianDate =
      instant.millisecondsSinceEpoch / Duration.millisecondsPerDay + 2440587.5;
  final century = (julianDate - 2451545.0) / 36525;
  final geometricLongitude = _normalizeAngle(
    280.46646 + century * (36000.76983 + century * 0.0003032),
  );
  final meanAnomaly = _normalizeAngle(
    357.52911 + century * (35999.05029 - 0.0001537 * century),
  );
  final eccentricity =
      0.016708634 - century * (0.000042037 + 0.0000001267 * century);
  final omega = 125.04 - 1934.136 * century;
  final meanObliquity =
      23 +
      (26 +
              (21.448 -
                      century *
                          (46.815 + century * (0.00059 - century * 0.001813))) /
                  60) /
          60;
  final obliquity = meanObliquity + 0.00256 * _cos(omega);
  final y = math.pow(math.tan(_radians(obliquity / 2)), 2).toDouble();
  final e = eccentricity;
  final l0 = geometricLongitude;
  final m = meanAnomaly;

  return 4 *
      _degrees(
        y * _sin(2 * l0) -
            2 * e * _sin(m) +
            4 * e * y * _sin(m) * _cos(2 * l0) -
            0.5 * y * y * _sin(4 * l0) -
            1.25 * e * e * _sin(2 * m),
      );
}

double _normalizeAngle(double angle) => angle - 360 * (angle / 360).floor();

double _sin(double degrees) => math.sin(_radians(degrees));

double _cos(double degrees) => math.cos(_radians(degrees));

double _radians(double degrees) => degrees * math.pi / 180;

double _degrees(double radians) => radians * 180 / math.pi;
