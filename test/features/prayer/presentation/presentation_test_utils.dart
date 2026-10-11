import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:muslim_guide/app/theme/app_theme.dart';
import 'package:muslim_guide/features/location/domain/location_permission_status.dart';
import 'package:muslim_guide/features/location/domain/location_result.dart';
import 'package:muslim_guide/features/location/domain/location_service.dart';
import 'package:muslim_guide/features/prayer/application/countdown_provider.dart';
import 'package:muslim_guide/features/prayer/application/location_provider.dart';
import 'package:muslim_guide/features/prayer/application/night_thirds_provider.dart';
import 'package:muslim_guide/features/prayer/application/prayer_times_provider.dart';
import 'package:muslim_guide/features/prayer/data/cities_loader.dart';
import 'package:muslim_guide/features/prayer/domain/models/asr_method.dart';
import 'package:muslim_guide/features/prayer/domain/models/calculation_method.dart';
import 'package:muslim_guide/features/prayer/domain/models/city.dart';
import 'package:muslim_guide/features/prayer/domain/models/high_latitude_rule.dart';
import 'package:muslim_guide/features/prayer/domain/models/location_data.dart';
import 'package:muslim_guide/features/prayer/domain/models/night_thirds.dart';
import 'package:muslim_guide/features/prayer/domain/models/prayer_times_result.dart';
import 'package:muslim_guide/features/prayer/presentation/screens/location_picker_screen.dart';
import 'package:muslim_guide/features/prayer/presentation/screens/prayer_times_screen.dart';
import 'package:muslim_guide/l10n/app_localizations.dart';

/// Sample city: Riyadh.
const City riyadhCity = City(
  id: 'riyadh',
  nameAr: 'الرياض',
  nameEn: 'Riyadh',
  countryAr: 'السعودية',
  countryEn: 'Saudi Arabia',
  countryCode: 'SA',
  latitude: 24.7136,
  longitude: 46.6753,
  timezone: 'Asia/Riyadh',
);

/// Sample city: Cairo.
const City cairoCity = City(
  id: 'cairo',
  nameAr: 'القاهرة',
  nameEn: 'Cairo',
  countryAr: 'مصر',
  countryEn: 'Egypt',
  countryCode: 'EG',
  latitude: 30.0444,
  longitude: 31.2357,
  timezone: 'Africa/Cairo',
);

/// Sample city: Mecca.
const City meccaCity = City(
  id: 'mecca',
  nameAr: 'مكة المكرمة',
  nameEn: 'Mecca',
  countryAr: 'السعودية',
  countryEn: 'Saudi Arabia',
  countryCode: 'SA',
  latitude: 21.4225,
  longitude: 39.8262,
  timezone: 'Asia/Riyadh',
);

/// The three sample cities encoded as the bundled cities JSON asset.
String fakeCitiesJson() {
  return jsonEncode(<String, Object?>{
    'cities': <Map<String, Object?>>[
      _cityJson(riyadhCity),
      _cityJson(cairoCity),
      _cityJson(meccaCity),
    ],
  });
}

Map<String, Object?> _cityJson(City city) {
  return <String, Object?>{
    'id': city.id,
    'name_ar': city.nameAr,
    'name_en': city.nameEn,
    'country_ar': city.countryAr,
    'country_en': city.countryEn,
    'country_code': city.countryCode,
    'lat': city.latitude,
    'lng': city.longitude,
    'timezone': city.timezone,
  };
}

/// Asset bundle serving [payload] for any requested key.
class FakeAssetBundle extends CachingAssetBundle {
  /// Creates a bundle that always answers with [payload].
  new(this.payload);

  /// JSON payload served by this bundle.
  final String payload;

  @override
  Future<ByteData> load(String key) async {
    return ByteData.sublistView(Uint8List.fromList(utf8.encode(payload)));
  }
}

/// Builds a full schedule for [dayOffset] days from today (or yesterday
/// with a negative value); all times are ordinary local DateTimes.
PrayerTimesResult buildTestTimes({int dayOffset = 1, bool withFajr = true}) {
  final base = DateTime.now().add(Duration(days: dayOffset));
  final date = DateTime(base.year, base.month, base.day);
  DateTime at(int hour, int minute) =>
      DateTime(date.year, date.month, date.day, hour, minute);

  return PrayerTimesResult(
    fajr: withFajr ? at(5, 15) : null,
    sunrise: at(6, 30),
    dhuhr: at(12, 45),
    asr: at(15, 20),
    maghrib: at(18, 10),
    isha: at(19, 40),
    polarState: PolarState.normal,
    location: const LocationData(
      latitude: 24.7136,
      longitude: 46.6753,
      timeZoneId: 'Asia/Riyadh',
    ),
    date: date,
    method: CalculationMethod.mwl,
    asrMethod: AsrMethod.standard,
    highLatRule: HighLatitudeRule.middleOfNight,
  );
}

/// Serves a fixed schedule; [buildCount] counts build() calls so tests can
/// assert recomputation (retry / refresh).
class FakePrayerTimesNotifier extends PrayerTimesNotifier {
  /// Creates a notifier serving [times].
  new(this.times, {this.failFirstBuild = false});

  /// Schedule returned to the provider.
  final PrayerTimesResult? times;

  /// When true, the first build() throws (error-state tests).
  final bool failFirstBuild;

  /// Total build() invocations since the last [prayerTimesOverride].
  static int buildCount = 0;

  @override
  Future<PrayerTimesResult?> build() {
    FakePrayerTimesNotifier.buildCount += 1;
    if (failFirstBuild && FakePrayerTimesNotifier.buildCount == 1) {
      throw Exception('calculation failed');
    }
    return Future<PrayerTimesResult?>.value(times);
  }
}

/// Keeps the provider in AsyncLoading for the whole test (loading state).
class PendingPrayerTimesNotifier extends PrayerTimesNotifier {
  @override
  Future<PrayerTimesResult?> build() {
    return Completer<PrayerTimesResult?>().future;
  }
}

/// Location notifier without storage: state starts at [initial] and
/// selections update memory only.
class FixedLocationNotifier extends LocationNotifier {
  /// Creates a notifier seeded with [initial].
  new(this.initial);

  /// Initial selection served by build().
  final LocationSelection? initial;

  @override
  LocationSelection? build() => initial;

  @override
  Future<void> selectCity(String cityId) async {
    state = CitySelection(cityId);
  }

  @override
  Future<void> selectCoordinates({
    required double latitude,
    required double longitude,
  }) async {
    state = CoordinatesSelection(latitude: latitude, longitude: longitude);
  }
}

/// Scripted [LocationService] for picker GPS tests.
class FakeLocationService implements LocationService {
  /// Creates a fake returning [permission] and, when set, [fix].
  new({this.permission = LocationPermissionStatus.granted, this.fix});

  /// Permission reported by check/requestPermission.
  LocationPermissionStatus permission;

  /// Fix returned by getCurrentLocation; `null` makes it throw.
  LocationResult? fix;

  /// Number of requestPermission() calls.
  int requestCount = 0;

  @override
  Future<LocationPermissionStatus> checkPermission() async => permission;

  @override
  Future<LocationPermissionStatus> requestPermission() async {
    requestCount += 1;
    return permission;
  }

  @override
  Future<bool> isServiceEnabled() async => true;

  @override
  Future<LocationResult> getCurrentLocation() async {
    final result = fix;
    if (result == null) {
      throw Exception('no fix available');
    }
    return result;
  }

  @override
  Future<void> openAppSettings() async {}

  @override
  Future<void> openLocationSettings() async {}
}

/// Overrides prayer times with a fixed [times] schedule.
Override prayerTimesOverride(
  PrayerTimesResult? times, {
  bool failFirstBuild = false,
}) {
  FakePrayerTimesNotifier.buildCount = 0;
  return prayerTimesProvider.overrideWith(
    () => FakePrayerTimesNotifier(times, failFirstBuild: failFirstBuild),
  );
}

/// Overrides prayer times with a permanently pending calculation.
Override pendingPrayerTimesOverride() {
  FakePrayerTimesNotifier.buildCount = 0;
  return prayerTimesProvider.overrideWith(PendingPrayerTimesNotifier.new);
}

/// Overrides night thirds with a fixed [thirds] value.
Override nightThirdsOverride(NightThirds? thirds) {
  return nightThirdsProvider.overrideWith(
    () => FixedNightThirdsNotifier(thirds),
  );
}

/// Serves a fixed [NightThirds] value (screen tests).
class FixedNightThirdsNotifier extends NightThirdsNotifier {
  /// Creates a notifier serving [thirds].
  new(this.thirds);

  /// Value returned to the provider.
  final NightThirds? thirds;

  @override
  Future<NightThirds?> build() => Future<NightThirds?>.value(thirds);
}

/// Overrides night thirds with a permanently pending calculation.
Override pendingNightThirdsOverride() {
  return nightThirdsProvider.overrideWith(PendingNightThirdsNotifier.new);
}

/// Keeps the night-thirds provider in AsyncLoading for the whole test.
class PendingNightThirdsNotifier extends NightThirdsNotifier {
  @override
  Future<NightThirds?> build() {
    return Completer<NightThirds?>().future;
  }
}

/// Overrides the countdown with a one-shot stream built from [value].
Override countdownOverride(Duration Function() value) {
  return countdownProvider.overrideWith(
    (ref) => Stream<Duration>.value(value()),
  );
}

/// Overrides the countdown with an empty stream (after-Isha state).
Override emptyCountdownOverride() {
  return countdownProvider.overrideWith(
    (ref) => const Stream<Duration>.empty(),
  );
}

/// Overrides the location selection without touching storage.
Override locationOverride(LocationSelection? selection) {
  return locationProvider.overrideWith(() => FixedLocationNotifier(selection));
}

/// Overrides the bundled cities with the three [fakeCitiesJson] samples.
Override citiesOverride() {
  return citiesLoaderProvider.overrideWithValue(
    CitiesLoader(assetBundle: FakeAssetBundle(fakeCitiesJson())),
  );
}

/// Builds a router exposing the two Task 5 routes.
GoRouter buildPresentationRouter({String initialLocation = '/prayer'}) {
  final router = GoRouter(
    initialLocation: initialLocation,
    routes: [
      GoRoute(path: '/prayer', builder: (_, _) => const PrayerTimesScreen()),
      GoRoute(
        path: '/location-picker',
        builder: (_, _) => const LocationPickerScreen(),
      ),
    ],
  );
  addTearDown(router.dispose);
  return router;
}

/// Wraps [child] with ProviderScope, app theme, delegates, and locale.
Widget buildTestApp({
  required Widget child,
  List<Override> overrides = const <Override>[],
  Locale locale = const Locale('ar'),
  double? textScale,
}) {
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp(
      theme: AppTheme.light(),
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: child,
      builder: (context, appChild) =>
          _scaledMediaQuery(context, appChild!, textScale),
    ),
  );
}

/// Wraps [router] with ProviderScope, app theme, delegates, and locale.
Widget buildTestRouterApp({
  required GoRouter router,
  List<Override> overrides = const <Override>[],
  Locale locale = const Locale('ar'),
  double? textScale,
}) {
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp.router(
      theme: AppTheme.light(),
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: router,
      builder: (context, appChild) =>
          _scaledMediaQuery(context, appChild!, textScale),
    ),
  );
}

Widget _scaledMediaQuery(BuildContext context, Widget child, double? scale) {
  if (scale == null) {
    return child;
  }
  return MediaQuery(
    data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(scale)),
    child: child,
  );
}

/// Loads the localized strings for [locale] (used by test assertions).
Future<AppLocalizations> loadL10n(Locale locale) {
  return AppLocalizations.delegate.load(locale);
}
