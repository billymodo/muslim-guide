import 'package:hive_ce/hive.dart';

/// Key-value storage for azkar progress primitives.
///
/// Unit tests use [MemoryAzkarProgressStorage]; production wires the shared
/// settings box via [HiveAzkarProgressStorage] (no new box, no TypeAdapter,
// no migration — DEC-0024).
abstract class AzkarProgressStorage {
  /// Reads a stored value, or null when absent.
  Object? read(String key);

  /// Writes [value] for [key].
  Future<void> write(String key, Object? value);
}

/// In-memory storage for tests.
class MemoryAzkarProgressStorage implements AzkarProgressStorage {
  /// Creates in-memory storage.
  new([Map<String, Object?>? seed])
      : _map = Map<String, Object?>.from(seed ?? {});

  final Map<String, Object?> _map;

  @override
  Object? read(String key) => _map[key];

  @override
  Future<void> write(String key, Object? value) async {
    if (value == null) {
      _map.remove(key);
    } else {
      _map[key] = value;
    }
  }
}

/// Hive-backed storage using the shared settings box.
class HiveAzkarProgressStorage implements AzkarProgressStorage {
  /// Creates Hive storage (box may be null before bootstrap).
  new(this._box);

  final Box<dynamic>? _box;

  @override
  Object? read(String key) {
    final box = _box;
    if (box == null || !box.isOpen) return null;
    return box.get(key);
  }

  @override
  Future<void> write(String key, Object? value) async {
    final box = _box;
    if (box == null || !box.isOpen) {
      throw StateError('Hive azkar progress storage is unavailable.');
    }
    if (value == null) {
      await box.delete(key);
    } else {
      await box.put(key, value);
    }
  }
}
