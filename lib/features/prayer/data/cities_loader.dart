import 'dart:convert';

import 'package:flutter/services.dart';

import 'package:muslim_guide/features/prayer/domain/models/city.dart';

/// Loads the bundled city list and caches the pending or parsed result.
class CitiesLoader {
  /// Creates a loader for the supplied asset bundle.
  new({
    required this.assetBundle,
    this.assetPath = 'assets/cities/major_cities.json',
  });

  /// Bundled JSON path.
  final String assetPath;

  /// Asset bundle used to load the JSON file.
  final AssetBundle assetBundle;

  Future<List<City>>? _cities;

  /// Returns all cities, sharing a pending load and caching its result.
  Future<List<City>> load() {
    return _cities ??= _load();
  }

  Future<List<City>> _load() async {
    final decoded = jsonDecode(await assetBundle.loadString(assetPath));
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Cities asset must contain a JSON object.');
    }

    final rawCities = decoded['cities'];
    if (rawCities is! List<dynamic>) {
      throw const FormatException(
        'Cities asset field "cities" must be a list.',
      );
    }

    final cities = <City>[];
    final ids = <String>{};
    for (final rawCity in rawCities) {
      if (rawCity is! Map<String, dynamic>) {
        throw const FormatException('Each city entry must be a JSON object.');
      }
      final city = City.fromJson(rawCity);
      if (!ids.add(city.id)) {
        throw FormatException('Duplicate city ID "${city.id}".');
      }
      cities.add(city);
    }

    return List<City>.unmodifiable(cities);
  }
}
