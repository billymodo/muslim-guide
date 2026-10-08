import 'package:meta/meta.dart';

/// Represents a resolved location fix.
@immutable
class LocationResult {
  /// Creates a resolved location result.
  const new({
    required this.latitude,
    required this.longitude,
    required this.accuracy,
    required this.timestamp,
  });

  /// Latitude in decimal degrees.
  final double latitude;

  /// Longitude in decimal degrees.
  final double longitude;

  /// Horizontal accuracy in meters.
  final double accuracy;

  /// The time the location was resolved.
  final DateTime timestamp;

  /// Returns a copy with the requested fields replaced.
  LocationResult copyWith({
    double? latitude,
    double? longitude,
    double? accuracy,
    DateTime? timestamp,
  }) {
    return LocationResult(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      accuracy: accuracy ?? this.accuracy,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is LocationResult &&
        other.latitude == latitude &&
        other.longitude == longitude &&
        other.accuracy == accuracy &&
        other.timestamp == timestamp;
  }

  @override
  int get hashCode => Object.hash(latitude, longitude, accuracy, timestamp);

  @override
  String toString() {
    return 'LocationResult(latitude: $latitude, longitude: $longitude, '
        'accuracy: $accuracy, timestamp: $timestamp)';
  }
}
