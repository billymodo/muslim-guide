import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_guide/features/azkar/application/azkar_providers.dart';
import 'package:muslim_guide/features/azkar/data/azkar_progress_repository.dart';
import 'package:muslim_guide/features/azkar/data/azkar_progress_storage.dart';
import 'package:muslim_guide/features/azkar/domain/azkar_category.dart';
import 'package:muslim_guide/features/azkar/domain/azkar_pack.dart';
import 'package:muslim_guide/features/azkar/domain/dhikr.dart';

AzkarPack stubPack() {
  Dhikr item(String id, AzkarCategoryId category) {
    return Dhikr(
      id: id,
      categoryId: category,
      textPlaceholder: '[PLACEHOLDER-DHIKR-$id]',
      virtuePlaceholder: '[PLACEHOLDER-VIRTUE-$id]',
      repeatCount: 1,
      sourcePlaceholder: '[PLACEHOLDER-SOURCE]',
    );
  }

  return AzkarPack(
    categories: const [
      AzkarCategory(id: AzkarCategoryId.morning, totalCount: 2),
      AzkarCategory(id: AzkarCategoryId.evening, totalCount: 1),
    ],
    items: [
      item('morning-01', AzkarCategoryId.morning),
      item('morning-02', AzkarCategoryId.morning),
      item('evening-01', AzkarCategoryId.evening),
    ],
  );
}

void main() {
  group('todayAzkarProvider', () {
    test('reads null then advances after completeOne', () async {
      final container = ProviderContainer(
        overrides: [
          azkarLibraryProvider.overrideWith(
            () => _StubLibrary(stubPack()),
          ),
          azkarProgressRepositoryProvider.overrideWithValue(
            AzkarProgressRepository(
              storage: MemoryAzkarProgressStorage(),
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      final before = await container.read(
        todayAzkarProvider(AzkarCategoryId.morning).future,
      );
      expect(before, isNull);

      final notifier = container.read(
        todayAzkarProvider(AzkarCategoryId.morning).notifier,
      );
      final updated = await notifier.completeOne();
      expect(updated.completed, 1);
      expect(updated.total, 2);
    });
  });

  group('azkarCounterProvider', () {
    test('increments and resets', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      expect(container.read(azkarCounterProvider), 0);
      container.read(azkarCounterProvider.notifier).increment();
      expect(container.read(azkarCounterProvider), 1);
      container.read(azkarCounterProvider.notifier).reset();
      expect(container.read(azkarCounterProvider), 0);
    });
  });
}

/// Stub library notifier returning [pack] immediately.
class _StubLibrary extends AzkarLibraryNotifier {
  /// Creates a stub.
  new(this.pack);

  /// Pack to return.
  final AzkarPack? pack;

  @override
  Future<AzkarPack?> build() async => pack;
}
