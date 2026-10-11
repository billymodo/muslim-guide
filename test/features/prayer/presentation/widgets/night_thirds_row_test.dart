import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:muslim_guide/features/prayer/domain/models/night_thirds.dart';
import 'package:muslim_guide/features/prayer/presentation/widgets/night_thirds_row.dart';

import '../presentation_test_utils.dart';

void main() {
  const arabic = Locale('ar');
  const english = Locale('en');

  NightThirds ordinaryThirds() => NightThirds(
        firstThirdStart: DateTime(2026, 10, 11, 18),
        firstThirdEnd: DateTime(2026, 10, 11, 22),
        lastThirdStart: DateTime(2026, 10, 12, 2),
        lastThirdEnd: DateTime(2026, 10, 12, 6),
      );

  Future<void> pumpRow(
    WidgetTester tester, {
    required NightThirds? thirds,
    Locale locale = arabic,
  }) async {
    await tester.pumpWidget(
      buildTestApp(
        locale: locale,
        child: Center(child: NightThirdsRow(thirds: thirds)),
      ),
    );
    await tester.pump();
  }

  testWidgets('shows both cells on an ordinary night', (tester) async {
    await pumpRow(tester, thirds: ordinaryThirds());

    expect(find.text('الثلث الأول'), findsOneWidget);
    expect(find.text('الثلث الأخير (التهجد)'), findsOneWidget);
    expect(find.text('22:00'), findsOneWidget);
    expect(find.text('02:00'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('hides everything for polar input', (tester) async {
    await pumpRow(
      tester,
      thirds: NightThirds.unavailable,
    );

    expect(find.text('الثلث الأول'), findsNothing);
    expect(find.text('الثلث الأخير (التهجد)'), findsNothing);
    expect(find.byType(SizedBox), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('formats times as zero-padded HH:mm', (tester) async {
    await pumpRow(
      tester,
      thirds: NightThirds(
        firstThirdStart: DateTime(2026, 10, 11, 18, 5),
        firstThirdEnd: DateTime(2026, 10, 11, 21, 5),
        lastThirdStart: DateTime(2026, 10, 12, 2, 5),
        lastThirdEnd: DateTime(2026, 10, 12, 5, 5),
      ),
    );

    expect(find.text('21:05'), findsOneWidget);
    expect(find.text('02:05'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('renders in LTR English layout', (tester) async {
    await pumpRow(tester, thirds: ordinaryThirds(), locale: english);

    expect(find.text('First Third'), findsOneWidget);
    expect(find.text('Last Third (Tahajjud)'), findsOneWidget);
    final element = tester.element(find.byType(NightThirdsRow));
    expect(Directionality.of(element), TextDirection.ltr);
    expect(tester.takeException(), isNull);
  });
}
