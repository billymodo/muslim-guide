import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muslim_guide/core/logging/local_error_log.dart';
import 'package:muslim_guide/data/settings/settings_repository.dart';
import 'package:muslim_guide/data/storage/hive_store.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// Holds the initialized Hive store for application providers.
final hiveStoreProvider = StateProvider<HiveStore?>((ref) => null);

/// Provides settings backed by the initialized Hive store.
final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  final store = ref.watch(hiveStoreProvider);
  if (store == null) {
    throw StateError('Settings are unavailable before app initialization.');
  }
  return SettingsRepository(store.settingsBox);
});

/// The currently selected application language.
final appLocaleProvider = StateProvider<Locale>(
  (ref) => const Locale('ar'),
);

/// Initializes local storage, logging, and timezone data.
final bootstrapProvider = AsyncNotifierProvider<Bootstrap, void>(Bootstrap.new);

/// Performs one-time application initialization.
class Bootstrap extends AsyncNotifier<void> {
  @override
  Future<void> build() async {
    final store = HiveStore();
    await store.init();
    tz_data.initializeTimeZones();
    // TODO(phase-02): replace with flutter_timezone (OD-0025).
    tz.setLocalLocation(tz.getLocation('Asia/Riyadh'));
    await LocalErrorLog.instance.init();

    ref.read(hiveStoreProvider.notifier).state = store;
    final settings = SettingsRepository(store.settingsBox);
    final language = await settings.getLanguage();
    ref.read(appLocaleProvider.notifier).state = Locale(language);
  }
}
