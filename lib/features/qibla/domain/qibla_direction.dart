import 'package:meta/meta.dart';

/// Immutable holder for a computed Qibla direction.
///
/// Data-only (no business logic): `bearingDegrees` is `null` when no
/// direction could be computed (see [QiblaDirection.unavailable]).
@immutable
class QiblaDirection {
  /// Creates a [QiblaDirection].
  const new({
    required this.source,
    this.bearingDegrees,
    this.userLatitude,
    this.userLongitude,
  });

  /// No location available → no bearing.
  factory unavailable() =>
      const QiblaDirection(source: QiblaLocationSource.unavailable);

  /// Initial bearing in degrees `[0, 360)` toward the Kaaba.
  /// `null` if unavailable.
  final double? bearingDegrees;

  /// Latitude the bearing was computed from. `null` if unavailable.
  final double? userLatitude;

  /// Longitude the bearing was computed from. `null` if unavailable.
  final double? userLongitude;

  /// Where the coordinates came from (GPS, saved city, or none).
  final QiblaLocationSource source;
}

/// Origin of the coordinates backing a [QiblaDirection].
enum QiblaLocationSource {
  /// Live device GPS fix.
  gps,

  /// Coordinates of a manually selected city.
  city,

  /// No location available (service off, permission denied, etc.).
  unavailable,
}
