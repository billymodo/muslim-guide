import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_guide/features/prayer/data/cities_loader.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(tz_data.initializeTimeZones);

  test('loads the bundled cities with unique, valid data', () async {
    final cities = await CitiesLoader(assetBundle: rootBundle).load();

    expect(cities.length, greaterThanOrEqualTo(100));
    expect(cities.map((city) => city.id).toSet(), hasLength(cities.length));
    for (final city in cities) {
      expect(city.id, isNotEmpty);
      expect(city.nameAr, isNotEmpty);
      expect(city.nameEn, isNotEmpty);
      expect(city.countryAr, isNotEmpty);
      expect(city.countryEn, isNotEmpty);
      expect(city.countryCode, matches(RegExp(r'^[A-Z]{2}$')));
      expect(city.latitude, inInclusiveRange(-90, 90));
      expect(city.longitude, inInclusiveRange(-180, 180));
    }
    final invalidTimezones = cities
        .where(
          (city) => !tz.timeZoneDatabase.locations.containsKey(city.timezone),
        )
        .map((city) => '${city.nameEn}: ${city.timezone}')
        .toList();
    expect(invalidTimezones, isEmpty, reason: 'Unsupported timezone IDs');

    final ids = cities.map((city) => city.id).toSet();
    expect(
      ids,
      containsAll([
        'mecca',
        'cairo',
        'riyadh',
        'karachi',
        'jakarta',
        'london',
        'istanbul',
        'tromso',
      ]),
    );
  });

  test('caches the parsed city list', () async {
    final bundle = _CountingAssetBundle();
    final loader = CitiesLoader(assetBundle: bundle);

    final firstLoad = loader.load();
    final secondLoad = loader.load();

    expect(identical(firstLoad, secondLoad), isTrue);
    expect(await firstLoad, isEmpty);
    expect(bundle.loadCount, 1);
  });
}

class _CountingAssetBundle extends CachingAssetBundle {
  int loadCount = 0;

  @override
  Future<ByteData> load(String key) async {
    loadCount++;
    return ByteData.sublistView(Uint8List.fromList('{"cities":[]}'.codeUnits));
  }
}
