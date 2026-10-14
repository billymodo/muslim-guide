import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muslim_guide/app/providers/bootstrap_provider.dart';
import 'package:muslim_guide/features/azkar/data/azkar_pack_loader.dart';
import 'package:muslim_guide/features/azkar/data/azkar_progress_repository.dart';
import 'package:muslim_guide/features/azkar/data/azkar_progress_storage.dart';
import 'package:muslim_guide/features/azkar/domain/azkar_category.dart';
import 'package:muslim_guide/features/azkar/domain/azkar_pack.dart';
import 'package:muslim_guide/features/azkar/domain/azkar_progress.dart';

/// Provides the pack loader backed by the root asset bundle.
final azkarPackLoaderProvider = Provider<AzkarPackLoader>(
  (ref) => AzkarPackLoader(assetBundle: rootBundle),
);

/// Real-text pack when shipped, null while pending approval (Rule 020).
///
/// keepAlive: static bundled library (or its absence).
final AsyncNotifierProvider<AzkarLibraryNotifier, AzkarPack?>
    azkarLibraryProvider =
    AsyncNotifierProvider<AzkarLibraryNotifier, AzkarPack?>(
  AzkarLibraryNotifier.new,
);

/// Loads the bundled pack once (null while the verified pack is pending).
class AzkarLibraryNotifier extends AsyncNotifier<AzkarPack?> {
  @override
  Future<AzkarPack?> build() {
    ref.keepAlive();
    return ref.watch(azkarPackLoaderProvider).load();
  }
}

/// Progress storage over the shared settings box (null before bootstrap).
final azkarProgressStorageProvider = Provider<AzkarProgressStorage>((ref) {
  return HiveAzkarProgressStorage(ref.watch(hiveStoreProvider)?.settingsBox);
});

/// Progress repository over [azkarProgressStorageProvider].
final Provider<AzkarProgressRepository> azkarProgressRepositoryProvider =
    Provider<AzkarProgressRepository>(
  (ref) => AzkarProgressRepository(
    storage: ref.watch(azkarProgressStorageProvider),
  ),
);

/// Today's per-category progress (autoDispose: refreshed on entry).
final AutoDisposeAsyncNotifierProviderFamily<TodayAzkarNotifier,
        CategoryProgress?, AzkarCategoryId> todayAzkarProvider =
    AsyncNotifierProvider.autoDispose
        .family<TodayAzkarNotifier, CategoryProgress?, AzkarCategoryId>(
  TodayAzkarNotifier.new,
);

/// Reads and advances today's progress for one category.
class TodayAzkarNotifier
    extends AutoDisposeFamilyAsyncNotifier<CategoryProgress?,
        AzkarCategoryId> {
  @override
  Future<CategoryProgress?> build(AzkarCategoryId arg) async {
    final pack = await ref.watch(azkarLibraryProvider.future);
    final total = pack?.itemsFor(arg).length ?? 0;
    return ref.watch(azkarProgressRepositoryProvider).read(arg, total: total);
  }

  /// Marks one item completed and refreshes state.
  Future<CategoryProgress> completeOne() async {
    final pack = await ref.read(azkarLibraryProvider.future);
    final total = pack?.itemsFor(arg).length ?? 0;
    final updated = await ref
        .read(azkarProgressRepositoryProvider)
        .completeOne(arg, total: total);
    state = AsyncData(updated);
    return updated;
  }
}

/// Session counter for the on-screen tasbih (autoDispose).
final AutoDisposeNotifierProvider<AzkarCounterNotifier, int>
azkarCounterProvider =
    NotifierProvider.autoDispose<AzkarCounterNotifier, int>(
  AzkarCounterNotifier.new,
);

/// Simple increment/reset counter for the visible dhikr card.
class AzkarCounterNotifier extends AutoDisposeNotifier<int> {
  @override
  int build() => 0;

  /// Increments by one.
  void increment() => state = state + 1;

  /// Resets to zero.
  void reset() => state = 0;
}
