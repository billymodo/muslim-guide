import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator_platform_interface/geolocator_platform_interface.dart';
import 'package:muslim_guide/features/location/data/geolocator_location_service.dart';
import 'package:muslim_guide/features/location/domain/exceptions/location_service_exception.dart';
import 'package:muslim_guide/features/location/domain/exceptions/location_timeout_exception.dart';
import 'package:muslim_guide/features/location/domain/location_permission_status.dart';
import 'package:muslim_guide/features/location/domain/location_result.dart';

import '../fakes/fake_geolocator_platform.dart';

void main() {
  group('GeolocatorLocationService', () {
    late FakeGeolocatorPlatform platform;
    late GeolocatorLocationService service;

    setUp(() {
      platform = FakeGeolocatorPlatform();
      service = GeolocatorLocationService(platform: platform);
    });

    test(
      'checkPermission returns granted when whileInUse permission is allowed',
      () async {
        platform.permission = LocationPermission.whileInUse;

        final result = await service.checkPermission();

        expect(result, LocationPermissionStatus.granted);
      },
    );

    test(
      'checkPermission returns granted when always permission is allowed',
      () async {
        platform.permission = LocationPermission.always;

        final result = await service.checkPermission();

        expect(result, LocationPermissionStatus.granted);
      },
    );

    test('checkPermission returns denied when access is denied', () async {
      platform.permission = LocationPermission.denied;

      final result = await service.checkPermission();

      expect(result, LocationPermissionStatus.denied);
    });

    test(
      'checkPermission returns deniedForever when access is permanently denied',
      () async {
        platform.permission = LocationPermission.deniedForever;

        final result = await service.checkPermission();

        expect(result, LocationPermissionStatus.deniedForever);
      },
    );

    test(
      'checkPermission returns serviceDisabled when the device service is off',
      () async {
        platform
          ..serviceEnabled = false
          ..permission = LocationPermission.whileInUse;

        final result = await service.checkPermission();

        expect(result, LocationPermissionStatus.serviceDisabled);
      },
    );

    test('requestPermission returns granted when access is approved', () async {
      platform.permission = LocationPermission.whileInUse;

      final result = await service.requestPermission();

      expect(result, LocationPermissionStatus.granted);
    });

    test('requestPermission returns denied when access is blocked', () async {
      platform.permission = LocationPermission.denied;

      final result = await service.requestPermission();

      expect(result, LocationPermissionStatus.denied);
    });

    test('isServiceEnabled delegates to the platform', () async {
      platform.serviceEnabled = true;

      final result = await service.isServiceEnabled();

      expect(result, isTrue);
      expect(platform.callLog, contains('isLocationServiceEnabled'));
    });

    test('getCurrentLocation returns a mapped LocationResult', () async {
      platform
        ..permission = LocationPermission.whileInUse
        ..position = Position(
          latitude: 21.4225,
          longitude: 39.8262,
          timestamp: DateTime(2026, 10, 8, 12),
          accuracy: 8.5,
          altitude: 0,
          altitudeAccuracy: 0,
          heading: 0,
          headingAccuracy: 0,
          speed: 0,
          speedAccuracy: 0,
        );

      final result = await service.getCurrentLocation();

      expect(result, isA<LocationResult>());
      expect(result.latitude, 21.4225);
      expect(result.longitude, 39.8262);
      expect(result.accuracy, 8.5);
    });

    test(
      'getCurrentLocation throws StateError when the preconditions fail',
      () async {
        platform.permission = LocationPermission.denied;

        await expectLater(
          service.getCurrentLocation(),
          throwsA(isA<StateError>()),
        );
      },
    );

    test(
      'getCurrentLocation throws LocationTimeoutException on timeout',
      () async {
        platform
          ..permission = LocationPermission.whileInUse
          ..throwOnGetCurrent = TimeoutException('timed out');

        await expectLater(
          service.getCurrentLocation(),
          throwsA(isA<LocationTimeoutException>()),
        );
      },
    );

    test(
      'getCurrentLocation wraps platform exceptions in '
      'LocationServiceException',
      () async {
        platform
          ..permission = LocationPermission.whileInUse
          ..throwOnGetCurrent = Exception('platform failure');

        await expectLater(
          service.getCurrentLocation(),
          throwsA(isA<LocationServiceException>()),
        );
      },
    );

    test('openAppSettings delegates to the plugin', () async {
      await service.openAppSettings();

      expect(platform.appSettingsCallCount, 1);
    });

    test('openLocationSettings delegates to the plugin', () async {
      await service.openLocationSettings();

      expect(platform.locationSettingsCallCount, 1);
    });
  });
}
