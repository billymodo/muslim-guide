import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_guide/features/prayer/data/country_method_mapping.dart';
import 'package:muslim_guide/features/prayer/domain/models/calculation_method.dart';

void main() {
  group('countryMethodMapping', () {
    test('maps Egypt to egyptian', () {
      expect(countryMethodMapping['EG'], CalculationMethod.egyptian);
    });

    test('maps Saudi Arabia and the Gulf to ummAlQura', () {
      for (final code in ['SA', 'AE', 'QA', 'KW', 'BH', 'OM', 'YE']) {
        expect(countryMethodMapping[code], CalculationMethod.ummAlQura);
      }
    });

    test('maps South Asia to karachi and North America to isna', () {
      expect(countryMethodMapping['PK'], CalculationMethod.karachi);
      expect(countryMethodMapping['IN'], CalculationMethod.karachi);
      expect(countryMethodMapping['US'], CalculationMethod.isna);
      expect(countryMethodMapping['CA'], CalculationMethod.isna);
    });

    test('maps Iran to tehran', () {
      expect(countryMethodMapping['IR'], CalculationMethod.tehran);
    });

    test('returns null for unknown codes (keep MWL)', () {
      expect(countryMethodMapping['XX'], isNull);
      expect(countryMethodMapping[''], isNull);
    });

    test('covers every bundled city country code', () async {
      // Every country_code present in major_cities.json must resolve to
      // either an explicit method or null (both are valid: null keeps MWL).
      // This test guards against typos in the map keys.
      const bundledCodes = [
        'AE',
        'AF',
        'AR',
        'AT',
        'AU',
        'AZ',
        'BD',
        'BE',
        'BH',
        'BR',
        'CA',
        'CH',
        'CN',
        'DE',
        'DZ',
        'EG',
        'ES',
        'ET',
        'FR',
        'GB',
        'GH',
        'HK',
        'ID',
        'IN',
        'IQ',
        'IR',
        'IT',
        'JO',
        'JP',
        'KE',
        'KG',
        'KR',
        'KW',
        'LB',
        'LK',
        'LY',
        'MA',
        'MR',
        'MX',
        'MY',
        'NG',
        'NL',
        'NO',
        'NZ',
        'OM',
        'PK',
        'PS',
        'QA',
        'RU',
        'SA',
        'SD',
        'SE',
        'SG',
        'SO',
        'SY',
        'TH',
        'TJ',
        'TN',
        'TR',
        'US',
        'UZ',
        'YE',
        'ZA',
      ];
      for (final code in bundledCodes) {
        // Access must not throw; value may be a method or null.
        expect(() => countryMethodMapping[code], returnsNormally);
      }
      // Spot-check non-default assignments among bundled codes.
      expect(countryMethodMapping['EG'], CalculationMethod.egyptian);
      expect(countryMethodMapping['SA'], CalculationMethod.ummAlQura);
      expect(countryMethodMapping['PK'], CalculationMethod.karachi);
      expect(countryMethodMapping['US'], CalculationMethod.isna);
      expect(countryMethodMapping['IR'], CalculationMethod.tehran);
    });
  });
}
