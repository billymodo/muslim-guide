import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meta/meta.dart';
import 'package:muslim_guide/app/providers/bootstrap_provider.dart';
import 'package:muslim_guide/features/location/data/geolocator_location_service.dart';
import 'package:muslim_guide/features/location/domain/location_service.dart';
import 'package:muslim_guide/features/prayer/data/cities_loader.dart';

/// The source of the user's location for prayer-time calculations.
@immutable
sealed class LocationSelection {
  /// Creates a location selection.
  const new();
}

/// A manually selected bundled city.
@immutable
class CitySelection extends LocationSelection {
  /// Creates a selection for the bundled city identified by [cityId].
  const new(this.cityId);

  /// Identifier of the selected city in the bundled city list.
  final String cityId;

  @override
  bool operator ==(Object other) {
    return other is CitySelection && other.cityId == cityId;
  }

  @override
  int get hashCode => cityId.hashCode;

  @override
  String toString() => 'CitySelection($cityId)';
}

/// GPS coordinates captured from the device.
@immutable
class CoordinatesSelection extends LocationSelection {
  /// Creates a selection for the given coordinates.
  const new({
    required this.latitude,
    required this.longitude,
  });

  /// Latitude in decimal degrees, positive north of the equator.
  final double latitude;

  /// Longitude in decimal degrees, positive east of the prime meridian.
  final double longitude;

  @override
  bool operator ==(Object other) {
    return other is CoordinatesSelection &&
        other.latitude == latitude &&
        other.longitude == longitude;
  }

  @override
  int get hashCode => Object.hash(latitude, longitude);

  @override
  String toString() =>
      'CoordinatesSelection(latitude: $latitude, longitude: $longitude)';
}

/// Provides the platform-backed location service.
final locationServiceProvider = Provider<LocationService>(
  (ref) => GeolocatorLocationService(),
);

/// Provides the bundled city loader backed by the root asset bundle.
final citiesLoaderProvider = Provider<CitiesLoader>(
  (ref) => CitiesLoader(assetBundle: rootBundle),
);

/// Holds the user's chosen location; `null` until a selection is made.
final locationProvider = NotifierProvider<LocationNotifier, LocationSelection?>(
  LocationNotifier.new,
);

/// Updates, persists, and restores the user's location selection.
///
/// Hydration runs once at creation; a selection made before hydration
/// finishes wins so the user's latest choice is never overwritten.
class LocationNotifier extends Notifier<LocationSelection?> {
  bool _touched = false;
  bool _disposed = false;

  @override
  LocationSelection? build() {
    // Re-hydrate once bootstrap makes storage available.
    ref.watch(hiveStoreProvider);
    _disposed = false;
    ref.onDispose(() => _disposed = true);
    unawaited(_restore());
    return null;
  }

  /// Selects a bundled city by [cityId] and persists the choice.
  ///
  /// The state updates immediately; persistence errors propagate to the
  /// caller while the in-session selection stays active.
  Future<void> selectCity(String cityId) async {
    _touched = true;
    state = CitySelection(cityId);
    await ref.read(settingsRepositoryProvider).setSelectedCityId(cityId);
  }

  /// Selects GPS [latitude] and [longitude] and persists the choice.
  Future<void> selectCoordinates({
    required double latitude,
    required double longitude,
  }) async {
    _touched = true;
    state = CoordinatesSelection(latitude: latitude, longitude: longitude);
    await ref
        .read(settingsRepositoryProvider)
        .setSelectedCoordinates(latitude, longitude);
  }

  /// Clears the selection both in memory and in storage.
  Future<void> clear() async {
    _touched = true;
    state = null;
    final settings = ref.read(settingsRepositoryProvider);
    await settings.setSelectedCityId(null);
    await settings.setSelectedCoordinates(null, null);
  }

  Future<void> _restore() async {
    if (ref.read(hiveStoreProvider) == null) {
      // Storage is not ready before bootstrap; the rebuild triggered when
      // the store appears runs hydration again.
      return;
    }
    try {
      final settings = ref.read(settingsRepositoryProvider);
      final cityId = await settings.getSelectedCityId();
      final coordinates = cityId == null
          ? await settings.getSelectedCoordinates()
          : null;
      if (_touched || _disposed) return;
      if (cityId != null) {
        state = CitySelection(cityId);
      } else if (coordinates != null) {
        state = CoordinatesSelection(
          latitude: coordinates.$1,
          longitude: coordinates.$2,
        );
      }
    } on Object catch (error, stack) {
      developer.log(
        'Failed to restore the saved location selection.',
        name: 'muslim_guide.prayer',
        error: error,
        stackTrace: stack,
      );
    }
  }
}
