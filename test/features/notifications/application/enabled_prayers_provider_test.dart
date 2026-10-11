import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_guide/app/providers/bootstrap_provider.dart';
import 'package:muslim_guide/data/settings/settings_repository.dart';
import 'package:muslim_guide/data/storage/hive_store.dart';
import 'package:muslim_guide/features/notifications/application/enabled_prayers_provider.dart';
import 'package:muslim_guide/features/notifications/domain/prayer_notification.dart';

class _FakeSettingsRepository extends SettingsRepository {
  new() : super(null);

  Set<PrayerNotification> stored = PrayerNotification.values.toSet();
  int saveCalls = 0;

  @override
  Future<Set<PrayerNotification>> getEnabledPrayerNotifications() async =>
      stored;

  @override
  Future<void> setEnabledPrayerNotifications(
    Set<PrayerNotification> prayers,
  ) async {
    saveCalls++;
    stored = Set.of(prayers);
  }
}

void main() {
  test('defaults to all five prayers enabled', () {
    final repository = _FakeSettingsRepository();
    final container = ProviderContainer(
      overrides: [settingsRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);

    expect(
      container.read(enabledPrayersProvider),
      PrayerNotification.values.toSet(),
    );
  });

  test('togglePrayer disables and re-enables with persistence', () async {
    final repository = _FakeSettingsRepository();
    final container = ProviderContainer(
      overrides: [settingsRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);
    final notifier = container.read(enabledPrayersProvider.notifier);

    await notifier.togglePrayer(PrayerNotification.fajr);
    expect(
      container.read(enabledPrayersProvider),
      PrayerNotification.values.toSet()..remove(PrayerNotification.fajr),
    );
    expect(repository.saveCalls, 1);
    expect(repository.stored, isNot(contains(PrayerNotification.fajr)));

    await notifier.togglePrayer(PrayerNotification.fajr);
    expect(
      container.read(enabledPrayersProvider),
      PrayerNotification.values.toSet(),
    );
    expect(repository.saveCalls, 2);
  });

  test('setPrayerEnabled sets explicit values', () async {
    final repository = _FakeSettingsRepository();
    final container = ProviderContainer(
      overrides: [settingsRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);
    final notifier = container.read(enabledPrayersProvider.notifier);

    await notifier.setPrayerEnabled(PrayerNotification.isha, false);
    expect(
      container.read(enabledPrayersProvider).contains(PrayerNotification.isha),
      isFalse,
    );

    // Disabling an already-disabled prayer is idempotent in state.
    await notifier.setPrayerEnabled(PrayerNotification.isha, false);
    expect(
      container.read(enabledPrayersProvider).contains(PrayerNotification.isha),
      isFalse,
    );

    await notifier.setPrayerEnabled(PrayerNotification.isha, true);
    expect(
      container.read(enabledPrayersProvider).contains(PrayerNotification.isha),
      isTrue,
    );
  });

  test('supports all prayers disabled', () async {
    final repository = _FakeSettingsRepository();
    final container = ProviderContainer(
      overrides: [settingsRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);
    final notifier = container.read(enabledPrayersProvider.notifier);

    for (final prayer in PrayerNotification.values) {
      await notifier.setPrayerEnabled(prayer, false);
    }
    expect(container.read(enabledPrayersProvider), isEmpty);
    expect(repository.stored, isEmpty);
  });

  test('restores the persisted set once storage is available', () async {
    final repository = _FakeSettingsRepository()
      ..stored = {PrayerNotification.dhuhr, PrayerNotification.asr};
    final container = ProviderContainer(
      overrides: [
        // A non-null (uninitialized) store passes the bootstrap gate so
        // _restore() runs against the fake repository.
        hiveStoreProvider.overrideWith((ref) => HiveStore()),
        settingsRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);

    container.read(enabledPrayersProvider);
    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);

    expect(
      container.read(enabledPrayersProvider),
      {PrayerNotification.dhuhr, PrayerNotification.asr},
    );
  });
}
