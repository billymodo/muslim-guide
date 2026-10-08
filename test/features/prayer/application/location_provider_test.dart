import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:muslim_guide/app/providers/bootstrap_provider.dart';
import 'package:muslim_guide/data/settings/settings_repository.dart';
import 'package:muslim_guide/data/storage/hive_store.dart';
import 'package:muslim_guide/features/prayer/application/location_provider.dart';

void main() {
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
    tempDirectory = await Directory.systemTemp.createTemp('location_provider_');
    Hive.init(tempDirectory.path);
    box = await Hive.openBox<dynamic>('settings');
  });

  tearDown(() async {
    await Hive.close();
    await tempDirectory.delete(recursive: true);
  });

  test('starts with no selection when storage is empty', () async {
    final container = createContainer();

    expect(container.read(locationProvider), isNull);
    await pumpEventQueue();
    expect(container.read(locationProvider), isNull);
  });

  test('stays empty before storage is ready', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(locationProvider), isNull);
    await pumpEventQueue();
    expect(container.read(locationProvider), isNull);
  });

  test('selectCity updates state and persists the city ID', () async {
    final container = createContainer();

    await container.read(locationProvider.notifier).selectCity('mecca');

    expect(container.read(locationProvider), const CitySelection('mecca'));
    expect(await box.get('selected_city_id'), 'mecca');
  });

  test('selectCoordinates updates state and persists coordinates', () async {
    final container = createContainer();

    await container
        .read(locationProvider.notifier)
        .selectCoordinates(latitude: 24.7136, longitude: 46.6753);

    expect(
      container.read(locationProvider),
      const CoordinatesSelection(latitude: 24.7136, longitude: 46.6753),
    );
    expect(await box.get('selected_coordinates'), '24.7136,46.6753');
  });

  test('clear removes the selection and the stored values', () async {
    final container = createContainer();
    final notifier = container.read(locationProvider.notifier);
    await notifier.selectCity('cairo');

    await notifier.clear();

    expect(container.read(locationProvider), isNull);
    expect(await box.get('selected_city_id'), isNull);
    expect(await box.get('selected_coordinates'), isNull);
  });

  test('restores a persisted city selection after hydration', () async {
    await box.put('selected_city_id', 'cairo');
    final container = createContainer();

    expect(container.read(locationProvider), isNull);
    await pumpEventQueue();

    expect(container.read(locationProvider), const CitySelection('cairo'));
  });

  test('restores persisted coordinates after hydration', () async {
    await box.put('selected_coordinates', '41.0082,28.9784');
    final container = createContainer();

    expect(container.read(locationProvider), isNull);
    await pumpEventQueue();

    expect(
      container.read(locationProvider),
      const CoordinatesSelection(latitude: 41.0082, longitude: 28.9784),
    );
  });

  test('a persisted city ID wins over stored coordinates', () async {
    await box.put('selected_city_id', 'istanbul');
    await box.put('selected_coordinates', '41.0082,28.9784');
    final container = createContainer();

    expect(container.read(locationProvider), isNull);
    await pumpEventQueue();

    expect(container.read(locationProvider), const CitySelection('istanbul'));
  });
}
