import 'dart:developer' as developer;
import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meta/meta.dart';
import 'package:muslim_guide/features/prayer/application/asr_method_provider.dart';
import 'package:muslim_guide/features/prayer/application/calculation_method_provider.dart';
import 'package:muslim_guide/features/prayer/application/high_latitude_rule_provider.dart';
import 'package:muslim_guide/features/prayer/application/location_provider.dart';
import 'package:muslim_guide/features/prayer/data/repositories/prayer_times_repository_impl.dart';
import 'package:muslim_guide/features/prayer/domain/models/city.dart';
import 'package:muslim_guide/features/prayer/domain/models/location_data.dart';
import 'package:muslim_guide/features/prayer/domain/models/prayer_times_result.dart';
import 'package:muslim_guide/features/prayer/domain/repositories/prayer_times_repository.dart';
import 'package:timezone/timezone.dart' as tz;

/// Maximum distance in kilometers between a GPS fix and the city used to
/// derive the timezone identifier (Task 4 decision: nearest city).
const double maxNearestCityDistanceKm = 500;

/// Provides the minimal calculation repository (isolation only, no I/O).
final prayerTimesRepositoryProvider = Provider<PrayerTimesRepository>(
  (ref) => const PrayerTimesRepositoryImpl(),
);

/// Calculates today's prayer times for the selected location.
///
/// Emits `null` while no location has been selected (Empty state), an error
/// when resolution or calculation fails, and the result otherwise. The
/// provider rebuilds whenever the location, the calculation method, the Asr
/// method, or the high-latitude rule changes; pull-to-refresh can call
/// `ref.invalidate(prayerTimesProvider)`.
final AutoDisposeAsyncNotifierProvider<
  PrayerTimesNotifier,
  PrayerTimesResult?
>
prayerTimesProvider =
    AsyncNotifierProvider.autoDispose<PrayerTimesNotifier, PrayerTimesResult?>(
  PrayerTimesNotifier.new,
);

/// Loads the inputs and runs the calculation repository.
class PrayerTimesNotifier extends AutoDisposeAsyncNotifier<PrayerTimesResult?> {
  @override
  Future<PrayerTimesResult?> build() async {
    final selection = ref.watch(locationProvider);
    if (selection == null) {
      return null;
    }
    final method = ref.watch(calculationMethodProvider);
    final asrMethod = ref.watch(asrMethodProvider);
    final highLatRule = ref.watch(highLatitudeRuleProvider);
    final cities = await ref.watch(citiesLoaderProvider).load();
    final location = resolveLocationData(selection, cities);
    final localNow = tz.TZDateTime.now(tz.getLocation(location.timeZoneId));
    return ref.read(prayerTimesRepositoryProvider).calculate(
      location: location,
      date: localNow,
      method: method,
      asrMethod: asrMethod,
      highLatRule: highLatRule,
    );
  }
}

/// Resolves [selection] into calculation inputs using the bundled [cities].
///
/// A [CitySelection] uses the city directly. A [CoordinatesSelection] uses
/// the coordinates with the timezone of the nearest bundled city within
/// [maxNearestCityDistanceKm]; beyond that the device-local timezone is used
/// (falling back to `Asia/Riyadh` per DEC-0029 when it cannot be read).
@visibleForTesting
LocationData resolveLocationData(
  LocationSelection selection,
  List<City> cities,
) {
  if (selection is CitySelection) {
    City? selected;
    for (final city in cities) {
      if (city.id == selection.cityId) {
        selected = city;
        break;
      }
    }
    if (selected == null) {
      throw StateError('Unknown bundled city "${selection.cityId}".');
    }
    return LocationData(
      latitude: selected.latitude,
      longitude: selected.longitude,
      timeZoneId: selected.timezone,
      elevationMeters: selected.elevation ?? 0,
    );
  }

  final coordinates = selection as CoordinatesSelection;
  City? nearest;
  var nearestDistanceKm = double.infinity;
  for (final city in cities) {
    final distanceKm = _haversineKm(
      coordinates.latitude,
      coordinates.longitude,
      city.latitude,
      city.longitude,
    );
    if (distanceKm < nearestDistanceKm) {
      nearestDistanceKm = distanceKm;
      nearest = city;
    }
  }

  String timeZoneId;
  if (nearest != null && nearestDistanceKm <= maxNearestCityDistanceKm) {
    timeZoneId = nearest.timezone;
  } else {
    timeZoneId = _deviceTimeZoneId();
    developer.log(
      'No bundled city within ${maxNearestCityDistanceKm.toStringAsFixed(0)}'
      ' km of the GPS fix; using device timezone "$timeZoneId".',
      name: 'muslim_guide.prayer',
    );
  }

  return LocationData(
    latitude: coordinates.latitude,
    longitude: coordinates.longitude,
    timeZoneId: timeZoneId,
  );
}

String _deviceTimeZoneId() {
  try {
    return tz.local.name;
  } on Object catch (error, stack) {
    developer.log(
      'Device timezone is unavailable; falling back to Asia/Riyadh.',
      name: 'muslim_guide.prayer',
      error: error,
      stackTrace: stack,
    );
    return 'Asia/Riyadh';
  }
}

double _haversineKm(
  double latitudeA,
  double longitudeA,
  double latitudeB,
  double longitudeB,
) {
  const earthRadiusKm = 6371.0;
  final deltaLatitude = _toRadians(latitudeB - latitudeA);
  final deltaLongitude = _toRadians(longitudeB - longitudeA);
  final a = math.sin(deltaLatitude / 2) * math.sin(deltaLatitude / 2) +
      math.cos(_toRadians(latitudeA)) *
          math.cos(_toRadians(latitudeB)) *
          math.sin(deltaLongitude / 2) *
          math.sin(deltaLongitude / 2);
  return 2 *
      earthRadiusKm *
      math.atan2(math.sqrt(a), math.sqrt(1 - a));
}

double _toRadians(double degrees) => degrees * math.pi / 180;
