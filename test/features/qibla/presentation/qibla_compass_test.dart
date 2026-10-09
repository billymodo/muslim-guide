import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_guide/features/qibla/presentation/widgets/qibla_compass.dart';
import 'package:muslim_guide/l10n/app_localizations.dart';

void main() {
  group('QiblaCompass', () {
    testWidgets('renders at relative angle 0', (tester) async {
      await _pumpCompass(tester, relativeAngle: 0);

      expect(_compassPainterFinder(), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders at relative angle 90', (tester) async {
      await _pumpCompass(tester, relativeAngle: 90);

      expect(_compassPainterFinder(), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders at relative angle 180', (tester) async {
      await _pumpCompass(tester, relativeAngle: 180);

      expect(_compassPainterFinder(), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders at relative angle 270', (tester) async {
      await _pumpCompass(tester, relativeAngle: 270);

      expect(_compassPainterFinder(), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('exposes semantic label for relative angle 0', (tester) async {
      await _pumpCompass(tester, relativeAngle: 0);

      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is Semantics &&
              widget.properties.label == 'اتجاه القبلة: 0°',
        ),
        findsOneWidget,
      );
    });

    testWidgets('updates semantic label for a non-cardinal angle', (
      tester,
    ) async {
      await _pumpCompass(tester, relativeAngle: 45);

      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is Semantics &&
              widget.properties.label == 'اتجاه القبلة: 45°',
        ),
        findsOneWidget,
      );
    });

    testWidgets('sizes itself to 85 percent of the shortest constraint', (
      tester,
    ) async {
      await tester.pumpWidget(
        _testApp(
          const Center(
            child: SizedBox(
              width: 240,
              height: 180,
              child: QiblaCompass(relativeAngle: 0),
            ),
          ),
        ),
      );

      expect(tester.getSize(_compassPainterFinder()), const Size(153, 153));
    });

    testWidgets('text scale 1.6 does not change 200-by-200 sizing', (
      tester,
    ) async {
      await tester.pumpWidget(
        _testApp(
          const Center(
            child: SizedBox(
              width: 200,
              height: 200,
              child: QiblaCompass(relativeAngle: 0),
            ),
          ),
          textScaler: const TextScaler.linear(1.6),
        ),
      );

      expect(tester.getSize(_compassPainterFinder()), const Size(170, 170));
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders in RTL without mirroring or layout failure', (
      tester,
    ) async {
      await _pumpCompass(
        tester,
        relativeAngle: 90,
        textDirection: TextDirection.rtl,
      );

      expect(_compassPainterFinder(), findsOneWidget);
      expect(
        tester.getSize(_compassPainterFinder()).shortestSide,
        greaterThan(0),
      );
      expect(tester.takeException(), isNull);
    });
  });
}

Finder _compassPainterFinder() {
  return find.descendant(
    of: find.byType(QiblaCompass),
    matching: find.byType(CustomPaint),
  );
}

Future<void> _pumpCompass(
  WidgetTester tester, {
  required double relativeAngle,
  TextDirection textDirection = TextDirection.ltr,
}) async {
  await tester.pumpWidget(
    _testApp(
      Center(
        child: SizedBox.square(
          dimension: 200,
          child: QiblaCompass(relativeAngle: relativeAngle),
        ),
      ),
      textDirection: textDirection,
    ),
  );
}

Widget _testApp(
  Widget child, {
  TextDirection textDirection = TextDirection.rtl,
  TextScaler? textScaler,
}) {
  return MaterialApp(
    locale: const Locale('ar'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Directionality(
      textDirection: textDirection,
      child: Scaffold(body: child),
    ),
    builder: (context, appChild) {
      final mediaQuery = MediaQuery.of(context);
      return MediaQuery(
        data: textScaler == null
            ? mediaQuery
            : mediaQuery.copyWith(textScaler: textScaler),
        child: appChild!,
      );
    },
  );
}
