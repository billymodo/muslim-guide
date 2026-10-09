import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:muslim_guide/features/prayer/application/location_provider.dart';
import 'package:muslim_guide/features/prayer/presentation/widgets/prayer_hero_card.dart';

import '../presentation_test_utils.dart';

void main() {
  List<Override> heroOverrides(LocationSelection selection) {
    return [
      prayerTimesOverride(buildTestTimes()),
      countdownOverride(() => const Duration(minutes: 42)),
      locationOverride(selection),
      citiesOverride(),
    ];
  }

  Future<void> pumpHero(
    WidgetTester tester, {
    required LocationSelection selection,
  }) async {
    await tester.pumpWidget(
      buildTestApp(
        child: const PrayerHeroCard(),
        overrides: heroOverrides(selection),
      ),
    );
    await tester.pump();
    await tester.pump();
  }

  testWidgets('shows the bundled city name for a city selection', (
    tester,
  ) async {
    await pumpHero(tester, selection: const CitySelection('riyadh'));

    expect(find.text('الرياض'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('falls back to the current-location label for coordinates', (
    tester,
  ) async {
    await pumpHero(
      tester,
      selection: const CoordinatesSelection(latitude: 24.7, longitude: 46.7),
    );

    expect(find.text('الموقع الحالي'), findsOneWidget);
  });

  testWidgets('renders a disabled settings action with a tooltip', (
    tester,
  ) async {
    await pumpHero(tester, selection: const CitySelection('riyadh'));

    final icon = find.byIcon(Icons.settings);
    expect(icon, findsOneWidget);
    final button = tester.widget<IconButton>(
      find.ancestor(of: icon, matching: find.byType(IconButton)),
    );
    expect(button.onPressed, isNull);
    expect(find.byTooltip('قريباً'), findsOneWidget);
  });

  testWidgets('shows an enabled change-city action beside settings', (
    tester,
  ) async {
    await pumpHero(tester, selection: const CitySelection('riyadh'));

    // BUG-2 (Option A): change-city button present, enabled, localized (ar).
    final changeCity = find.byIcon(Icons.edit_location_alt);
    expect(changeCity, findsOneWidget);
    expect(find.byTooltip('تغيير المدينة'), findsOneWidget);
    final changeCityButton = tester.widget<IconButton>(
      find.ancestor(of: changeCity, matching: find.byType(IconButton)),
    );
    expect(changeCityButton.onPressed, isNotNull);

    // The disabled settings button is unchanged.
    final settings = find.byIcon(Icons.settings);
    expect(settings, findsOneWidget);
    final settingsButton = tester.widget<IconButton>(
      find.ancestor(of: settings, matching: find.byType(IconButton)),
    );
    expect(settingsButton.onPressed, isNull);
  });

  testWidgets('navigates to the location picker when change city is tapped', (
    tester,
  ) async {
    final router = GoRouter(
      initialLocation: '/prayer',
      routes: [
        GoRoute(
          path: '/prayer',
          builder: (_, _) => const PrayerHeroCard(),
        ),
        GoRoute(
          path: '/location-picker',
          builder: (_, _) =>
              const Scaffold(body: Text('location picker route')),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      buildTestRouterApp(
        router: router,
        overrides: heroOverrides(const CitySelection('riyadh')),
      ),
    );
    await tester.pump();
    await tester.pump();

    await tester.tap(find.byIcon(Icons.edit_location_alt));
    await tester.pump();
    await tester.pump();

    expect(find.text('location picker route'), findsOneWidget);
  });
}
