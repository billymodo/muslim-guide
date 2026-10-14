import 'package:muslim_guide/features/azkar/domain/azkar_category.dart';
import 'package:muslim_guide/features/azkar/domain/dhikr.dart';

/// Real-text pack additionally shipped with the app (Rule 020).
///
/// Empty categories and items mean the verified pack has not been
/// approved yet; the UI renders the pending-pack Empty state.
class AzkarPack {
  /// Creates a pack.
  const new({required this.categories, required this.items});

  /// Empty pack: no verified content approved yet (Rule 020).
  // ignore: unnecessary_type_name_in_constructor // Project const new(...) mandate (phases/06.md deviation).
  factory AzkarPack.pending() {
    return const AzkarPack(categories: <AzkarCategory>[], items: <Dhikr>[]);
  }

  /// Creates a pack from decoded JSON.
  factory fromJson(Map<String, dynamic> json) {
    final rawCategories = json['categories'];
    if (rawCategories is! List<dynamic>) {
      throw const FormatException(
        'Azkar pack field "categories" must be a list.',
      );
    }
    final categories = <AzkarCategory>[];
    for (final raw in rawCategories) {
      if (raw is! Map<String, dynamic>) {
        throw const FormatException('Each category must be a JSON object.');
      }
      final id = AzkarCategoryId.fromValue(raw['id'] as String?);
      if (id == null) {
        throw FormatException('Unknown category id: ${raw['id']}');
      }
      final total = raw['total'];
      if (total is! num || total.toInt() < 0) {
        throw FormatException('Category "${id.value}" total must be >= 0.');
      }
      categories.add(AzkarCategory(id: id, totalCount: total.toInt()));
    }

    final rawItems = json['items'];
    if (rawItems is! List<dynamic>) {
      throw const FormatException(
        'Azkar pack field "items" must be a list.',
      );
    }
    final items = <Dhikr>[];
    final ids = <String>{};
    for (final raw in rawItems) {
      if (raw is! Map<String, dynamic>) {
        throw const FormatException('Each dhikr must be a JSON object.');
      }
      final item = Dhikr.fromJson(raw);
      if (!ids.add(item.id)) {
        throw FormatException('Duplicate dhikr id "${item.id}".');
      }
      items.add(item);
    }
    return AzkarPack(
      categories: List<AzkarCategory>.unmodifiable(categories),
      items: List<Dhikr>.unmodifiable(items),
    );
  }

  /// Categories in pack order.
  final List<AzkarCategory> categories;

  /// All dhikr placeholders.
  final List<Dhikr> items;

  /// Items for [categoryId].
  List<Dhikr> itemsFor(AzkarCategoryId categoryId) {
    return items.where((item) => item.categoryId == categoryId).toList();
  }
}
