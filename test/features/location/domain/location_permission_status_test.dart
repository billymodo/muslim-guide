import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_guide/features/location/domain/location_permission_status.dart';

void main() {
  group('LocationPermissionStatus', () {
    test('exposes the expected enum values in order', () {
      expect(LocationPermissionStatus.values, [
        LocationPermissionStatus.granted,
        LocationPermissionStatus.denied,
        LocationPermissionStatus.deniedForever,
        LocationPermissionStatus.serviceDisabled,
      ]);
    });

    test('has four distinct permission states', () {
      expect(LocationPermissionStatus.values, hasLength(4));
    });
  });
}
