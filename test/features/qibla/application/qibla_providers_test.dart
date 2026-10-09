import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_guide/features/prayer/application/location_provider.dart';
import 'package:muslim_guide/features/qibla/application/qibla_providers.dart';
import 'package:muslim_guide/features/qibla/application/qibla_state.dart';
import 'package:muslim_guide/features/qibla/data/compass_service.dart';

import '../helpers/qibla_test_helpers.dart';

const _cairo = CoordinatesSelection(latitude: 30.0444, longitude: 31.2357);

void main() {
  group('QiblaNotifier stream completion', () {
    test('empty stream marks the sensor unavailable', () async {
      final container = _makeContainer(const Stream<double?>.empty());
      await container.read(qiblaStateProvider.future);
      await pumpEventQueue();

      final state = container.read(qiblaStateProvider).requireValue;
      expect(state.sensorStatus, SensorStatus.unavailable);
      expect(state.qiblaBearing, isNotNull);
    });

    test(
      'stream completion after a heading preserves available status',
      () async {
        final headings = StreamController<double?>();
        addTearDown(() async {
          if (!headings.isClosed) {
            await headings.close();
          }
        });
        final container = _makeContainer(headings.stream);
        await container.read(qiblaStateProvider.future);
        headings.add(45);
        await pumpEventQueue();
        await headings.close();
        await pumpEventQueue();

        final state = container.read(qiblaStateProvider).requireValue;
        expect(state.sensorStatus, SensorStatus.available);
        expect(state.deviceHeading, 45);
        expect(state.relativeAngle, isNotNull);
      },
    );
  });
}

ProviderContainer _makeContainer(Stream<double?> headings) {
  final container = ProviderContainer(
    overrides: [
      locationProvider.overrideWith(() => FixedLocationNotifier(_cairo)),
      compassServiceProvider.overrideWithValue(_TestCompassService(headings)),
    ],
  );
  final subscription = container.listen(qiblaStateProvider, (_, _) {});
  addTearDown(subscription.close);
  addTearDown(container.dispose);
  return container;
}

class _TestCompassService implements CompassService {
  const new(this._headings);

  final Stream<double?> _headings;

  @override
  Stream<double?> get headingStream => _headings;
}
