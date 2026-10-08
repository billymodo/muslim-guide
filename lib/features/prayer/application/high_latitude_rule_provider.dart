import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muslim_guide/app/providers/bootstrap_provider.dart';
import 'package:muslim_guide/features/prayer/domain/models/high_latitude_rule.dart';

/// Holds the selected high-latitude rule; defaults to MiddleOfNight
/// (DEC-0028).
final highLatitudeRuleProvider =
    NotifierProvider<HighLatitudeRuleNotifier, HighLatitudeRule>(
  HighLatitudeRuleNotifier.new,
);

/// Updates and persists the selected high-latitude rule.
class HighLatitudeRuleNotifier extends Notifier<HighLatitudeRule> {
  bool _touched = false;
  bool _disposed = false;

  @override
  HighLatitudeRule build() {
    // Re-hydrate once bootstrap makes storage available.
    ref.watch(hiveStoreProvider);
    _disposed = false;
    ref.onDispose(() => _disposed = true);
    unawaited(_restore());
    return HighLatitudeRule.middleOfNight;
  }

  /// Selects [rule] and persists it.
  ///
  /// The state updates immediately; persistence errors propagate to the
  /// caller while the in-session selection stays active.
  Future<void> setRule(HighLatitudeRule rule) async {
    _touched = true;
    state = rule;
    await ref.read(settingsRepositoryProvider).setHighLatitudeRule(rule);
  }

  Future<void> _restore() async {
    if (ref.read(hiveStoreProvider) == null) {
      // Storage is not ready before bootstrap; the rebuild triggered when
      // the store appears runs hydration again.
      return;
    }
    try {
      final saved =
          await ref.read(settingsRepositoryProvider).getHighLatitudeRule();
      if (_touched || _disposed) return;
      state = saved;
    } on Object catch (error, stack) {
      developer.log(
        'Failed to restore the saved high-latitude rule.',
        name: 'muslim_guide.prayer',
        error: error,
        stackTrace: stack,
      );
    }
  }
}
