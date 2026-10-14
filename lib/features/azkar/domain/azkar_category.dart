/// Azkar category identifiers supported by Phase 06 (placeholders only).
enum AzkarCategoryId {
  /// Morning adhkar.
  morning('morning'),

  /// Evening adhkar.
  evening('evening'),

  /// Sleep adhkar.
  sleep('sleep'),

  /// Wake-up adhkar.
  wakeUp('wake_up'),

  /// General tasbih counter.
  tasbih('tasbih');

  /// Creates a category id.
  /// Explicit const form required for value-carrying entries (file errors
  /// without it); the two lints contradict the project `const new(...)`
  /// mandate here, so both are suppressed with justification.
  // ignore: unnecessary_const_in_enum_constructor, unnecessary_type_name_in_constructor // Explicit const form required for value-carrying entries; lints contradict the project const new(...) mandate (phases/02.md, phases/06.md deviation).
  const AzkarCategoryId(this.value);

  /// Stable JSON value.
  final String value;

  /// Resolves [value] to a category, or null when unknown.
  static AzkarCategoryId? fromValue(String? value) {
    for (final id in values) {
      if (id.value == value) return id;
    }
    return null;
  }
}

/// A single category entry in the placeholder pack.
class AzkarCategory {
  /// Creates a category.
  const new({required this.id, required this.totalCount});

  /// Category identifier.
  final AzkarCategoryId id;

  /// Total items in this category (placeholder counts).
  final int totalCount;
}
