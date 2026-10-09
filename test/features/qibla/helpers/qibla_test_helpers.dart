import 'package:flutter/services.dart' show rootBundle;
import 'package:muslim_guide/features/prayer/application/location_provider.dart';
import 'package:muslim_guide/features/prayer/data/cities_loader.dart';
import 'package:muslim_guide/features/prayer/domain/models/city.dart';

/// Test-only [LocationNotifier] that serves a fixed selection and allows
/// changing it without touching Hive (no bootstrap required in tests).
class FixedLocationNotifier extends LocationNotifier {
  /// Creates the notifier serving the given selection.
  new(this._selection);

  LocationSelection? _selection;

  /// Replaces the selection and notifies listeners.
  void change(LocationSelection? selection) {
    _selection = selection;
    state = selection;
  }

  @override
  LocationSelection? build() => _selection;
}

/// Test-only [CitiesLoader] returning an in-memory list.
class FixedCitiesLoader extends CitiesLoader {
  /// Creates the loader serving the given cities.
  new(this._cities) : super(assetBundle: rootBundle);

  final List<City> _cities;

  @override
  Future<List<City>> load() async => _cities;
}

/// Builds a [City] for tests with minimal required fields.
City makeCity({
  required String id,
  required double latitude,
  required double longitude,
}) => City(
  id: id,
  nameAr: 'مدينة',
  nameEn: id,
  countryAr: 'بلد',
  countryEn: 'Country',
  countryCode: 'XX',
  latitude: latitude,
  longitude: longitude,
  timezone: 'UTC',
);
