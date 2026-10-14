import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_guide/features/azkar/data/azkar_progress_repository.dart';
import 'package:muslim_guide/features/azkar/data/azkar_progress_storage.dart';
import 'package:muslim_guide/features/azkar/domain/azkar_category.dart';

void main() {
  AzkarProgressRepository repository([
    Map<String, Object?>? seed,
  ]) {
    return AzkarProgressRepository(
      storage: MemoryAzkarProgressStorage(seed),
    );
  }

  group('AzkarProgressRepository', () {
    test('returns null when nothing completed', () {
      final repo = repository();
      expect(
        repo.read(AzkarCategoryId.morning, total: 2),
        isNull,
      );
    });

    test('completeOne stores completed count for today', () async {
      final repo = repository();
      final updated = await repo.completeOne(
        AzkarCategoryId.morning,
        total: 2,
      );
      expect(updated.completed, 1);
      expect(updated.total, 2);
      expect(
        repo.read(AzkarCategoryId.morning, total: 2)?.completed,
        1,
      );
    });

    test('completeOne clamps at total', () async {
      final repo = repository();
      await repo.completeOne(AzkarCategoryId.morning, total: 1);
      final second = await repo.completeOne(
        AzkarCategoryId.morning,
        total: 1,
      );
      expect(second.completed, 1);
    });

    test('progress resets on a new day', () async {
      final repo = repository();
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      await repo.completeOne(
        AzkarCategoryId.evening,
        total: 2,
        now: yesterday,
      );
      expect(
        repo.read(AzkarCategoryId.evening, total: 2),
        isNull,
      );
    });

    test('reset clears today progress', () async {
      final repo = repository();
      await repo.completeOne(AzkarCategoryId.sleep, total: 1);
      await repo.reset(AzkarCategoryId.sleep);
      expect(
        repo.read(AzkarCategoryId.sleep, total: 1),
        isNull,
      );
    });

    test('fraction clamps to 0..1', () async {
      final repo = repository();
      final updated = await repo.completeOne(
        AzkarCategoryId.tasbih,
        total: 1,
      );
      expect(updated.fraction, 1.0);
    });
  });
}
