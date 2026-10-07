/// Geographic inputs required to calculate prayer times.
class LocationData {
  /// Creates a location using decimal coordinates, elevation in meters, and
  /// an IANA timezone identifier.
  const new({
    required this.latitude,
    required this.longitude,
    required this.timeZoneId,
    this.elevationMeters = 0,
  });

  /// Latitude in decimal degrees, positive north of the equator.
  final double latitude;

  /// Longitude in decimal degrees, positive east of the prime meridian.
  final double longitude;

  /// Elevation above sea level in meters.
  final double elevationMeters;

  /// IANA timezone identifier, such as `Europe/London`.
  final String timeZoneId;
}
