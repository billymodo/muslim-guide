import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

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
}
