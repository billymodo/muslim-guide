import 'package:geolocator_platform_interface/geolocator_platform_interface.dart';

/// A fake geolocator platform for deterministic unit tests.
class FakeGeolocatorPlatform extends GeolocatorPlatform {
  LocationPermission permission = LocationPermission.denied;
  bool serviceEnabled = true;
  Position? position;
  Exception? throwOnGetCurrent;
  int appSettingsCallCount = 0;
  int locationSettingsCallCount = 0;
  final List<String> callLog = <String>[];

  void clearCallLog() {
    callLog.clear();
  }

  @override
  Future<LocationPermission> checkPermission() async {
    callLog.add('checkPermission');
    return permission;
  }

  @override
  Future<LocationPermission> requestPermission() async {
    callLog.add('requestPermission');
    return permission;
  }

  @override
  Future<bool> isLocationServiceEnabled() async {
    callLog.add('isLocationServiceEnabled');
    return serviceEnabled;
  }

  @override
  Future<Position> getCurrentPosition({
    LocationSettings? locationSettings,
  }) async {
    callLog.add('getCurrentPosition');
    final error = throwOnGetCurrent;
    if (error != null) {
      throw error;
    }

    return position ??
        Position(
          latitude: 24.4539,
          longitude: 39.617,
          timestamp: DateTime(2026, 10, 8, 12),
          accuracy: 5,
          altitude: 0,
          altitudeAccuracy: 0,
          heading: 0,
          headingAccuracy: 0,
          speed: 0,
          speedAccuracy: 0,
        );
  }

  @override
  Future<bool> openAppSettings() async {
    appSettingsCallCount += 1;
    callLog.add('openAppSettings');
    return true;
  }

  @override
  Future<bool> openLocationSettings() async {
    locationSettingsCallCount += 1;
    callLog.add('openLocationSettings');
    return true;
  }
}
