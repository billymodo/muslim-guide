import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muslim_guide/app/providers/bootstrap_provider.dart';
import 'package:muslim_guide/features/notifications/domain/prayer_notification.dart';

/// Holds the prayers with notifications enabled; defaults to all five
/// (SETTING-006, Task 7).
final enabledPrayersProvider =
    NotifierProvider<EnabledPrayersNotifier, Set<PrayerNotification>>(
  EnabledPrayersNotifier.new,
);

/// Updates and persists the enabled-prayer set.
class EnabledPrayersNotifier extends Notifier<Set<PrayerNotification>> {
  bool _touched = false;
  bool _disposed = false;

  @override
  Set<PrayerNotification> build() {
    // Re-hydrate once bootstrap makes storage available.
    ref.watch(hiveStoreProvider);
    _disposed = false;
    ref.onDispose(() => _disposed = true);
    unawaited(_restore());
    return PrayerNotification.values.toSet();
  }

  /// Enables or disables notifications for [prayer] and persists the set.
  ///
  /// The state updates immediately; persistence errors propagate to the
  /// caller while the in-session selection stays active.
  // ignore: avoid_positional_boolean_parameters // Matches SettingsRepository bool setter API.
  Future<void> setPrayerEnabled(PrayerNotification prayer, bool enabled) async {
    _touched = true;
    final updated = Set<PrayerNotification>.of(state);
    if (enabled) {
      updated.add(prayer);
    } else {
      updated.remove(prayer);
    }
    state = updated;
    await ref
        .read(settingsRepositoryProvider)
        .setEnabledPrayerNotifications(updated);
  }

  /// Toggles notifications for [prayer] and persists the set.
  Future<void> togglePrayer(PrayerNotification prayer) {
    return setPrayerEnabled(prayer, !state.contains(prayer));
  }

  Future<void> _restore() async {
    if (ref.read(hiveStoreProvider) == null) {
      // Storage is not ready before bootstrap; the rebuild triggered when
      // the store appears runs hydration again.
      return;
    }
    try {
      final saved = await ref
          .read(settingsRepositoryProvider)
          .getEnabledPrayerNotifications();
      if (_touched || _disposed) return;
      state = saved;
    } on Object catch (error, stack) {
      developer.log(
        'Failed to restore the enabled prayers.',
        name: 'muslim_guide.notifications',
        error: error,
        stackTrace: stack,
      );
    }
  }
}
