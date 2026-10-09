import 'package:flutter_compass/flutter_compass.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_guide/features/qibla/data/flutter_compass_service.dart';

void main() {
  group('FlutterCompassService', () {
    test('uses the plugin events provider by default', () {
      expect(FlutterCompassService().headingStream, isA<Stream<double?>>());
    });

    test(
      'null events provider emits one null heading then completes',
      () async {
        final service = FlutterCompassService(eventsProvider: () => null);

        await expectLater(
          service.headingStream,
          emitsInOrder([null, emitsDone]),
        );
      },
    );

    test('maps compass event headings', () async {
      final events = Stream<CompassEvent>.fromIterable([
        CompassEvent.fromList([45, 0, -1]),
        CompassEvent.fromList([90, 0, -1]),
      ]);
      final service = FlutterCompassService(eventsProvider: () => events);

      await expectLater(
        service.headingStream,
        emitsInOrder([45.0, 90.0, emitsDone]),
      );
    });

    test('propagates errors from the event stream', () async {
      final error = StateError('compass stream failed');
      final service = FlutterCompassService(
        eventsProvider: () => Stream<CompassEvent>.error(error),
      );

      await expectLater(service.headingStream, emitsError(same(error)));
    });

    test('preserves an empty live event stream', () async {
      final service = FlutterCompassService(
        eventsProvider: () => const Stream<CompassEvent>.empty(),
      );

      await expectLater(service.headingStream, emitsDone);
    });
  });
}
