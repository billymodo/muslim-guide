import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_guide/features/prayer/domain/models/city.dart';

void main() {
  const validJson = <String, dynamic>{
    'id': 'mecca',
    'name_ar': 'مكة المكرمة',
    'name_en': 'Mecca',
    'country_ar': 'السعودية',
    'country_en': 'Saudi Arabia',
    'country_code': 'SA',
    'lat': 21.4225,
    'lng': 39.8262,
    'timezone': 'Asia/Riyadh',
    'elevation': 277,
  };

  group('City.fromJson', () {
    test('parses all supported fields', () {
      final city = City.fromJson(validJson);

      expect(city.id, 'mecca');
      expect(city.nameAr, 'مكة المكرمة');
      expect(city.nameEn, 'Mecca');
      expect(city.countryAr, 'السعودية');
      expect(city.countryEn, 'Saudi Arabia');
      expect(city.countryCode, 'SA');
      expect(city.latitude, 21.4225);
      expect(city.longitude, 39.8262);
      expect(city.timezone, 'Asia/Riyadh');
      expect(city.elevation, 277);
    });

    test('accepts a null elevation', () {
      final city = City.fromJson({...validJson, 'elevation': null});

      expect(city.elevation, isNull);
    });

    test('rejects a missing required field', () {
      final json = Map<String, dynamic>.of(validJson)..remove('name_ar');

      expect(() => City.fromJson(json), throwsFormatException);
    });

    test('rejects an invalid coordinate', () {
      expect(
        () => City.fromJson({...validJson, 'lat': 91}),
        throwsFormatException,
      );
    });
  });
}
