/*
Prayer-time formulas adapted from PrayTimes.js v2.5.
Copyright (C) 2007-2017 PrayTimes.org (Hamid Zarrabi-Zadeh).
Licensed under GNU LGPL v3.0. Original source:
https://praytimes.org/code/v2/js/PrayTimes.js
*/

import 'dart:math' as math;

import 'package:muslim_guide/features/prayer/domain/exceptions/prayer_calculation_exception.dart';
import 'package:muslim_guide/features/prayer/domain/models/asr_method.dart';
import 'package:muslim_guide/features/prayer/domain/models/calculation_method.dart';
import 'package:muslim_guide/features/prayer/domain/models/high_latitude_rule.dart';
import 'package:muslim_guide/features/prayer/domain/models/location_data.dart';
import 'package:muslim_guide/features/prayer/domain/models/prayer_times_result.dart';
import 'package:timezone/timezone.dart' as tz;

typedef _CalculationParameters = ({
  double fajrAngle,
  double? maghribAngle,
  double? ishaAngle,
  double? ishaAfterMaghribMinutes,
});

/// Calculates prayer times from solar position without Flutter dependencies.
class PrayerCalculator {
  /// Creates a stateless prayer calculator.
  const new();

  /// Calculates local prayer times for [date] and [location].
  ///
  /// Times that cannot be determined astronomically remain `null`; no
  /// neighboring-day or neighboring-location substitute is applied.
  PrayerTimesResult calculate({
    required LocationData location,
    required DateTime date,
    CalculationMethod method = CalculationMethod.mwl,
    AsrMethod asrMethod = AsrMethod.standard,
    HighLatitudeRule highLatRule = HighLatitudeRule.middleOfNight,
  }) {
    _validateLocation(location);
    final timezone = _getTimezone(location.timeZoneId);
    final parameters = _parametersFor(method);
    final julianDate =
        _julianDate(date.year, date.month, date.day) - location.longitude / 360;
    final riseSetAngle = 0.833 + 0.0347 * math.sqrt(location.elevationMeters);
    final polarState = _polarState(
      location.latitude,
      _sunPosition(julianDate + 0.5).declination,
      riseSetAngle,
    );

    final fajr = _sunAngleTime(
      parameters.fajrAngle,
      5 / 24,
      julianDate,
      location.latitude,
      beforeNoon: true,
    );
    final sunrise = _sunAngleTime(
      riseSetAngle,
      6 / 24,
      julianDate,
      location.latitude,
      beforeNoon: true,
    );
    final dhuhr = _midDay(12 / 24, julianDate);
    final asr = _asrTime(
      asrMethod == AsrMethod.standard ? 1 : 2,
      13 / 24,
      julianDate,
      location.latitude,
    );
    final sunset = _sunAngleTime(
      riseSetAngle,
      18 / 24,
      julianDate,
      location.latitude,
      beforeNoon: false,
    );
    final maghrib = parameters.maghribAngle == null
        ? sunset
        : _sunAngleTime(
            parameters.maghribAngle!,
            18 / 24,
            julianDate,
            location.latitude,
            beforeNoon: false,
          );

    var isha = parameters.ishaAngle == null
        ? _addMinutes(maghrib, parameters.ishaAfterMaghribMinutes!)
        : _sunAngleTime(
            parameters.ishaAngle!,
            18 / 24,
            julianDate,
            location.latitude,
            beforeNoon: false,
          );

    var localFajr = _toLocalSolarTime(
      fajr,
      timezone,
      date,
      location.longitude,
    );
    final localSunrise = _toLocalSolarTime(
      sunrise,
      timezone,
      date,
      location.longitude,
    );
    final localDhuhr = _toLocalSolarTime(
      dhuhr,
      timezone,
      date,
      location.longitude,
    );
    final localAsr = _toLocalSolarTime(
      asr,
      timezone,
      date,
      location.longitude,
    );
    final localSunset = _toLocalSolarTime(
      sunset,
      timezone,
      date,
      location.longitude,
    );
    var localMaghrib = _toLocalSolarTime(
      maghrib,
      timezone,
      date,
      location.longitude,
    );
    isha = _toLocalSolarTime(isha, timezone, date, location.longitude);

    final nightLength = localSunrise == null || localSunset == null
        ? null
        : _fixHour(localSunrise - localSunset);
    if (highLatRule != HighLatitudeRule.none && nightLength != null) {
      localFajr = _adjustHighLatitudeTime(
        localFajr,
        localSunrise,
        parameters.fajrAngle,
        nightLength,
        highLatRule,
        beforeBase: true,
      );
      if (parameters.maghribAngle != null) {
        localMaghrib = _adjustHighLatitudeTime(
          localMaghrib,
          localSunset,
          parameters.maghribAngle!,
          nightLength,
          highLatRule,
        );
      }
      if (parameters.ishaAngle != null) {
        isha = _adjustHighLatitudeTime(
          isha,
          localSunset,
          parameters.ishaAngle!,
          nightLength,
          highLatRule,
        );
      }
    }

    return PrayerTimesResult(
      fajr: _toDateTime(timezone, date, localFajr),
      sunrise: _toDateTime(timezone, date, localSunrise),
      dhuhr: _toDateTime(timezone, date, localDhuhr),
      asr: _toDateTime(timezone, date, localAsr),
      maghrib: _toDateTime(timezone, date, localMaghrib),
      isha: _toDateTime(timezone, date, isha),
      polarState: polarState,
      location: location,
      date: date,
      method: method,
      asrMethod: asrMethod,
      highLatRule: highLatRule,
    );
  }

  static _CalculationParameters _parametersFor(CalculationMethod method) {
    return switch (method) {
      CalculationMethod.mwl => (
        fajrAngle: 18,
        maghribAngle: null,
        ishaAngle: 17,
        ishaAfterMaghribMinutes: null,
      ),
      CalculationMethod.egyptian => (
        fajrAngle: 19.5,
        maghribAngle: null,
        ishaAngle: 17.5,
        ishaAfterMaghribMinutes: null,
      ),
      CalculationMethod.ummAlQura => (
        fajrAngle: 18.5,
        maghribAngle: null,
        ishaAngle: null,
        ishaAfterMaghribMinutes: 90,
      ),
      CalculationMethod.karachi => (
        fajrAngle: 18,
        maghribAngle: null,
        ishaAngle: 18,
        ishaAfterMaghribMinutes: null,
      ),
      CalculationMethod.isna => (
        fajrAngle: 15,
        maghribAngle: null,
        ishaAngle: 15,
        ishaAfterMaghribMinutes: null,
      ),
      CalculationMethod.tehran => (
        fajrAngle: 17.7,
        maghribAngle: 4.5,
        ishaAngle: 14,
        ishaAfterMaghribMinutes: null,
      ),
      CalculationMethod.jafari => (
        fajrAngle: 16,
        maghribAngle: 4,
        ishaAngle: 14,
        ishaAfterMaghribMinutes: null,
      ),
    };
  }

  static tz.Location _getTimezone(String timezoneId) {
    try {
      return tz.getLocation(timezoneId);
    } on tz.LocationNotFoundException catch (error) {
      throw PrayerCalculationException(
        'Unknown IANA timezone "$timezoneId": ${error.msg}',
      );
    } on tz.TimeZoneInitException catch (error) {
      throw PrayerCalculationException(
        'Timezone data has not been initialized: ${error.msg}',
      );
    }
  }

  static void _validateLocation(LocationData location) {
    if (!location.latitude.isFinite ||
        location.latitude < -90 ||
        location.latitude > 90) {
      throw const PrayerCalculationException(
        'Latitude must be finite and between -90 and 90 degrees.',
      );
    }
    if (!location.longitude.isFinite ||
        location.longitude < -180 ||
        location.longitude > 180) {
      throw const PrayerCalculationException(
        'Longitude must be finite and between -180 and 180 degrees.',
      );
    }
    if (!location.elevationMeters.isFinite || location.elevationMeters < 0) {
      throw const PrayerCalculationException(
        'Elevation must be finite and non-negative.',
      );
    }
  }

  static double? _sunAngleTime(
    double angle,
    double timeFraction,
    double julianDate,
    double latitude, {
    required bool beforeNoon,
  }) {
    final declination = _sunPosition(julianDate + timeFraction).declination;
    final noon = _midDay(timeFraction, julianDate);
    final hourAngle = _hourAngle(angle, latitude, declination);
    if (hourAngle == null) return null;
    return noon + (beforeNoon ? -hourAngle : hourAngle);
  }

  static double? _hourAngle(double angle, double latitude, double declination) {
    final denominator = _cos(declination) * _cos(latitude);
    if (denominator.abs() < 1e-15) return null;

    final cosine =
        (-_sin(angle) - _sin(declination) * _sin(latitude)) / denominator;
    if (!cosine.isFinite || cosine < -1 || cosine > 1) return null;
    return math.acos(cosine) * 12 / math.pi;
  }

  static double? _asrTime(
    int factor,
    double timeFraction,
    double julianDate,
    double latitude,
  ) {
    final declination = _sunPosition(julianDate + timeFraction).declination;
    final tangent = math.tan(_toRadians((latitude - declination).abs()));
    final cotangent = factor + tangent;
    if (!cotangent.isFinite) return null;

    final angle = -_toDegrees(math.atan(1 / cotangent));
    return _sunAngleTime(
      angle,
      timeFraction,
      julianDate,
      latitude,
      beforeNoon: false,
    );
  }

  static double _midDay(double timeFraction, double julianDate) {
    final equation = _sunPosition(julianDate + timeFraction).equation;
    return _fixHour(12 - equation);
  }

  static ({double declination, double equation}) _sunPosition(
    double julianDate,
  ) {
    final days = julianDate - 2451545.0;
    final meanAnomaly = _fixAngle(357.529 + 0.98560028 * days);
    final meanLongitude = _fixAngle(280.459 + 0.98564736 * days);
    final eclipticLongitude = _fixAngle(
      meanLongitude + 1.915 * _sin(meanAnomaly) + 0.020 * _sin(2 * meanAnomaly),
    );
    final obliquity = 23.439 - 0.00000036 * days;
    final rightAscension =
        _toDegrees(
          math.atan2(
            _cos(obliquity) * _sin(eclipticLongitude),
            _cos(eclipticLongitude),
          ),
        ) /
        15;
    final equation = meanLongitude / 15 - _fixHour(rightAscension);
    final declination = _toDegrees(
      math.asin(_sin(obliquity) * _sin(eclipticLongitude)),
    );

    return (declination: declination, equation: equation);
  }

  static PolarState _polarState(
    double latitude,
    double declination,
    double horizonAngle,
  ) {
    final latitudeSine = _sin(latitude);
    final latitudeCosine = _cos(latitude);
    final declinationSine = _sin(declination);
    final declinationCosine = _cos(declination);
    final maximumAltitude = _toDegrees(
      math.asin(
        (latitudeSine * declinationSine + latitudeCosine * declinationCosine)
            .clamp(-1.0, 1.0),
      ),
    );
    final minimumAltitude = _toDegrees(
      math.asin(
        (latitudeSine * declinationSine - latitudeCosine * declinationCosine)
            .clamp(-1.0, 1.0),
      ),
    );

    if (maximumAltitude < -horizonAngle) return PolarState.polarNight;
    if (minimumAltitude > -horizonAngle) return PolarState.polarDay;
    return PolarState.normal;
  }

  static double? _adjustHighLatitudeTime(
    double? time,
    double? baseTime,
    double angle,
    double nightLength,
    HighLatitudeRule rule, {
    bool beforeBase = false,
  }) {
    if (baseTime == null) return time;
    final portion = switch (rule) {
      HighLatitudeRule.middleOfNight => 0.5,
      HighLatitudeRule.seventhOfNight => 1 / 7,
      HighLatitudeRule.twilightAngle => angle / 60,
      HighLatitudeRule.none => 0.0,
    };
    final allowedDifference = portion * nightLength;
    final difference = time == null
        ? double.infinity
        : beforeBase
        ? _fixHour(baseTime - time)
        : _fixHour(time - baseTime);
    if (difference > allowedDifference) {
      return baseTime + (beforeBase ? -allowedDifference : allowedDifference);
    }
    return time;
  }

  static double? _addMinutes(double? time, double minutes) {
    if (time == null) return null;
    return time + minutes / 60;
  }

  static double? _toLocalSolarTime(
    double? solarTime,
    tz.Location timezone,
    DateTime date,
    double longitude,
  ) {
    if (solarTime == null) return null;
    final utcHour = solarTime - longitude / 15;
    final utcInstant = DateTime.utc(date.year, date.month, date.day).add(
      Duration(seconds: (utcHour * 3600).round()),
    );
    final timezoneOffset =
        tz.TZDateTime.from(utcInstant, timezone).timeZoneOffset.inSeconds /
        3600;
    return solarTime + timezoneOffset - longitude / 15;
  }

  static DateTime? _toDateTime(
    tz.Location timezone,
    DateTime date,
    double? hours,
  ) {
    if (hours == null || !hours.isFinite) return null;
    final totalSeconds = (hours * Duration.secondsPerHour).round();
    final dayOffset = (totalSeconds / Duration.secondsPerDay).floor();
    final secondsOfDay = totalSeconds - dayOffset * Duration.secondsPerDay;
    final localDate = DateTime.utc(date.year, date.month, date.day).add(
      Duration(days: dayOffset),
    );
    return tz.TZDateTime(
      timezone,
      localDate.year,
      localDate.month,
      localDate.day,
      secondsOfDay ~/ Duration.secondsPerHour,
      secondsOfDay ~/ Duration.secondsPerMinute % Duration.secondsPerMinute,
      secondsOfDay % Duration.secondsPerMinute,
    );
  }

  static double _julianDate(int year, int month, int day) {
    var adjustedYear = year;
    var adjustedMonth = month;
    if (adjustedMonth <= 2) {
      adjustedYear--;
      adjustedMonth += 12;
    }

    final century = (adjustedYear / 100).floor();
    final correction = 2 - century + (century / 4).floor();
    return (365.25 * (adjustedYear + 4716)).floor() +
        (30.6001 * (adjustedMonth + 1)).floor() +
        day +
        correction -
        1524.5;
  }

  static double _fixAngle(double angle) => angle - 360 * (angle / 360).floor();

  static double _fixHour(double hour) => hour - 24 * (hour / 24).floor();

  static double _sin(double degrees) => math.sin(_toRadians(degrees));

  static double _cos(double degrees) => math.cos(_toRadians(degrees));

  static double _toRadians(double degrees) => degrees * math.pi / 180;

  static double _toDegrees(double radians) => radians * 180 / math.pi;
}
