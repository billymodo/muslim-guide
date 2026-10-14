import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_guide/features/azkar/data/azkar_pack_loader.dart';
import 'package:muslim_guide/features/azkar/data/azkar_progress_storage.dart';
import 'package:muslim_guide/features/azkar/domain/azkar_category.dart';
import 'package:muslim_guide/features/azkar/domain/azkar_pack.dart';

/// Test-only bundle serving [payload] (fixtures never ship — CI-017).
class _FixtureBundle extends CachingAssetBundle {
  /// Creates a fixture bundle.
  new(this.payload);

  /// Fixture JSON payload.
  final String payload;

  @override
  Future<ByteData> load(String key) async {
    return ByteData.sublistView(utf8.encode(payload));
  }

  @override
  Future<String> loadString(String key, {bool cache = true}) async {
    return payload;
  }
}

void main() {
  group('azkar loader (Rule 020, CI-017)', () {
    test('returns null when the asset is absent', () async {
      final loader = AzkarPackLoader(
        assetBundle: _MissingBundle(),
      );
      expect(await loader.load(), isNull);
    });

    test('returns null for placeholder-shaped fixture text', () async {
      final fixture = await File(
        'test/fixtures/azkar_pack_sample.json',
      ).readAsString();
      final loader = AzkarPackLoader(
        assetBundle: _FixtureBundle(fixture),
      );
      expect(await loader.load(), isNull);
    });

    test('loads real-text packs when approved content ships', () async {
      final json = jsonEncode({
        'categories': [
          {'id': 'morning', 'total': 1},
        ],
        'items': [
          {
            'id': 'morning-01',
            'category': 'morning',
            'text': 'real-approved-text',
            'virtue': 'real-approved-virtue',
            'repeat': 1,
            'source': 'real-approved-source',
          },
        ],
      });
      final loader = AzkarPackLoader(
        assetBundle: _FixtureBundle(json),
      );
      final pack = await loader.load();
      expect(pack, isNotNull);
      expect(
        pack!.itemsFor(AzkarCategoryId.morning),
        hasLength(1),
      );
    });

    test('returns null for malformed JSON', () async {
      final loader = AzkarPackLoader(
        assetBundle: _FixtureBundle('not-json'),
      );
      expect(await loader.load(), isNull);
    });

    test('AzkarPack.pending is empty', () {
      final pack = AzkarPack.pending();
      expect(pack.categories, isEmpty);
      expect(pack.items, isEmpty);
    });

    test('memory storage round-trips primitives', () async {
      final storage = MemoryAzkarProgressStorage();
      await storage.write('k', 'v');
      expect(storage.read('k'), 'v');
      await storage.write('k', null);
      expect(storage.read('k'), isNull);
    });
  });
}

/// Bundle that always misses (simulates unshipped pack asset).
class _MissingBundle extends CachingAssetBundle {
  @override
  Future<ByteData> load(String key) {
    throw StateError('asset absent');
  }

  @override
  Future<String> loadString(String key, {bool cache = true}) {
    throw StateError('asset absent');
  }
}
