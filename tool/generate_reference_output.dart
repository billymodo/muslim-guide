import 'dart:io';

import 'package:muslim_guide/features/prayer/domain/models/calculation_method.dart';
import 'package:muslim_guide/features/prayer/domain/models/location_data.dart';
import 'package:muslim_guide/features/prayer/domain/services/prayer_calculator.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;

typedef _ReferenceCity = ({LocationData location, CalculationMethod method});

const _cities = <String, _ReferenceCity>{
  'Mecca': (
    location: LocationData(
      latitude: 21.42,
      longitude: 39.83,
      timeZoneId: 'Asia/Riyadh',
    ),
    method: CalculationMethod.ummAlQura,
  ),
  'Cairo': (
    location: LocationData(
      latitude: 30.04,
      longitude: 31.24,
      timeZoneId: 'Africa/Cairo',
    ),
    method: CalculationMethod.egyptian,
  ),
  'Riyadh': (
    location: LocationData(
      latitude: 24.71,
      longitude: 46.68,
      timeZoneId: 'Asia/Riyadh',
    ),
    method: CalculationMethod.ummAlQura,
  ),
  'Karachi': (
    location: LocationData(
      latitude: 24.86,
      longitude: 67.01,
      timeZoneId: 'Asia/Karachi',
    ),
    method: CalculationMethod.karachi,
  ),
  'Jakarta': (
    location: LocationData(
      latitude: -6.21,
      longitude: 106.85,
      timeZoneId: 'Asia/Jakarta',
    ),
    method: CalculationMethod.mwl,
  ),
  'London': (
    location: LocationData(
      latitude: 51.51,
      longitude: -0.13,
      timeZoneId: 'Europe/London',
    ),
    method: CalculationMethod.mwl,
  ),
  'Istanbul': (
    location: LocationData(
      latitude: 41.01,
      longitude: 28.98,
      timeZoneId: 'Europe/Istanbul',
    ),
    method: CalculationMethod.mwl,
  ),
  'Tromsø': (
    location: LocationData(
      latitude: 69.65,
      longitude: 18.96,
      timeZoneId: 'Europe/Oslo',
    ),
    method: CalculationMethod.mwl,
  ),
};

final _referenceDate = DateTime(2026, 10, 7);

void main() {
  tz_data.initializeTimeZones();
  const calculator = PrayerCalculator();
  final output = StringBuffer()
    ..writeln(
      'city,date,method,asr_method,high_lat,'
      'fajr,sunrise,dhuhr,asr,maghrib,isha,polar_state',
    );

  for (final entry in _cities.entries) {
    final result = calculator.calculate(
      location: entry.value.location,
      date: _referenceDate,
      method: entry.value.method,
    );
    output.writeln(
      [
        entry.key,
        _formatDate(_referenceDate),
        result.method.name,
        result.asrMethod.name,
        result.highLatRule.name,
        _formatTime(result.fajr),
        _formatTime(result.sunrise),
        _formatTime(result.dhuhr),
        _formatTime(result.asr),
        _formatTime(result.maghrib),
        _formatTime(result.isha),
        result.polarState.name,
      ].join(','),
    );
  }

  const outputPath = 'docs/phase-02-reference-output-2026-10-07.csv';
  File(outputPath).writeAsStringSync(output.toString(), flush: true);
  stdout.writeln('Wrote $outputPath (${_cities.length} cities).');
}

String _formatDate(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-'
    '${date.month.toString().padLeft(2, '0')}-'
    '${date.day.toString().padLeft(2, '0')}';

String _formatTime(DateTime? time) {
  if (time == null) return 'null';
  return '${time.hour.toString().padLeft(2, '0')}:'
      '${time.minute.toString().padLeft(2, '0')}:'
      '${time.second.toString().padLeft(2, '0')}';
}
