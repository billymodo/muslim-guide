import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_guide/features/prayer/domain/models/night_thirds.dart';

void main() {
  const calculator = NightThirdsCalculator();

  group('NightThirdsCalculator', () {
    test('12-hour night splits into 4h thirds', () {
      final maghrib = DateTime(2026, 10, 11, 18);
      final fajr = DateTime(2026, 10, 12, 6);

      final result = calculator.compute(maghrib: maghrib, fajrNextDay: fajr);

      expect(result.isAvailable, isTrue);
      expect(result.firstThirdStart, maghrib);
      expect(result.firstThirdEnd, DateTime(2026, 10, 11, 22));
      expect(result.lastThirdStart, DateTime(2026, 10, 12, 2));
      expect(result.lastThirdEnd, fajr);
    });

    test('10-hour night splits into 200-minute thirds', () {
      final maghrib = DateTime(2026, 10, 11, 19);
      final fajr = DateTime(2026, 10, 12, 5);

      final result = calculator.compute(maghrib: maghrib, fajrNextDay: fajr);

      expect(result.isAvailable, isTrue);
      expect(result.firstThirdEnd, DateTime(2026, 10, 11, 22, 20));
      expect(result.lastThirdStart, DateTime(2026, 10, 12, 1, 40));
    });

    test('14-hour night splits correctly', () {
      final maghrib = DateTime(2026, 10, 11, 17);
      final fajr = DateTime(2026, 10, 12, 7);

      final result = calculator.compute(maghrib: maghrib, fajrNextDay: fajr);

      expect(result.isAvailable, isTrue);
      expect(result.firstThirdEnd, DateTime(2026, 10, 11, 21, 40));
      expect(result.lastThirdStart, DateTime(2026, 10, 12, 2, 20));
    });

    test('null fajr (polar) returns unavailable', () {
      final result = calculator.compute(
        maghrib: DateTime(2026, 6, 21, 22, 30),
        fajrNextDay: null,
      );

      expect(result.isAvailable, isFalse);
      expect(result.firstThirdStart, isNull);
      expect(result.firstThirdEnd, isNull);
      expect(result.lastThirdStart, isNull);
      expect(result.lastThirdEnd, isNull);
    });

    test('null maghrib returns unavailable', () {
      final result = calculator.compute(
        maghrib: null,
        fajrNextDay: DateTime(2026, 12, 21, 6, 30),
      );

      expect(result.isAvailable, isFalse);
      expect(result.firstThirdStart, isNull);
      expect(result.lastThirdEnd, isNull);
    });

    test('both null returns unavailable', () {
      final result = calculator.compute(maghrib: null, fajrNextDay: null);

      expect(result.isAvailable, isFalse);
    });

    test('fajr before maghrib returns unavailable', () {
      final result = calculator.compute(
        maghrib: DateTime(2026, 10, 11, 18),
        fajrNextDay: DateTime(2026, 10, 11, 5),
      );

      expect(result.isAvailable, isFalse);
    });

    test('fajr equal to maghrib returns unavailable', () {
      final moment = DateTime(2026, 10, 11, 18);
      final result = calculator.compute(maghrib: moment, fajrNextDay: moment);

      expect(result.isAvailable, isFalse);
    });

    test('midnight crossing keeps calendar dates', () {
      final maghrib = DateTime(2026, 10, 11, 21, 30);
      final fajr = DateTime(2026, 10, 12, 4, 10);

      final result = calculator.compute(maghrib: maghrib, fajrNextDay: fajr);

      expect(result.isAvailable, isTrue);
      expect(result.firstThirdStart!.day, 11);
      expect(result.lastThirdEnd!.day, 12);
      expect(
        result.lastThirdEnd!.difference(result.firstThirdStart!),
        const Duration(hours: 6, minutes: 40),
      );
    });

    test('minute precision is preserved for odd durations', () {
      // 10h37m night: 637 minutes; thirds of 212m20s each.
      final maghrib = DateTime(2026, 10, 11, 18, 3);
      final fajr = DateTime(2026, 10, 12, 4, 40);

      final result = calculator.compute(maghrib: maghrib, fajrNextDay: fajr);

      expect(result.isAvailable, isTrue);
      expect(
        result.firstThirdEnd,
        maghrib.add(const Duration(minutes: 212, seconds: 20)),
      );
      expect(
        result.lastThirdStart,
        maghrib.add(const Duration(minutes: 424, seconds: 40)),
      );
    });

    test('isAvailable is true for an ordinary night', () {
      final result = calculator.compute(
        maghrib: DateTime(2026, 10, 11, 17, 45),
        fajrNextDay: DateTime(2026, 10, 12, 5, 15),
      );

      expect(result.isAvailable, isTrue);
      expect(result.firstThirdStart, isNotNull);
      expect(result.firstThirdEnd, isNotNull);
      expect(result.lastThirdStart, isNotNull);
      expect(result.lastThirdEnd, isNotNull);
    });
  });
}
