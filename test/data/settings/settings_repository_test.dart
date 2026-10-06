import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:muslim_guide/data/settings/settings_repository.dart';

void main() {
  late Directory tempDirectory;

  setUp(() async {
    tempDirectory = await Directory.systemTemp.createTemp('settings_test_');
    Hive.init(tempDirectory.path);
  });

  tearDown(() async {
    await Hive.close();
    await tempDirectory.delete(recursive: true);
  });

  test('reads defaults and persists validated settings', () async {
    final box = await Hive.openBox<dynamic>('settings');
    final repository = SettingsRepository(box);

    expect(await repository.getLanguage(), 'ar');
    expect(await repository.isOnboardingCompleted(), isFalse);
    expect(await repository.getTheme(), 'system');

    await repository.setLanguage('en');
    await repository.setOnboardingCompleted(true);
    await repository.setTheme('dark');

    expect(await repository.getLanguage(), 'en');
    expect(await repository.isOnboardingCompleted(), isTrue);
    expect(await repository.getTheme(), 'dark');
    await expectLater(repository.setLanguage('fr'), throwsArgumentError);

    await box.put('language', true);
    await expectLater(repository.getLanguage(), throwsFormatException);
  });
}
