import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:muslim_guide/data/settings/settings_repository.dart';
import 'package:muslim_guide/features/notifications/domain/prayer_notification.dart';
import 'package:muslim_guide/features/prayer/domain/models/asr_method.dart';
import 'package:muslim_guide/features/prayer/domain/models/calculation_method.dart';
import 'package:muslim_guide/features/prayer/domain/models/high_latitude_rule.dart';

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

  test('persists and clears the selected city ID', () async {
    final box = await Hive.openBox<dynamic>('settings');
    final repository = SettingsRepository(box);

    expect(await repository.getSelectedCityId(), isNull);

    await repository.setSelectedCityId('makkah');
    expect(await repository.getSelectedCityId(), 'makkah');

    await repository.setSelectedCityId(null);
    expect(await repository.getSelectedCityId(), isNull);

    await expectLater(
      repository.setSelectedCityId('   '),
      throwsArgumentError,
    );
    await box.put('selected_city_id', 42);
    await expectLater(repository.getSelectedCityId(), throwsFormatException);
  });

  test('persists and clears selected coordinates', () async {
    final box = await Hive.openBox<dynamic>('settings');
    final repository = SettingsRepository(box);

    expect(await repository.getSelectedCoordinates(), isNull);

    await repository.setSelectedCoordinates(21.4225, 39.8262);
    expect(await repository.getSelectedCoordinates(), (21.4225, 39.8262));

    await repository.setSelectedCoordinates(null, null);
    expect(await repository.getSelectedCoordinates(), isNull);

    await expectLater(
      repository.setSelectedCoordinates(21.4225, null),
      throwsArgumentError,
    );
    await expectLater(
      repository.setSelectedCoordinates(-91, 0),
      throwsArgumentError,
    );
    await expectLater(
      repository.setSelectedCoordinates(0, 181),
      throwsArgumentError,
    );
    await box.put('selected_coordinates', 'abc');
    await expectLater(
      repository.getSelectedCoordinates(),
      throwsFormatException,
    );
    await box.put('selected_coordinates', '91,0');
    await expectLater(
      repository.getSelectedCoordinates(),
      throwsFormatException,
    );
  });

  test('reads DEC-0028 defaults and persists prayer settings', () async {
    final box = await Hive.openBox<dynamic>('settings');
    final repository = SettingsRepository(box);

    expect(await repository.getCalculationMethod(), CalculationMethod.mwl);
    expect(await repository.getAsrMethod(), AsrMethod.standard);
    expect(
      await repository.getHighLatitudeRule(),
      HighLatitudeRule.middleOfNight,
    );

    await repository.setCalculationMethod(CalculationMethod.ummAlQura);
    await repository.setAsrMethod(AsrMethod.hanafi);
    await repository.setHighLatitudeRule(HighLatitudeRule.seventhOfNight);

    expect(
      await repository.getCalculationMethod(),
      CalculationMethod.ummAlQura,
    );
    expect(await repository.getAsrMethod(), AsrMethod.hanafi);
    expect(
      await repository.getHighLatitudeRule(),
      HighLatitudeRule.seventhOfNight,
    );

    await box.put('calculation_method', 'unknownMethod');
    await expectLater(
      repository.getCalculationMethod(),
      throwsFormatException,
    );
    await box.put('asr_method', 7);
    await expectLater(repository.getAsrMethod(), throwsFormatException);
    await box.put('high_latitude_rule', 'nope');
    await expectLater(
      repository.getHighLatitudeRule(),
      throwsFormatException,
    );
  });

  test(
    'defaults to all prayers enabled and persists the enabled set',
    () async {
    final box = await Hive.openBox<dynamic>('settings');
    final repository = SettingsRepository(box);

    expect(
      await repository.getEnabledPrayerNotifications(),
      PrayerNotification.values.toSet(),
    );

    await repository.setEnabledPrayerNotifications({
      PrayerNotification.fajr,
      PrayerNotification.isha,
    });
    expect(
      await repository.getEnabledPrayerNotifications(),
      {PrayerNotification.fajr, PrayerNotification.isha},
    );

    await repository.setEnabledPrayerNotifications({});
    expect(await repository.getEnabledPrayerNotifications(), isEmpty);
  });

  test('ignores unknown stored prayer names and rejects wrong types', () async {
    final box = await Hive.openBox<dynamic>('settings');
    final repository = SettingsRepository(box);

    await box.put('enabled_prayer_notifications', ['fajr', 'bong', 'isha']);
    expect(
      await repository.getEnabledPrayerNotifications(),
      {PrayerNotification.fajr, PrayerNotification.isha},
    );

    await box.put('enabled_prayer_notifications', 'fajr');
    await expectLater(
      repository.getEnabledPrayerNotifications(),
      throwsFormatException,
    );

    await box.put('enabled_prayer_notifications', ['fajr', 42]);
    await expectLater(
      repository.getEnabledPrayerNotifications(),
      throwsFormatException,
    );
  });
}
