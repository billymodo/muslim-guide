import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:muslim_guide/features/prayer/application/location_provider.dart';
import 'package:muslim_guide/features/prayer/domain/models/city.dart';
import 'package:muslim_guide/features/qibla/application/qibla_providers.dart';
import 'package:muslim_guide/features/qibla/application/qibla_state.dart';
import 'package:muslim_guide/features/qibla/domain/qibla_direction.dart';

import '../helpers/fake_compass_service.dart';
import '../helpers/qibla_test_helpers.dart';

void main() {
  const cairoBearing = 136.135858;
  const londonBearing = 118.986778;

  const cairoCoords = CoordinatesSelection(
    latitude: 30.0444,
    longitude: 31.2357,
  );
  const londonCoords = CoordinatesSelection(
    latitude: 51.5074,
    longitude: -0.1278,
  );

  ({
    ProviderContainer container,
    FakeCompassService compass,
  }) makeContainer({
    LocationSelection? selection,
    List<City> cities = const [],
  }) {
    final compass = FakeCompassService();
    final container = ProviderContainer(
      overrides: [
        locationProvider
            .overrideWith(() => FixedLocationNotifier(selection)),
        compassServiceProvider.overrideWithValue(compass),
        citiesLoaderProvider
            .overrideWith((ref) => FixedCitiesLoader(cities)),
      ],
    );
    // Keep the autoDispose provider alive, like a mounted screen would.
    final subscription = container.listen(
      qiblaStateProvider,
      (_, _) {},
    );
    addTearDown(subscription.close);
    addTearDown(container.dispose);
    addTearDown(compass.dispose);
    return (container: container, compass: compass);
  }

  QiblaState readState(ProviderContainer container) {
    return container.read(qiblaStateProvider).requireValue;
  }

  group('qiblaStateProvider', () {
    test('initial state: initializing, no bearing', () async {
      final (:container, :compass) = makeContainer();
      await container.read(qiblaStateProvider.future);
      final state = readState(container);
      expect(state.sensorStatus, SensorStatus.initializing);
      expect(state.qiblaBearing, isNull);
      expect(state.deviceHeading, isNull);
      expect(state.relativeAngle, isNull);
      expect(state.locationSource, QiblaLocationSource.unavailable);
      expect(compass.activeListeners, 1);
    });

    test('GPS + heading 0 → available with correct bearing', () async {
      final (:container, :compass) =
          makeContainer(selection: cairoCoords);
      await container.read(qiblaStateProvider.future);
      compass.emit(0);
      await pumpEventQueue();
      final state = readState(container);
      expect(state.sensorStatus, SensorStatus.available);
      expect(state.locationSource, QiblaLocationSource.gps);
      expect(state.qiblaBearing, closeTo(cairoBearing, 0.1));
      expect(state.deviceHeading, 0);
      expect(state.relativeAngle, closeTo(cairoBearing, 0.1));
    });

    test('city location → city source with city bearing', () async {
      final (:container, :compass) = makeContainer(
        selection: const CitySelection('cairo'),
        cities: [
          makeCity(id: 'cairo', latitude: 30.0444, longitude: 31.2357),
        ],
      );
      await container.read(qiblaStateProvider.future);
      compass.emit(45);
      await pumpEventQueue();
      final state = readState(container);
      expect(state.locationSource, QiblaLocationSource.city);
      expect(state.sensorStatus, SensorStatus.available);
      expect(state.qiblaBearing, closeTo(cairoBearing, 0.1));
      expect(state.relativeAngle, closeTo(cairoBearing - 45, 0.1));
    });

    test('unknown city id → no bearing, unavailable source', () async {
      final (:container, :compass) = makeContainer(
        selection: const CitySelection('missing'),
        cities: [
          makeCity(id: 'cairo', latitude: 30.0444, longitude: 31.2357),
        ],
      );
      await container.read(qiblaStateProvider.future);
      final state = readState(container);
      expect(state.qiblaBearing, isNull);
      expect(state.locationSource, QiblaLocationSource.unavailable);
      expect(compass.activeListeners, 1);
    });

    test('no location + heading arrives → available, no bearing',
        () async {
      final (:container, :compass) = makeContainer();
      await container.read(qiblaStateProvider.future);
      compass.emit(90);
      await pumpEventQueue();
      final state = readState(container);
      expect(state.sensorStatus, SensorStatus.available);
      expect(state.deviceHeading, 90);
      expect(state.qiblaBearing, isNull);
      expect(state.relativeAngle, isNull);
    });

    test('compass emits null → unavailable, keeps bearing', () async {
      final (:container, :compass) =
          makeContainer(selection: cairoCoords);
      await container.read(qiblaStateProvider.future);
      compass.emit(null);
      await pumpEventQueue();
      final state = readState(container);
      expect(state.sensorStatus, SensorStatus.unavailable);
      expect(state.qiblaBearing, closeTo(cairoBearing, 0.1));
      expect(state.deviceHeading, isNull);
      expect(state.locationSource, QiblaLocationSource.gps);
    });

    test('compass error → sensorStatus error, keeps bearing', () async {
      final (:container, :compass) =
          makeContainer(selection: cairoCoords);
      await container.read(qiblaStateProvider.future);
      compass.emitError(Exception('sensor failure'));
      await pumpEventQueue();
      final state = readState(container);
      expect(state.sensorStatus, SensorStatus.error);
      expect(state.qiblaBearing, closeTo(cairoBearing, 0.1));
    });

    test('heading sequence [10, 20, 30] → deviceHeading follows',
        () async {
      final (:container, :compass) =
          makeContainer(selection: cairoCoords);
      await container.read(qiblaStateProvider.future);
      for (final heading in [10.0, 20.0, 30.0]) {
        compass.emit(heading);
        await pumpEventQueue();
        expect(readState(container).deviceHeading, heading);
      }
      expect(readState(container).sensorStatus, SensorStatus.available);
    });

    test('location change → qiblaBearing recalculated', () async {
      final (:container, :compass) =
          makeContainer(selection: cairoCoords);
      await container.read(qiblaStateProvider.future);
      compass.emit(0);
      await pumpEventQueue();
      expect(readState(container).qiblaBearing, closeTo(cairoBearing, 0.1));

      final notifier = container.read(locationProvider.notifier);
      expect(notifier, isA<FixedLocationNotifier>());
      (notifier as FixedLocationNotifier).change(londonCoords);
      await container.read(qiblaStateProvider.future);
      // The rebuild starts a fresh heading-less state; re-emit a heading.
      compass.emit(0);
      await pumpEventQueue();
      expect(readState(container).qiblaBearing, closeTo(londonBearing, 0.1));
      expect(
        readState(container).relativeAngle,
        closeTo(londonBearing, 0.1),
      );
    });

    test('dispose cancels the compass subscription', () async {
      final (:container, :compass) =
          makeContainer(selection: cairoCoords);
      await container.read(qiblaStateProvider.future);
      expect(compass.activeListeners, 1);
      container.dispose();
      expect(compass.activeListeners, 0);
      compass.emit(10); // Dropped after cancel — must not throw.
    });
  });

  group('QiblaState.ready relative angle', () {
    QiblaState ready(double bearing, double heading) => QiblaState.ready(
      qiblaBearing: bearing,
      deviceHeading: heading,
      locationSource: QiblaLocationSource.gps,
    );

    test('bearing 200, heading 50 → 150', () {
      expect(ready(200, 50).relativeAngle, closeTo(150, 1e-9));
    });

    test('bearing 50, heading 200 → 210 (wrap)', () {
      expect(ready(50, 200).relativeAngle, closeTo(210, 1e-9));
    });

    test('bearing 0, heading 0 → 0', () {
      expect(ready(0, 0).relativeAngle, closeTo(0, 1e-9));
    });

    test('bearing 359, heading 1 → 358', () {
      expect(ready(359, 1).relativeAngle, closeTo(358, 1e-9));
    });

    test('bearing 1, heading 359 → 2 (wrap across 0)', () {
      expect(ready(1, 359).relativeAngle, closeTo(2, 1e-9));
    });

    test('bearing 180, heading 270 → 270', () {
      expect(ready(180, 270).relativeAngle, closeTo(270, 1e-9));
    });

    test('bearing 350, heading 10 → 340', () {
      expect(ready(350, 10).relativeAngle, closeTo(340, 1e-9));
    });

    test('five values stay in [0, 360)', () {
      const pairs = <(double, double)>[
        (12.3, 345.6),
        (271.4, 103.9),
        (180.0, 180.0),
        (0.4, 359.9),
        (359.6, 0.1),
      ];
      for (final (bearing, heading) in pairs) {
        final relative = ready(bearing, heading).relativeAngle!;
        expect(relative, greaterThanOrEqualTo(0.0));
        expect(relative, lessThan(360.0));
      }
    });
  });

  group('QiblaState factories', () {
    test('initializing → unavailable source, null bearing', () {
      final state = QiblaState.initializing();
      expect(state.sensorStatus, SensorStatus.initializing);
      expect(state.qiblaBearing, isNull);
      expect(state.locationSource, QiblaLocationSource.unavailable);
    });

    test('noSensor keeps bearing + location source', () {
      final state = QiblaState.noSensor(
        locationSource: QiblaLocationSource.city,
        qiblaBearing: 136.1,
      );
      expect(state.sensorStatus, SensorStatus.unavailable);
      expect(state.qiblaBearing, 136.1);
      expect(state.locationSource, QiblaLocationSource.city);
      expect(state.deviceHeading, isNull);
    });

    test('noLocation propagates sensor status', () {
      final state = QiblaState.noLocation(
        sensorStatus: SensorStatus.initializing,
      );
      expect(state.locationSource, QiblaLocationSource.unavailable);
      expect(state.qiblaBearing, isNull);
      expect(state.sensorStatus, SensorStatus.initializing);
    });
  });
}
