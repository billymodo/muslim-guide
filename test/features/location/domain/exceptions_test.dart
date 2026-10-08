import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_guide/features/location/domain/exceptions/location_service_exception.dart';
import 'package:muslim_guide/features/location/domain/exceptions/location_timeout_exception.dart';

void main() {
  group('Location exceptions', () {
    test('LocationTimeoutException toString includes the timeout', () {
      const exception = LocationTimeoutException(
        timeout: Duration(seconds: 15),
      );

      expect(exception.toString(), contains('0:00:15.000000'));
    });

    test('LocationServiceException toString includes message and cause', () {
      const exception = LocationServiceException(
        message: 'Permission denied',
        cause: 'platform error',
      );

      expect(exception.toString(), contains('Permission denied'));
      expect(exception.toString(), contains('platform error'));
    });
  });
}
