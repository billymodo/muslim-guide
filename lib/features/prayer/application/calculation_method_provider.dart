import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muslim_guide/app/providers/bootstrap_provider.dart';
import 'package:muslim_guide/features/prayer/domain/models/calculation_method.dart';

/// Holds the selected calculation method; defaults to MWL (DEC-0028).
final calculationMethodProvider =
    NotifierProvider<CalculationMethodNotifier, CalculationMethod>(
  CalculationMethodNotifier.new,
);

/// Updates and persists the selected calculation method.
class CalculationMethodNotifier extends Notifier<CalculationMethod> {
  bool _touched = false;
  bool _disposed = false;

  @override
  CalculationMethod build() {
    // Re-hydrate once bootstrap makes storage available.
    ref.watch(hiveStoreProvider);
    _disposed = false;
    ref.onDispose(() => _disposed = true);
    unawaited(_restore());
    return CalculationMethod.mwl;
  }

  /// Selects [method] and persists it.
  ///
  /// The state updates immediately; persistence errors propagate to the
  /// caller while the in-session selection stays active.
  Future<void> setMethod(CalculationMethod method) async {
    _touched = true;
    state = method;
    await ref.read(settingsRepositoryProvider).setCalculationMethod(method);
  }

  Future<void> _restore() async {
    if (ref.read(hiveStoreProvider) == null) {
      // Storage is not ready before bootstrap; the rebuild triggered when
      // the store appears runs hydration again.
      return;
    }
    try {
      final saved =
          await ref.read(settingsRepositoryProvider).getCalculationMethod();
      if (_touched || _disposed) return;
      state = saved;
    } on Object catch (error, stack) {
      developer.log(
        'Failed to restore the saved calculation method.',
        name: 'muslim_guide.prayer',
        error: error,
        stackTrace: stack,
      );
    }
  }
}
