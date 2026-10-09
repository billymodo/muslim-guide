// Reference: PrayTimes.js v2.5 (LGPL). See tool/asr_reference_generator.md
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_guide/features/prayer/domain/models/location_data.dart';
import 'package:muslim_guide/features/prayer/domain/services/prayer_calculator.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;

typedef _Case = ({
  String name,
  LocationData location,
  DateTime date,
  String goldenAsr,
});

List<_Case> _loadCases() {
  final raw = File('test/fixtures/asr_reference.json').readAsStringSync();
  final decoded = jsonDecode(raw) as Map<String, dynamic>;
  final cases = (decoded['cases'] as List).cast<Map<String, dynamic>>();
  return cases.map((entry) {
    final dateParts =
        (entry['date'] as String).split('-').map(int.parse).toList();
    return (
      name: entry['name'] as String,
      location: LocationData(
        latitude: (entry['lat'] as num).toDouble(),
        longitude: (entry['lng'] as num).toDouble(),
        timeZoneId: entry['timezone'] as String,
      ),
      date: DateTime(dateParts[0], dateParts[1], dateParts[2]),
      goldenAsr: entry['golden_asr'] as String,
    );
  }).toList();
}

void main() {
  setUpAll(tz_data.initializeTimeZones);

  const calculator = PrayerCalculator();

  for (final testCase in _loadCases()) {
    test('Asr matches golden reference: ${testCase.name}', () {
      final result = calculator.calculate(
        location: testCase.location,
        date: testCase.date,
      );
      final asr = result.asr!;
      final appSeconds = asr.hour * 3600 + asr.minute * 60 + asr.second;
      final goldenSeconds = _parseHms(testCase.goldenAsr);

      expect(
        (appSeconds - goldenSeconds).abs(),
        lessThanOrEqualTo(10),
        reason:
            '${testCase.name}: app asr must match the PrayTimes.js v2.5 '
            'golden value ${testCase.goldenAsr} within 10s '
            '(fixture: test/fixtures/asr_reference.json).',
      );
    });
  }
}

int _parseHms(String hms) {
  final parts = hms.split(':').map(int.parse).toList();
  return parts[0] * 3600 + parts[1] * 60 + parts[2];
}
