import 'package:muslim_guide/features/azkar/domain/azkar_category.dart';

/// Daily progress for one category (stored primitives only, no TypeAdapter).
class CategoryProgress {
  /// Creates progress.
  const new({
    required this.categoryId,
    required this.completed,
    required this.total,
    required this.dateKey,
  });

  /// Owning category.
  final AzkarCategoryId categoryId;

  /// Completed items today.
  final int completed;

  /// Total items in the category.
  final int total;

  /// `yyyy-mm-dd` day key (local).
  final String dateKey;

  /// Completion fraction clamped to 0..1.
  double get fraction {
    if (total <= 0) return 0;
    final value = completed / total;
    if (value < 0) return 0;
    if (value > 1) return 1;
    return value;
  }

  /// Day key for [date] in local time (`yyyy-mm-dd`).
  static String todayKey(DateTime date) {
    final local = date.toLocal();
    final month = local.month.toString().padLeft(2, '0');
    final day = local.day.toString().padLeft(2, '0');
    return '${local.year}-$month-$day';
  }
}
