import 'package:muslim_guide/features/location/domain/exceptions/location_service_exception.dart';
import 'package:muslim_guide/features/location/domain/exceptions/location_timeout_exception.dart';
import 'package:muslim_guide/features/location/domain/location_permission_status.dart';
import 'package:muslim_guide/features/location/domain/location_result.dart';

/// Domain contract for location access.
abstract class LocationService {
  /// Checks whether the app has location permission and service availability.
  Future<LocationPermissionStatus> checkPermission();

  /// Requests permission for location access.
  Future<LocationPermissionStatus> requestPermission();

  /// Returns true when location services are enabled on the device.
  Future<bool> isServiceEnabled();

  /// Resolves the current device position.
  ///
  /// Throws:
  /// - [StateError] if [checkPermission] is not granted or the device
  ///   service is disabled.
  /// - [LocationTimeoutException] if the request exceeds the configured
  ///   timeout.
  /// - [LocationServiceException] when the platform reports an error.
  Future<LocationResult> getCurrentLocation();

  /// Opens the app settings screen for this application.
  Future<void> openAppSettings();

  /// Opens the device location settings screen.
  Future<void> openLocationSettings();
}
