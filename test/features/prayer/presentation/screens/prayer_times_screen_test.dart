import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:muslim_guide/features/adhan/application/adhan_player_provider.dart';
import 'package:muslim_guide/features/prayer/application/location_provider.dart';
import 'package:muslim_guide/features/prayer/domain/models/night_thirds.dart';
import 'package:muslim_guide/features/prayer/presentation/screens/location_picker_screen.dart';

import '../../../adhan/fake_adhan_player_service.dart';
import '../presentation_test_utils.dart';

void main() {
  List<Override> successOverrides({
    int dayOffset = 1,
    bool withFajr = true,
    bool failFirstBuild = false,
  }) {
    final adhanPlayer = FakeAdhanPlayerService();
    final times = buildTestTimes(dayOffset: dayOffset, withFajr: withFajr);
    return [
      prayerTimesOverride(times, failFirstBuild: failFirstBuild),
      nightThirdsOverride(NightThirds.unavailable),
      countdownOverride(() => const Duration(minutes: 42)),
      locationOverride(const CitySelection('riyadh')),
      citiesOverride(),
      adhanPlayerServiceProvider.overrideWithValue(adhanPlayer),
    ];
  }

  Future<void> pumpTimesScreen(
    WidgetTester tester, {
    required List<Override> overrides,
    Locale locale = const Locale('ar'),
    double? textScale,
  }) async {
    final router = buildPresentationRouter();
    await tester.pumpWidget(
      buildTestRouterApp(
        router: router,
        overrides: overrides,
        locale: locale,
        textScale: textScale,
      ),
    );
    await tester.pump();
    await tester.pump();
  }

  testWidgets('shows the skeleton while times are loading', (tester) async {
    await pumpTimesScreen(
      tester,
      overrides: [
        pendingPrayerTimesOverride(),
        pendingNightThirdsOverride(),
      ],
    );

    expect(find.byKey(const ValueKey('prayer_skeleton')), findsOneWidget);
    expect(find.text('الفجر'), findsNothing);
  });

  testWidgets('shows the empty state and opens the location picker', (
    tester,
  ) async {
    await pumpTimesScreen(
      tester,
      overrides: [
        prayerTimesOverride(null),
        nightThirdsOverride(null),
        locationOverride(null),
        citiesOverride(),
      ],
    );

    expect(find.text('لم يتم تحديد الموقع'), findsOneWidget);

    await tester.tap(find.text('تحديد الموقع'));
    await tester.pumpAndSettle();

    expect(find.byType(LocationPickerScreen), findsOneWidget);
    expect(find.text('اختيار الموقع'), findsOneWidget);
  });

  testWidgets('shows the error state and recovers on retry', (tester) async {
    await pumpTimesScreen(
      tester,
      overrides: successOverrides(failFirstBuild: true),
    );

    expect(find.text('فشل حساب المواقيت'), findsOneWidget);
    expect(FakePrayerTimesNotifier.buildCount, 1);

    await tester.tap(find.text('إعادة المحاولة'));
    await tester.pump();
    await tester.pump();

    expect(FakePrayerTimesNotifier.buildCount, 2);
    expect(find.text('05:15'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('renders the hero and every prayer row on success', (
    tester,
  ) async {
    await pumpTimesScreen(tester, overrides: successOverrides());

    for (final label in const [
      'الفجر',
      'الظهر',
      'العصر',
      'المغرب',
      'العشاء',
      'الشروق',
    ]) {
      expect(find.text(label), findsOneWidget);
    }
    expect(find.text('05:15'), findsOneWidget);
    expect(find.text('12:45'), findsOneWidget);
    expect(find.text('19:40'), findsOneWidget);
    expect(find.text('00:42:00'), findsOneWidget);
    expect(find.text('الرياض'), findsOneWidget);
    expect(find.text('ليست صلاة فرض'), findsOneWidget);

    // The fixed night-thirds row above the list pushes the bottom controls
    // below the fold in the default test surface; scroll to reveal them.
    await tester.drag(find.byType(ListView), const Offset(0, -500));
    await tester.pumpAndSettle();

    expect(find.text('إعدادات التنبيه'), findsOneWidget);
    expect(find.text('تشغيل الأذان'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('keeps the success state alive during pull-to-refresh', (
    tester,
  ) async {
    await pumpTimesScreen(tester, overrides: successOverrides());
    expect(FakePrayerTimesNotifier.buildCount, 1);

    await tester.drag(find.byType(ListView), const Offset(0, 400));
    await tester.pumpAndSettle();

    expect(FakePrayerTimesNotifier.buildCount, 2);
    expect(find.byKey(const ValueKey('prayer_skeleton')), findsNothing);
    expect(find.text('05:15'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('marks unavailable polar times as such', (tester) async {
    await pumpTimesScreen(tester, overrides: successOverrides(withFajr: false));

    expect(find.text('غير متاح'), findsOneWidget);
    expect(find.text('05:15'), findsNothing);
  });

  testWidgets('shows the after-Isha message when no prayer remains', (
    tester,
  ) async {
    await pumpTimesScreen(tester, overrides: successOverrides(dayOffset: -1));

    expect(find.text('لا صلاة قادمة اليوم'), findsOneWidget);
    expect(find.text('00:42:00'), findsNothing);
  });

  testWidgets('supports RTL, LTR, and 200% text scale', (tester) async {
    await pumpTimesScreen(tester, overrides: successOverrides());
    expect(
      Directionality.of(tester.element(find.text('الرياض'))),
      TextDirection.rtl,
    );

    await pumpTimesScreen(
      tester,
      overrides: successOverrides(),
      locale: const Locale('en'),
    );
    expect(find.text('Riyadh'), findsOneWidget);
    expect(
      Directionality.of(tester.element(find.text('Riyadh'))),
      TextDirection.ltr,
    );

    await pumpTimesScreen(tester, overrides: successOverrides(), textScale: 2);
    expect(tester.takeException(), isNull);
    expect(find.text('05:15'), findsOneWidget);
  });
}
