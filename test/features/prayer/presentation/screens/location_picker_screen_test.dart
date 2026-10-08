import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:muslim_guide/features/location/domain/location_permission_status.dart';
import 'package:muslim_guide/features/location/domain/location_result.dart';
import 'package:muslim_guide/features/prayer/application/location_provider.dart';
import 'package:muslim_guide/features/prayer/presentation/screens/location_picker_screen.dart';
import 'package:muslim_guide/features/prayer/presentation/screens/prayer_times_screen.dart';

import '../presentation_test_utils.dart';

void main() {
  List<Override> pickerOverrides() {
    return [
      citiesOverride(),
      prayerTimesOverride(null),
      locationOverride(null),
    ];
  }

  Future<void> pumpPicker(
    WidgetTester tester, {
    List<Override> extraOverrides = const <Override>[],
    Locale locale = const Locale('ar'),
  }) async {
    final router = buildPresentationRouter(initialLocation: '/location-picker');
    await tester.pumpWidget(
      buildTestRouterApp(
        router: router,
        overrides: [...pickerOverrides(), ...extraOverrides],
        locale: locale,
      ),
    );
    await tester.pump();
    await tester.pump();
  }

  testWidgets('filters the bundled cities while typing', (tester) async {
    await pumpPicker(tester);

    expect(find.text('الرياض'), findsOneWidget);
    expect(find.text('القاهرة'), findsOneWidget);
    expect(find.text('مكة المكرمة'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'القاهر');
    await tester.pump();

    expect(find.text('القاهرة'), findsOneWidget);
    expect(find.text('الرياض'), findsNothing);
    expect(find.text('مكة المكرمة'), findsNothing);
  });

  testWidgets('shows the empty message when nothing matches', (tester) async {
    await pumpPicker(tester);

    await tester.enterText(find.byType(TextField), 'zzzz');
    await tester.pump();

    expect(find.text('لا نتائج'), findsOneWidget);
  });

  testWidgets('records GPS coordinates and returns to the times screen', (
    tester,
  ) async {
    final service = FakeLocationService(
      fix: LocationResult(
        latitude: 24.7136,
        longitude: 46.6753,
        accuracy: 5,
        timestamp: DateTime(2026, 10),
      ),
    );
    await pumpPicker(
      tester,
      extraOverrides: [locationServiceProvider.overrideWithValue(service)],
    );
    final container = ProviderScope.containerOf(
      tester.element(find.byType(LocationPickerScreen)),
    );

    await tester.tap(find.text('استخدام موقعي'));
    await tester.pumpAndSettle();

    final selection = container.read(locationProvider);
    expect(selection, isA<CoordinatesSelection>());
    final coordinates = selection! as CoordinatesSelection;
    expect(coordinates.latitude, 24.7136);
    expect(coordinates.longitude, 46.6753);
    expect(service.requestCount, 0);
    expect(find.byType(PrayerTimesScreen), findsOneWidget);
  });

  testWidgets('reports a denied location permission', (tester) async {
    final service = FakeLocationService(
      permission: LocationPermissionStatus.denied,
    );
    await pumpPicker(
      tester,
      extraOverrides: [locationServiceProvider.overrideWithValue(service)],
    );

    await tester.tap(find.text('استخدام موقعي'));
    await tester.pumpAndSettle();

    expect(find.text('تم رفض صلاحية الموقع'), findsOneWidget);
    expect(service.requestCount, 1);
    expect(find.byType(LocationPickerScreen), findsOneWidget);
  });

  testWidgets('reports a failed GPS fix', (tester) async {
    final service = FakeLocationService();
    await pumpPicker(
      tester,
      extraOverrides: [locationServiceProvider.overrideWithValue(service)],
    );

    await tester.tap(find.text('استخدام موقعي'));
    await tester.pumpAndSettle();

    expect(find.text('تعذر تحديد موقعك'), findsOneWidget);
    expect(find.byType(LocationPickerScreen), findsOneWidget);
  });

  testWidgets('selecting a city stores it and returns to the times screen', (
    tester,
  ) async {
    await pumpPicker(tester);
    final container = ProviderScope.containerOf(
      tester.element(find.byType(LocationPickerScreen)),
    );

    await tester.tap(find.text('القاهرة'));
    await tester.pumpAndSettle();

    final selection = container.read(locationProvider);
    expect(selection, isA<CitySelection>());
    expect((selection! as CitySelection).cityId, 'cairo');
    expect(find.byType(PrayerTimesScreen), findsOneWidget);
  });

  testWidgets('supports RTL and LTR layouts', (tester) async {
    await pumpPicker(tester);

    expect(
      Directionality.of(tester.element(find.byType(TextField))),
      TextDirection.rtl,
    );

    await pumpPicker(tester, locale: const Locale('en'));

    expect(
      Directionality.of(tester.element(find.byType(TextField))),
      TextDirection.ltr,
    );
    final localizations = await loadL10n(const Locale('en'));
    expect(
      find.text(localizations.location_picker_search_hint),
      findsOneWidget,
    );
  });
}
