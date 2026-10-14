import 'package:muslim_guide/features/azkar/domain/azkar_category.dart';

/// A single dhikr placeholder entry (Rule 020: no real text in Phase 06).
class Dhikr {
  /// Creates a dhikr placeholder.
  const new({
    required this.id,
    required this.categoryId,
    required this.textPlaceholder,
    required this.virtuePlaceholder,
    required this.repeatCount,
    required this.sourcePlaceholder,
  });

  /// Creates a dhikr from the placeholder pack JSON.
  factory fromJson(Map<String, dynamic> json) {
    String requiredString(String key) {
      final value = json[key];
      if (value is String && value.trim().isNotEmpty) {
        return value;
      }
      throw FormatException('Dhikr field "$key" must be a non-empty string.');
    }

    int requiredCount(String key) {
      final value = json[key];
      if (value is num && value.toInt() > 0) {
        return value.toInt();
      }
      throw FormatException('Dhikr field "$key" must be a positive number.');
    }

    final rawCategory = json['category'];
    final categoryId = AzkarCategoryId.fromValue(
      rawCategory is String ? rawCategory : null,
    );
    if (categoryId == null) {
      throw FormatException('Dhikr field "category" is unknown: $rawCategory');
    }

    return Dhikr(
      id: requiredString('id'),
      categoryId: categoryId,
      textPlaceholder: requiredString('text'),
      virtuePlaceholder: requiredString('virtue'),
      repeatCount: requiredCount('repeat'),
      sourcePlaceholder: requiredString('source'),
    );
  }

  /// Stable identifier.
  final String id;

  /// Owning category.
  final AzkarCategoryId categoryId;

  /// Placeholder text (never a real religious text in Phase 06).
  final String textPlaceholder;

  /// Placeholder virtue text.
  final String virtuePlaceholder;

  /// Required repetitions.
  final int repeatCount;

  /// Placeholder source label.
  final String sourcePlaceholder;
}
