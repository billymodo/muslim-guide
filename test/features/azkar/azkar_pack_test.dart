import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_guide/features/azkar/domain/azkar_category.dart';
import 'package:muslim_guide/features/azkar/domain/azkar_pack.dart';

void main() {
  Map<String, dynamic> validPack() {
    return {
      'categories': [
        {'id': 'morning', 'total': 2},
        {'id': 'evening', 'total': 1},
      ],
      'items': [
        {
          'id': 'morning-01',
          'category': 'morning',
          'text': '[PLACEHOLDER-DHIKR-morning-01]',
          'virtue': '[PLACEHOLDER-VIRTUE-morning-01]',
          'repeat': 1,
          'source': '[PLACEHOLDER-SOURCE]',
        },
        {
          'id': 'morning-02',
          'category': 'morning',
          'text': '[PLACEHOLDER-DHIKR-morning-02]',
          'virtue': '[PLACEHOLDER-VIRTUE-morning-02]',
          'repeat': 3,
          'source': '[PLACEHOLDER-SOURCE]',
        },
        {
          'id': 'evening-01',
          'category': 'evening',
          'text': '[PLACEHOLDER-DHIKR-evening-01]',
          'virtue': '[PLACEHOLDER-VIRTUE-evening-01]',
          'repeat': 1,
          'source': '[PLACEHOLDER-SOURCE]',
        },
      ],
    };
  }

  group('AzkarPack.fromJson', () {
    test('parses categories and items', () {
      final pack = AzkarPack.fromJson(validPack());
      expect(pack.categories, hasLength(2));
      expect(pack.items, hasLength(3));
      expect(
        pack.itemsFor(AzkarCategoryId.morning),
        hasLength(2),
      );
    });

    test('itemsFor returns only the requested category', () {
      final pack = AzkarPack.fromJson(validPack());
      final evening = pack.itemsFor(AzkarCategoryId.evening);
      expect(evening, hasLength(1));
      expect(evening.single.id, 'evening-01');
    });

    test('throws on duplicate dhikr ids', () {
      final raw = validPack();
      final items = List<Map<String, dynamic>>.from(
        raw['items']! as List<dynamic>,
      );
      items.add(Map<String, dynamic>.from(items.first));
      raw['items'] = items;
      expect(() => AzkarPack.fromJson(raw), throwsFormatException);
    });

    test('throws on unknown category id', () {
      final raw = validPack();
      raw['categories'] = [
        {'id': 'noon', 'total': 1},
      ];
      expect(() => AzkarPack.fromJson(raw), throwsFormatException);
    });

    test('throws when categories is not a list', () {
      final raw = validPack();
      raw['categories'] = {'id': 'morning'};
      expect(() => AzkarPack.fromJson(raw), throwsFormatException);
    });

    test('throws when items is not a list', () {
      final raw = validPack();
      raw['items'] = {'id': 'morning-01'};
      expect(() => AzkarPack.fromJson(raw), throwsFormatException);
    });

    test('throws on unknown dhikr category', () {
      final raw = validPack();
      final items = List<Map<String, dynamic>>.from(
        raw['items']! as List<dynamic>,
      );
      items[0] = Map<String, dynamic>.from(items[0])..['category'] = 'noon';
      raw['items'] = items;
      expect(() => AzkarPack.fromJson(raw), throwsFormatException);
    });

    test('throws on non-positive repeat count', () {
      final raw = validPack();
      final items = List<Map<String, dynamic>>.from(
        raw['items']! as List<dynamic>,
      );
      items[0] = Map<String, dynamic>.from(items[0])..['repeat'] = 0;
      raw['items'] = items;
      expect(() => AzkarPack.fromJson(raw), throwsFormatException);
    });
  });
}
