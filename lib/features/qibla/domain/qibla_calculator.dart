import 'dart:math' as math;

/// Pure calculator: great-circle bearing from a user location to the Kaaba.
///
/// No Flutter dependencies. No side effects. `dart:math` only.
///
/// Formula: great-circle **initial bearing**
/// (<https://en.wikipedia.org/wiki/Great-circle_navigation#Bearing>,
/// <https://www.movable-type.co.uk/scripts/latlong.html>):
///
/// ```text
/// θ = atan2( sin(Δλ)·cos(φ2),
///            cos(φ1)·sin(φ2) − sin(φ1)·cos(φ2)·cos(Δλ) )
/// bearing = (θ·180/π + 360) mod 360
/// ```
///
/// Static methods only — do not instantiate.
class QiblaCalculator {
  /// Kaaba coordinates (WGS84 decimal degrees): 21.4225, 39.8266
  /// (≈ 21°25′21″N 39°49′34″E).
  /// Source: <https://en.wikipedia.org/wiki/Kaaba> (infobox).
  static const double kaabaLatitude = 21.4225;

  /// Longitude of the Kaaba — see [kaabaLatitude].
  static const double kaabaLongitude = 39.8266;

  /// Users closer than ≈ 1m (1e-5°) to the Kaaba are rejected because the
  /// bearing is undefined there.
  static const double _kaabaEpsilon = 1e-5;

  /// Returns the initial great-circle bearing in degrees from
  /// (`userLatitude`, `userLongitude`) to the Kaaba, normalized to
  /// `[0, 360)`.
  ///
  /// Throws [ArgumentError] if latitude is outside `[-90, 90]`, if
  /// longitude is outside `[-180, 180]`, or if the user is within
  /// ≈1m of the Kaaba itself.
  static double bearingToKaaba({
    required double userLatitude,
    required double userLongitude,
  }) {
    if (userLatitude < -90 || userLatitude > 90) {
      throw ArgumentError.value(
        userLatitude,
        'userLatitude',
        'must be in the range [-90, 90]',
      );
    }
    if (userLongitude < -180 || userLongitude > 180) {
      throw ArgumentError.value(
        userLongitude,
        'userLongitude',
        'must be in the range [-180, 180]',
      );
    }

    // Reject the Kaaba itself (bearing undefined): Δ in degrees.
    final dLat = userLatitude - kaabaLatitude;
    final dLng = userLongitude - kaabaLongitude;
    if (math.sqrt(dLat * dLat + dLng * dLng) < _kaabaEpsilon) {
      throw ArgumentError.value(
        '$userLatitude, $userLongitude',
        'user location',
        'bearing is undefined within ~1m of the Kaaba',
      );
    }

    const degreesToRadians = math.pi / 180;
    final phi1 = userLatitude * degreesToRadians;
    const phi2 = kaabaLatitude * degreesToRadians;
    final deltaLambda =
        (kaabaLongitude - userLongitude) * degreesToRadians;

    final y = math.sin(deltaLambda) * math.cos(phi2);
    final x = math.cos(phi1) * math.sin(phi2) -
        math.sin(phi1) * math.cos(phi2) * math.cos(deltaLambda);

    final thetaDegrees = math.atan2(y, x) / degreesToRadians;
    return (thetaDegrees + 360) % 360;
  }
}
