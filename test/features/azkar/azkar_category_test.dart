import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_guide/features/azkar/domain/azkar_category.dart';

void main() {
  group('AzkarCategoryId.fromValue', () {
    test('resolves all five known values', () {
      expect(AzkarCategoryId.fromValue('morning'), AzkarCategoryId.morning);
      expect(AzkarCategoryId.fromValue('evening'), AzkarCategoryId.evening);
      expect(AzkarCategoryId.fromValue('sleep'), AzkarCategoryId.sleep);
      expect(AzkarCategoryId.fromValue('wake_up'), AzkarCategoryId.wakeUp);
      expect(AzkarCategoryId.fromValue('tasbih'), AzkarCategoryId.tasbih);
    });

    test('returns null for unknown or null values', () {
      expect(AzkarCategoryId.fromValue('noon'), isNull);
      expect(AzkarCategoryId.fromValue(''), isNull);
      expect(AzkarCategoryId.fromValue(null), isNull);
    });

    test('round-trips each value', () {
      for (final id in AzkarCategoryId.values) {
        expect(AzkarCategoryId.fromValue(id.value), id);
      }
    });
  });
}
