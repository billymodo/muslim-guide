import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_guide/features/location/domain/location_result.dart';

void main() {
  group('LocationResult', () {
    final timestamp = DateTime(2026, 10, 8, 12);
    final result = LocationResult(
      latitude: 21.4225,
      longitude: 39.8262,
      accuracy: 8.5,
      timestamp: timestamp,
    );

    test('stores the provided values', () {
      expect(result.latitude, 21.4225);
      expect(result.longitude, 39.8262);
      expect(result.accuracy, 8.5);
      expect(result.timestamp, timestamp);
    });

    test('supports equality and hashCode', () {
      final other = LocationResult(
        latitude: 21.4225,
        longitude: 39.8262,
        accuracy: 8.5,
        timestamp: timestamp,
      );

      expect(result, equals(other));
      expect(result.hashCode, equals(other.hashCode));
    });

    test('copyWith updates only the requested values', () {
      final updated = result.copyWith(latitude: 30, accuracy: 12);

      expect(updated.latitude, 30);
      expect(updated.longitude, 39.8262);
      expect(updated.accuracy, 12);
      expect(updated.timestamp, timestamp);
    });

    test('toString contains the resolved values', () {
      expect(result.toString(), contains('LocationResult'));
      expect(result.toString(), contains('21.4225'));
    });
  });
}
