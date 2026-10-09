import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:muslim_guide/features/prayer/application/location_provider.dart';
import 'package:muslim_guide/features/qibla/application/qibla_providers.dart';
import 'package:muslim_guide/features/qibla/presentation/qibla_screen.dart';
import 'package:muslim_guide/features/qibla/presentation/widgets/qibla_compass.dart';
import 'package:muslim_guide/l10n/app_localizations.dart';

import '../helpers/fake_compass_service.dart';
import '../helpers/qibla_test_helpers.dart';

const _cairo = CoordinatesSelection(latitude: 30.0444, longitude: 31.2357);

void main() {
  group('QiblaScreen', () {
    testWidgets('shows loading before the first provider result', (
      tester,
    ) async {
      final compass = FakeCompassService();
      await _pumpScreen(tester, compass: compass);

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows the compass when sensor and location are available', (
      tester,
    ) async {
      final compass = FakeCompassService();
      await _pumpScreen(tester, compass: compass);
      compass.emit(36);
      await tester.pump();

      expect(find.byType(QiblaCompass), findsOneWidget);
      expect(find.byTooltip('تغيير المدينة'), findsNothing);
    });

    testWidgets('shows no-sensor icon and absolute bearing', (tester) async {
      final compass = FakeCompassService();
      await _pumpScreen(tester, compass: compass);
      compass.emit(null);
      await tester.pump();

      expect(find.byIcon(Icons.explore_off), findsOneWidget);
      expect(find.text('136°'), findsOneWidget);
    });

    testWidgets('shows an error message and retry action on stream error', (
      tester,
    ) async {
      final compass = FakeCompassService();
      await _pumpScreen(tester, compass: compass);
      compass.emitError(Exception('sensor failure'));
      await tester.pump();

      expect(find.text('تعذّر قراءة البوصلة'), findsOneWidget);
      expect(find.text('إعادة المحاولة'), findsOneWidget);
    });

    testWidgets('retry invalidates the provider and resumes stream updates', (
      tester,
    ) async {
      final compass = FakeCompassService();
      await _pumpScreen(tester, compass: compass);
      compass.emitError(Exception('sensor failure'));
      await tester.pump();

      await tester.tap(find.text('إعادة المحاولة'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      compass.emit(null);
      await tester.pump();

      expect(find.byIcon(Icons.explore_off), findsOneWidget);
    });

    testWidgets('shows a location-picker action when location is unavailable', (
      tester,
    ) async {
      final compass = FakeCompassService();
      await _pumpScreen(tester, compass: compass, selection: null);
      compass.emit(null);
      await tester.pump();

      expect(find.byIcon(Icons.location_off), findsOneWidget);
      expect(find.text('لم يتم تحديد الموقع'), findsOneWidget);
      expect(
        find.widgetWithText(FilledButton, 'تغيير المدينة'),
        findsOneWidget,
      );
    });

    testWidgets('location-picker action navigates to the local marker route', (
      tester,
    ) async {
      final compass = FakeCompassService();
      await _pumpScreen(tester, compass: compass, selection: null);
      compass.emit(null);
      await tester.pump();

      await tester.tap(find.widgetWithText(FilledButton, 'تغيير المدينة'));
      await tester.pumpAndSettle();

      expect(find.text('MARKER_PICKER'), findsOneWidget);
    });

    testWidgets('AppBar edit action is present in every non-success state', (
      tester,
    ) async {
      final compass = FakeCompassService();
      await _pumpScreen(tester, compass: compass);
      expect(find.byTooltip('تغيير المدينة'), findsOneWidget);

      compass.emit(null);
      await tester.pump();
      expect(find.byTooltip('تغيير المدينة'), findsOneWidget);

      compass.emitError(Exception('sensor failure'));
      await tester.pump();
      expect(find.byTooltip('تغيير المدينة'), findsOneWidget);

      final noLocationCompass = FakeCompassService();
      await _pumpScreen(tester, compass: noLocationCompass, selection: null);
      expect(find.byTooltip('تغيير المدينة'), findsOneWidget);
      noLocationCompass.emit(0);
      await tester.pump();
      expect(find.byTooltip('تغيير المدينة'), findsOneWidget);
    });

    testWidgets('AppBar edit action is hidden in success state', (
      tester,
    ) async {
      final compass = FakeCompassService();
      await _pumpScreen(tester, compass: compass);
      compass.emit(36);
      await tester.pump();

      expect(find.byTooltip('تغيير المدينة'), findsNothing);
    });

    testWidgets('exposes the Arabic compass direction semantic label', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      try {
        final compass = FakeCompassService();
        await _pumpScreen(tester, compass: compass);
        compass.emit(36);
        await tester.pump();

        expect(find.bySemanticsLabel('اتجاه القبلة: 100°'), findsOneWidget);
      } finally {
        semantics.dispose();
      }
    });

    testWidgets('uses RTL directionality for the Arabic locale', (
      tester,
    ) async {
      final compass = FakeCompassService();
      await _pumpScreen(tester, compass: compass);

      expect(
        Directionality.of(tester.element(find.byType(QiblaScreen))),
        TextDirection.rtl,
      );
    });

    testWidgets('does not overflow at 1.6 text scale', (tester) async {
      tester.view
        ..physicalSize = const Size(360, 640)
        ..devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final compass = FakeCompassService();
      await _pumpScreen(
        tester,
        compass: compass,
        textScaler: const TextScaler.linear(1.6),
      );
      compass.emit(36);
      await tester.pump();

      expect(tester.takeException(), isNull);
    });

    testWidgets('updates compass semantic angle as headings change', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      try {
        final compass = FakeCompassService();
        await _pumpScreen(tester, compass: compass);
        compass.emit(36);
        await tester.pump();
        expect(find.bySemanticsLabel('اتجاه القبلة: 100°'), findsOneWidget);

        compass.emit(46);
        await tester.pump();

        expect(find.bySemanticsLabel('اتجاه القبلة: 90°'), findsOneWidget);
      } finally {
        semantics.dispose();
      }
    });

    testWidgets('keeps no-location message when sensor is available', (
      tester,
    ) async {
      final compass = FakeCompassService();
      await _pumpScreen(tester, compass: compass, selection: null);
      compass.emit(90);
      await tester.pump();

      expect(find.byIcon(Icons.location_off), findsOneWidget);
      expect(find.text('لم يتم تحديد الموقع'), findsOneWidget);
      expect(find.byType(QiblaCompass), findsNothing);
    });
  });
}

Future<void> _pumpScreen(
  WidgetTester tester, {
  required FakeCompassService compass,
  LocationSelection? selection = _cairo,
  TextScaler? textScaler,
}) async {
  final router = GoRouter(
    initialLocation: '/qibla',
    routes: [
      GoRoute(path: '/qibla', builder: (context, state) => const QiblaScreen()),
      GoRoute(
        path: '/location-picker',
        builder: (context, state) => const Text('MARKER_PICKER'),
      ),
    ],
  );
  addTearDown(() async {
    await tester.pumpWidget(const SizedBox.shrink());
    await compass.dispose();
    router.dispose();
  });

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        compassServiceProvider.overrideWithValue(compass),
        locationProvider.overrideWith(() => FixedLocationNotifier(selection)),
        citiesLoaderProvider.overrideWithValue(FixedCitiesLoader(const [])),
      ],
      child: MaterialApp.router(
        locale: const Locale('ar'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: router,
        builder: (context, child) {
          final mediaQuery = MediaQuery.of(context);
          return MediaQuery(
            data: textScaler == null
                ? mediaQuery
                : mediaQuery.copyWith(textScaler: textScaler),
            child: child!,
          );
        },
      ),
    ),
  );
}
