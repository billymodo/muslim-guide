import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:muslim_guide/data/storage/migrations.dart';

void main() {
  late Directory tempDirectory;

  setUp(() async {
    tempDirectory = await Directory.systemTemp.createTemp('muslim_guide_test_');
    Hive.init(tempDirectory.path);
  });

  tearDown(() async {
    await Hive.close();
    await tempDirectory.delete(recursive: true);
  });

  test('migrates a version 0 settings box to version 1', () async {
    final box = await Hive.openBox<dynamic>('settings');
    await box.put('language', 'ar');

    await runMigrations(box);

    expect(box.get('schemaVersion'), currentSettingsVersion);
    expect(box.get('language'), 'ar');
  });

  test('migrates a version 1 box to version 2 without conversion', () async {
    final box = await Hive.openBox<dynamic>('settings');
    await box.put('schemaVersion', 1);
    await box.put('language', 'en');

    await runMigrations(box);

    // v1 → v2 adds the enabled_prayer_notifications key; absence of the
    // key means all prayers stay enabled (Task 7).
    expect(box.get('schemaVersion'), 2);
    expect(box.get('schemaVersion'), currentSettingsVersion);
    expect(box.get('language'), 'en');
    expect(box.get('enabled_prayer_notifications'), isNull);
  });
}
