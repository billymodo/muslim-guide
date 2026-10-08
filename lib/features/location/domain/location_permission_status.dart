/// Permission and service states exposed by the location domain.
enum LocationPermissionStatus {
  /// Location permission was granted.
  granted,

  /// Location permission was denied but can be requested again.
  denied,

  /// Location permission was permanently denied.
  deniedForever,

  /// The device-wide location service is disabled.
  serviceDisabled,
}
