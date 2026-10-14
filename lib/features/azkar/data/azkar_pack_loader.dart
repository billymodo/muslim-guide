import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:muslim_guide/features/azkar/domain/azkar_pack.dart';

/// Loads the bundled real-text azkar pack and caches the result.
///
/// Returns null when `assets/data/azkar_pack.json` is absent or invalid:
/// the verified pack has not been approved yet (Rule 020, GAP pending).
/// The UI renders the pending-pack Empty state in that case.
class AzkarPackLoader {
  /// Creates a loader for the supplied asset bundle.
  new({
    required this.assetBundle,
    this.assetPath = 'assets/data/azkar_pack.json',
  });

  /// Bundled JSON path.
  final String assetPath;

  /// Asset bundle used to load the JSON file.
  final AssetBundle assetBundle;

  Future<AzkarPack?>? _pack;

  /// Returns the pack, or null when it is not shipped yet.
  Future<AzkarPack?> load() {
    return _pack ??= _load();
  }

  Future<AzkarPack?> _load() async {
    try {
      final raw = await assetBundle.loadString(assetPath);
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) {
        return null;
      }
      final pack = AzkarPack.fromJson(decoded);
      if (pack.items.any((item) => !_isRealText(item.textPlaceholder))) {
        return null;
      }
      return pack;
    } on Object {
      return null;
    }
  }

  /// Rejects placeholder-shaped text so dev fixtures can never ship.
  bool _isRealText(String text) {
    final trimmed = text.trim();
    return trimmed.isNotEmpty && !trimmed.startsWith('[PLACEHOLDER-');
  }
}
