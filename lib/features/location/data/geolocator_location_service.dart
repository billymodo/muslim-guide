import 'dart:async';

import 'package:geolocator/geolocator.dart';
import 'package:muslim_guide/features/location/domain/exceptions/location_service_exception.dart';
import 'package:muslim_guide/features/location/domain/exceptions/location_timeout_exception.dart';
import 'package:muslim_guide/features/location/domain/location_permission_status.dart';
import 'package:muslim_guide/features/location/domain/location_result.dart';
import 'package:muslim_guide/features/location/domain/location_service.dart';

/// Geolocator-backed implementation of the location domain contract.
class GeolocatorLocationService implements LocationService {
  /// Creates a geolocator-backed location service.
  new({GeolocatorPlatform? platform})
    : _platform = platform ?? GeolocatorPlatform.instance;

  static const Duration _defaultTimeout = Duration(seconds: 15);

  final GeolocatorPlatform _platform;

  @override
  /// Checks the current permission and service status for location access.
  Future<LocationPermissionStatus> checkPermission() async {
    try {
      final serviceEnabled = await _platform.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return LocationPermissionStatus.serviceDisabled;
      }

      final permission = await _platform.checkPermission();
      return _mapPermission(permission);
    } on Exception catch (error) {
      throw LocationServiceException(
        message: 'Unable to determine location permission.',
        cause: error,
      );
    }
  }

  @override
  /// Requests location permission from the platform.
  Future<LocationPermissionStatus> requestPermission() async {
    try {
      final serviceEnabled = await _platform.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return LocationPermissionStatus.serviceDisabled;
      }

      final permission = await _platform.requestPermission();
      return _mapPermission(permission);
    } on Exception catch (error) {
      throw LocationServiceException(
        message: 'Unable to request location permission.',
        cause: error,
      );
    }
  }

  @override
  /// Returns whether location services are enabled on the device.
  Future<bool> isServiceEnabled() => _platform.isLocationServiceEnabled();

  @override
  /// Resolves the current device position when preconditions are satisfied.
  Future<LocationResult> getCurrentLocation() async {
    final status = await checkPermission();
    if (status != LocationPermissionStatus.granted) {
      throw StateError(
        'Location permission must be granted and the location service must '
        'be enabled before retrieving the current position.',
      );
    }

    try {
      final position = await _platform.getCurrentPosition(
        locationSettings: const LocationSettings(timeLimit: _defaultTimeout),
      );
      return _mapPosition(position);
    } on TimeoutException {
      throw const LocationTimeoutException(timeout: _defaultTimeout);
    } on Exception catch (error) {
      throw LocationServiceException(
        message: 'Unable to determine the current location.',
        cause: error,
      );
    }
  }

  @override
  /// Opens the app settings screen for this application.
  Future<void> openAppSettings() async {
    try {
      final opened = await _platform.openAppSettings();
      if (!opened) {
        throw const LocationServiceException(
          message: 'Could not open the app settings screen.',
        );
      }
    } on LocationServiceException {
      rethrow;
    } on Exception catch (error) {
      throw LocationServiceException(
        message: 'Unable to open the app settings screen.',
        cause: error,
      );
    }
  }

  @override
  /// Opens the system location settings screen.
  Future<void> openLocationSettings() async {
    try {
      final opened = await _platform.openLocationSettings();
      if (!opened) {
        throw const LocationServiceException(
          message: 'Could not open the device location settings screen.',
        );
      }
    } on LocationServiceException {
      rethrow;
    } on Exception catch (error) {
      throw LocationServiceException(
        message: 'Unable to open the device location settings screen.',
        cause: error,
      );
    }
  }

  static LocationPermissionStatus _mapPermission(
    LocationPermission permission,
  ) {
    switch (permission) {
      case LocationPermission.always:
      case LocationPermission.whileInUse:
        return LocationPermissionStatus.granted;
      case LocationPermission.deniedForever:
        return LocationPermissionStatus.deniedForever;
      case LocationPermission.denied:
      case LocationPermission.unableToDetermine:
        return LocationPermissionStatus.denied;
    }
  }

  static LocationResult _mapPosition(Position position) {
    return LocationResult(
      latitude: position.latitude,
      longitude: position.longitude,
      accuracy: position.accuracy,
      timestamp: position.timestamp,
    );
  }
}
