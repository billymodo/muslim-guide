import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
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
    await LocalErrorLog.instance.init();
    // DEC-0029 / OD-0025 — CR-0010: device timezone, safe fallback.
    await setLocalTimezone();

    ref.read(hiveStoreProvider.notifier).state = store;
    final settings = SettingsRepository(store.settingsBox);
    final language = await settings.getLanguage();
    ref.read(appLocaleProvider.notifier).state = Locale(language);
  }
}

/// Fallback device timezone used when the platform lookup fails
/// (DEC-0029 — Asia/Riyadh with a local warning, per OD-0025).
const String _fallbackTimezone = 'Asia/Riyadh';

/// Sets `tz.local` from the device's IANA timezone identifier (DEC-0029,
/// CR-0010 `flutter_timezone`).
///
/// [getLocalTimezone] and [errorLog] exist so tests can inject fakes.
/// Any failure — platform error or an identifier unknown to the tz
/// database — falls back to [_fallbackTimezone] and records a `warning`
/// in the local error log (DEC-0025). The lookup must never break
/// bootstrap.
Future<void> setLocalTimezone({
  Future<TimezoneInfo> Function()? getLocalTimezone,
  LocalErrorLog? errorLog,
}) async {
  final lookup = getLocalTimezone ?? FlutterTimezone.getLocalTimezone;
  try {
    final info = await lookup();
    tz.setLocalLocation(tz.getLocation(info.identifier));
  } on Object catch (error, stack) {
    developer.log(
      'Timezone lookup failed; using $_fallbackTimezone.',
      name: 'muslim_guide.bootstrap',
      error: error,
      stackTrace: stack,
    );
    try {
      await (errorLog ?? LocalErrorLog.instance).log(
        level: 'warning',
        message: 'Timezone lookup failed; using $_fallbackTimezone.',
        stack: stack,
        context: {'error': error.toString()},
      );
    } on Object {
      // The local log must never break bootstrap (DEC-0025).
    }
    tz.setLocalLocation(tz.getLocation(_fallbackTimezone));
  }
}
