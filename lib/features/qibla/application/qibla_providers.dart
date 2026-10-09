import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muslim_guide/features/prayer/application/location_provider.dart';
import 'package:muslim_guide/features/qibla/application/qibla_state.dart';
import 'package:muslim_guide/features/qibla/data/compass_service.dart';
import 'package:muslim_guide/features/qibla/data/flutter_compass_service.dart';
import 'package:muslim_guide/features/qibla/domain/qibla_calculator.dart';
import 'package:muslim_guide/features/qibla/domain/qibla_direction.dart';

/// Compass data source; overridable in tests (Phase 02 lesson: no
/// MethodChannel inside widget/unit tests).
final compassServiceProvider = Provider<CompassService>(
  (ref) => FlutterCompassService(),
);

/// Combined location + compass state for the Qibla screen.
final AutoDisposeAsyncNotifierProvider<QiblaNotifier, QiblaState>
qiblaStateProvider =
    AsyncNotifierProvider.autoDispose<QiblaNotifier, QiblaState>(
  QiblaNotifier.new,
);

/// Resolves the location selection, computes the absolute bearing, and
/// streams device headings into a single [QiblaState].
class QiblaNotifier extends AutoDisposeAsyncNotifier<QiblaState> {
  @override
  Future<QiblaState> build() async {
    final selection = ref.watch(locationProvider);

    var locationSource = QiblaLocationSource.unavailable;
    double? latitude;
    double? longitude;

    if (selection is CoordinatesSelection) {
      latitude = selection.latitude;
      longitude = selection.longitude;
      locationSource = QiblaLocationSource.gps;
    } else if (selection is CitySelection) {
      final loader = ref.watch(citiesLoaderProvider);
      final cities = await loader.load();
      for (final city in cities) {
        if (city.id == selection.cityId) {
          latitude = city.latitude;
          longitude = city.longitude;
          locationSource = QiblaLocationSource.city;
          break;
        }
      }
    }

    double? bearing;
    if (latitude != null && longitude != null) {
      bearing = QiblaCalculator.bearingToKaaba(
        userLatitude: latitude,
        userLongitude: longitude,
      );
    }

    var current = bearing == null
        ? QiblaState.noLocation(sensorStatus: SensorStatus.initializing)
        : QiblaState(
            qiblaBearing: bearing,
            locationSource: locationSource,
            sensorStatus: SensorStatus.initializing,
          );

    final subscription = ref
        .read(compassServiceProvider)
        .headingStream
        .listen(
          (heading) {
            current = _applyHeading(current, heading);
            state = AsyncData(current);
          },
          onError: (Object error, StackTrace stack) {
            current = _withSensorStatus(current, SensorStatus.error);
            state = AsyncData(current);
          },
          onDone: () {
            if (current.sensorStatus == SensorStatus.initializing) {
              scheduleMicrotask(() {
                if (current.sensorStatus == SensorStatus.initializing) {
                  current = _withSensorStatus(
                    current,
                    SensorStatus.unavailable,
                  );
                  state = AsyncData(current);
                }
              });
            }
          },
        );
    ref.onDispose(subscription.cancel);
    return current;
  }

  QiblaState _applyHeading(QiblaState previous, double? heading) {
    if (heading == null) {
      return QiblaState.noSensor(
        locationSource: previous.locationSource,
        qiblaBearing: previous.qiblaBearing,
      );
    }
    final bearing = previous.qiblaBearing;
    if (bearing == null) {
      // Heading known but no location: report the sensor as available.
      return QiblaState(
        deviceHeading: heading,
        locationSource: previous.locationSource,
        sensorStatus: SensorStatus.available,
      );
    }
    return QiblaState.ready(
      qiblaBearing: bearing,
      deviceHeading: heading,
      locationSource: previous.locationSource,
    );
  }

  QiblaState _withSensorStatus(QiblaState previous, SensorStatus status) {
    return QiblaState(
      qiblaBearing: previous.qiblaBearing,
      deviceHeading: previous.deviceHeading,
      relativeAngle: previous.relativeAngle,
      locationSource: previous.locationSource,
      sensorStatus: status,
    );
  }
}
