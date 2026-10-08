import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:muslim_guide/app/providers/bootstrap_provider.dart';
import 'package:muslim_guide/data/settings/settings_repository.dart';
import 'package:muslim_guide/data/storage/hive_store.dart';
import 'package:muslim_guide/features/prayer/application/asr_method_provider.dart';
import 'package:muslim_guide/features/prayer/application/calculation_method_provider.dart';
import 'package:muslim_guide/features/prayer/application/high_latitude_rule_provider.dart';
import 'package:muslim_guide/features/prayer/application/location_provider.dart';
import 'package:muslim_guide/features/prayer/application/prayer_times_provider.dart';
import 'package:muslim_guide/features/prayer/domain/models/asr_method.dart';
import 'package:muslim_guide/features/prayer/domain/models/calculation_method.dart';
import 'package:muslim_guide/features/prayer/domain/models/city.dart';
import 'package:muslim_guide/features/prayer/domain/models/high_latitude_rule.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

const City riyadh = City(
  id: 'riyadh',
  nameAr: 'Riyadh',
  nameEn: 'Riyadh',
  countryAr: 'Saudi Arabia',
  countryEn: 'Saudi Arabia',
  countryCode: 'SA',
  latitude: 24.6333,
  longitude: 46.7167,
  timezone: 'Asia/Riyadh',
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(tz_data.initializeTimeZones);

  late Directory tempDirectory;
  late Box<dynamic> box;

  ProviderContainer createContainer() {
    final container = ProviderContainer(
      overrides: [
        hiveStoreProvider.overrideWith((ref) => HiveStore()),
        settingsRepositoryProvider.overrideWithValue(SettingsRepository(box)),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  setUp(() async {
    tempDirectory = await Directory.systemTemp.createTemp('prayer_times_');
    Hive.init(tempDirectory.path);
    box = await Hive.openBox<dynamic>('settings');
  });

  tearDown(() async {
    await Hive.close();
    await tempDirectory.delete(recursive: true);
  });

  test('returns null while no location is selected', () async {
    final container = createContainer();

    expect(await container.read(prayerTimesProvider.future), isNull);
  });

  test('calculates times for the selected city with DEC-0028 defaults',
      () async {
    final container = createContainer();
    await container.read(locationProvider.notifier).selectCity('mecca');

    final result = await container.read(prayerTimesProvider.future);

    expect(result, isNotNull);
    expect(result!.location.timeZoneId, 'Asia/Riyadh');
    expect(result.method, CalculationMethod.mwl);
    expect(result.asrMethod, AsrMethod.standard);
    expect(result.highLatRule, HighLatitudeRule.middleOfNight);
    expect(result.fajr, isNotNull);
    expect(result.sunrise, isNotNull);
    expect(result.dhuhr, isNotNull);
    expect(result.asr, isNotNull);
    expect(result.maghrib, isNotNull);
    expect(result.isha, isNotNull);
  });

  test('recalculates when the calculation method changes', () async {
    final container = createContainer();
    final listener = container.listen(prayerTimesProvider, (_, _) {});
    addTearDown(listener.close);
    await container.read(locationProvider.notifier).selectCity('mecca');
    final first = await container.read(prayerTimesProvider.future);
    expect(first, isNotNull);

    await container
        .read(calculationMethodProvider.notifier)
        .setMethod(CalculationMethod.egyptian);
    final second = await container.read(prayerTimesProvider.future);

    expect(second, isNotNull);
    expect(second!.method, CalculationMethod.egyptian);
    expect(second.fajr, isNot(first!.fajr));
  });

  test('reports an error for an unknown bundled city', () async {
    final container = createContainer();
    await container.read(locationProvider.notifier).selectCity('atlantis');

    await expectLater(
      container.read(prayerTimesProvider.future),
      throwsStateError,
    );
  });

  group('prayer settings providers', () {
    test('expose the DEC-0028 defaults', () {
      final container = createContainer();

      expect(
        container.read(calculationMethodProvider),
        CalculationMethod.mwl,
      );
      expect(container.read(asrMethodProvider), AsrMethod.standard);
      expect(
        container.read(highLatitudeRuleProvider),
        HighLatitudeRule.middleOfNight,
      );
    });

    test('persist choices and restore them in a fresh container', () async {
      final container = createContainer();
      await container
          .read(calculationMethodProvider.notifier)
          .setMethod(CalculationMethod.karachi);
      await container
          .read(asrMethodProvider.notifier)
          .setMethod(AsrMethod.hanafi);
      await container
          .read(highLatitudeRuleProvider.notifier)
          .setRule(HighLatitudeRule.twilightAngle);

      expect(await box.get('calculation_method'), 'karachi');
      expect(await box.get('asr_method'), 'hanafi');
      expect(await box.get('high_latitude_rule'), 'twilightAngle');

      final fresh = createContainer();
      expect(
        fresh.read(calculationMethodProvider),
        CalculationMethod.mwl,
      );
      expect(fresh.read(asrMethodProvider), AsrMethod.standard);
      expect(
        fresh.read(highLatitudeRuleProvider),
        HighLatitudeRule.middleOfNight,
      );
      await pumpEventQueue();

      expect(
        fresh.read(calculationMethodProvider),
        CalculationMethod.karachi,
      );
      expect(fresh.read(asrMethodProvider), AsrMethod.hanafi);
      expect(
        fresh.read(highLatitudeRuleProvider),
        HighLatitudeRule.twilightAngle,
      );
      // The first container keeps the in-session values.
      expect(
        container.read(calculationMethodProvider),
        CalculationMethod.karachi,
      );
    });
  });

  group('resolveLocationData', () {
    test('uses the bundled city for a city selection', () {
      final location = resolveLocationData(
        const CitySelection('riyadh'),
        const [riyadh],
      );

      expect(location.latitude, 24.6333);
      expect(location.longitude, 46.7167);
      expect(location.timeZoneId, 'Asia/Riyadh');
    });

    test('uses the nearest city timezone for a close GPS fix', () {
      final location = resolveLocationData(
        const CoordinatesSelection(latitude: 24.6, longitude: 46.7),
        const [riyadh],
      );

      expect(location.latitude, 24.6);
      expect(location.longitude, 46.7);
      expect(location.timeZoneId, 'Asia/Riyadh');
    });

    test('falls back to the device timezone beyond the distance limit', () {
      tz.setLocalLocation(tz.getLocation('Europe/London'));

      final location = resolveLocationData(
        const CoordinatesSelection(latitude: -90, longitude: 0),
        const [riyadh],
      );

      expect(location.timeZoneId, 'Europe/London');
    });

    test('throws for an unknown city selection', () {
      expect(
        () => resolveLocationData(
          const CitySelection('missing'),
          const [riyadh],
        ),
        throwsStateError,
      );
    });
  });
}
