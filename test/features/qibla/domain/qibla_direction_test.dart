import 'package:flutter_test/flutter_test.dart';

import 'package:muslim_guide/features/qibla/domain/qibla_direction.dart';

void main() {
  group('QiblaDirection', () {
    test('holds provided values', () {
      const d = QiblaDirection(
        bearingDegrees: 136.1,
        userLatitude: 30.0444,
        userLongitude: 31.2357,
        source: QiblaLocationSource.gps,
      );
      expect(d.bearingDegrees, 136.1);
      expect(d.userLatitude, 30.0444);
      expect(d.userLongitude, 31.2357);
      expect(d.source, QiblaLocationSource.gps);
    });

    test('unavailable factory → nulls + unavailable source', () {
      final d = QiblaDirection.unavailable();
      expect(d.bearingDegrees, isNull);
      expect(d.userLatitude, isNull);
      expect(d.userLongitude, isNull);
      expect(d.source, QiblaLocationSource.unavailable);
    });

    test('city source is distinct from gps', () {
      const d = QiblaDirection(source: QiblaLocationSource.city);
      expect(d.source, QiblaLocationSource.city);
      expect(d.source, isNot(QiblaLocationSource.gps));
    });

    test('exposes all three location sources', () {
      expect(QiblaLocationSource.values, hasLength(3));
      expect(
        QiblaLocationSource.values,
        containsAll([
          QiblaLocationSource.gps,
          QiblaLocationSource.city,
          QiblaLocationSource.unavailable,
        ]),
      );
    });
  });
}
