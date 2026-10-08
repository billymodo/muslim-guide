import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muslim_guide/app/providers/bootstrap_provider.dart';
import 'package:muslim_guide/features/prayer/domain/models/asr_method.dart';

/// Holds the selected Asr method; defaults to Standard (DEC-0028).
final asrMethodProvider =
    NotifierProvider<AsrMethodNotifier, AsrMethod>(AsrMethodNotifier.new);

/// Updates and persists the selected Asr method.
class AsrMethodNotifier extends Notifier<AsrMethod> {
  bool _touched = false;
  bool _disposed = false;

  @override
  AsrMethod build() {
    // Re-hydrate once bootstrap makes storage available.
    ref.watch(hiveStoreProvider);
    _disposed = false;
    ref.onDispose(() => _disposed = true);
    unawaited(_restore());
    return AsrMethod.standard;
  }

  /// Selects [asrMethod] and persists it.
  ///
  /// The state updates immediately; persistence errors propagate to the
  /// caller while the in-session selection stays active.
  Future<void> setMethod(AsrMethod asrMethod) async {
    _touched = true;
    state = asrMethod;
    await ref.read(settingsRepositoryProvider).setAsrMethod(asrMethod);
  }

  Future<void> _restore() async {
    if (ref.read(hiveStoreProvider) == null) {
      // Storage is not ready before bootstrap; the rebuild triggered when
      // the store appears runs hydration again.
      return;
    }
    try {
      final saved =
          await ref.read(settingsRepositoryProvider).getAsrMethod();
      if (_touched || _disposed) return;
      state = saved;
    } on Object catch (error, stack) {
      developer.log(
        'Failed to restore the saved Asr method.',
        name: 'muslim_guide.prayer',
        error: error,
        stackTrace: stack,
      );
    }
  }
}
