/// A city with the location details needed for prayer-time calculations.
class City {
  /// Creates a city.
  const new({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.countryAr,
    required this.countryEn,
    required this.countryCode,
    required this.latitude,
    required this.longitude,
    required this.timezone,
    this.elevation,
  });

  /// Creates a city from the versioned cities asset.
  factory fromJson(Map<String, dynamic> json) {
    String requiredString(String key) {
      final value = json[key];
      if (value is String && value.trim().isNotEmpty) {
        return value;
      }
      throw FormatException('City field "$key" must be a non-empty string.');
    }

    double requiredNumber(String key) {
      final value = json[key];
      if (value is num) {
        return value.toDouble();
      }
      throw FormatException('City field "$key" must be a number.');
    }

    final latitude = requiredNumber('lat');
    if (latitude < -90 || latitude > 90) {
      throw const FormatException(
        'City field "lat" must be between -90 and 90.',
      );
    }

    final longitude = requiredNumber('lng');
    if (longitude < -180 || longitude > 180) {
      throw const FormatException(
        'City field "lng" must be between -180 and 180.',
      );
    }

    final rawElevation = json['elevation'];
    final double? elevation;
    if (rawElevation == null) {
      elevation = null;
    } else if (rawElevation is num) {
      elevation = rawElevation.toDouble();
    } else {
      throw const FormatException(
        'City field "elevation" must be a number or null.',
      );
    }

    return City(
      id: requiredString('id'),
      nameAr: requiredString('name_ar'),
      nameEn: requiredString('name_en'),
      countryAr: requiredString('country_ar'),
      countryEn: requiredString('country_en'),
      countryCode: requiredString('country_code'),
      latitude: latitude,
      longitude: longitude,
      timezone: requiredString('timezone'),
      elevation: elevation,
    );
  }

  /// Stable lowercase identifier.
  final String id;

  /// Arabic city name.
  final String nameAr;

  /// English city name.
  final String nameEn;

  /// Arabic country name.
  final String countryAr;

  /// English country name.
  final String countryEn;

  /// ISO 3166-1 alpha-2 country code.
  final String countryCode;

  /// Latitude in decimal degrees.
  final double latitude;

  /// Longitude in decimal degrees.
  final double longitude;

  /// IANA timezone identifier.
  final String timezone;

  /// Elevation above sea level in meters, when available.
  final double? elevation;
}
