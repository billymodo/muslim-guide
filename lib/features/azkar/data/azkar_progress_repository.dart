import 'package:muslim_guide/features/azkar/data/azkar_progress_storage.dart';
import 'package:muslim_guide/features/azkar/domain/azkar_category.dart';
import 'package:muslim_guide/features/azkar/domain/azkar_progress.dart';

/// Persists per-category daily progress as primitives in shared Hive storage.
class AzkarProgressRepository {
  /// Creates a repository over [storage].
  new({required this.storage});

  /// Underlying key-value storage.
  final AzkarProgressStorage storage;

  String _key(AzkarCategoryId id, String suffix) {
    return 'azkar_progress_${id.value}_$suffix';
  }

  /// Returns today's progress for [id], or null when nothing was completed.
  CategoryProgress? read(
    AzkarCategoryId id, {
    required int total,
    DateTime? now,
  }) {
    final today = CategoryProgress.todayKey(now ?? DateTime.now());
    final storedDate = storage.read(_key(id, 'date'));
    if (storedDate != today) return null;
    final rawCompleted = storage.read(_key(id, 'completed'));
    final completed =
        rawCompleted is int && rawCompleted > 0 ? rawCompleted : 0;
    if (completed == 0) return null;
    return CategoryProgress(
      categoryId: id,
      completed: completed > total ? total : completed,
      total: total,
      dateKey: today,
    );
  }

  /// Marks one item completed for [id] today; returns the updated progress.
  Future<CategoryProgress> completeOne(
    AzkarCategoryId id, {
    required int total,
    DateTime? now,
  }) async {
    final today = CategoryProgress.todayKey(now ?? DateTime.now());
    final storedDate = storage.read(_key(id, 'date'));
    final rawCompleted = storedDate == today
        ? storage.read(_key(id, 'completed'))
        : null;
    final previous = rawCompleted is int && rawCompleted > 0 ? rawCompleted : 0;
    final completed = (previous + 1) > total ? total : previous + 1;
    await storage.write(_key(id, 'date'), today);
    await storage.write(_key(id, 'completed'), completed);
    return CategoryProgress(
      categoryId: id,
      completed: completed,
      total: total,
      dateKey: today,
    );
  }

  /// Resets today's progress for [id].
  Future<void> reset(AzkarCategoryId id) async {
    await storage.write(_key(id, 'completed'), null);
  }
}
