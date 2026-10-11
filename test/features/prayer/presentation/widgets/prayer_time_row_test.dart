import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:muslim_guide/features/prayer/presentation/widgets/prayer_time_row.dart';

import '../presentation_test_utils.dart';

void main() {
  const arabic = Locale('ar');

  Future<void> pumpRow(
    WidgetTester tester, {
    DateTime? time,
    bool isNext = false,
    String? note,
    String? inlineNote,
  }) async {
    final localizations = await loadL10n(arabic);
    await tester.pumpWidget(
      buildTestApp(
        child: Center(
          child: PrayerTimeRow(
            label: localizations.prayer_fajr,
            time: time,
            isNext: isNext,
            note: note,
            inlineNote: inlineNote,
          ),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('renders the prayer label and HH:mm time', (tester) async {
    await pumpRow(tester, time: DateTime(2026, 10, 1, 5, 15));

    expect(find.text('الفجر'), findsOneWidget);
    expect(find.text('05:15'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('shows the unavailable marker for null times', (tester) async {
    await pumpRow(tester);

    expect(find.text('غير متاح'), findsOneWidget);
    expect(find.text('05:15'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('highlights the next prayer with semantics', (tester) async {
    final semantics = tester.ensureSemantics();

    await pumpRow(tester, time: DateTime(2026, 10, 1, 5, 15), isNext: true);

    expect(find.bySemanticsLabel('الفجر: 05:15'), findsOneWidget);
    final timeText = tester.widget<Text>(find.text('05:15'));
    expect(timeText.style?.fontWeight, FontWeight.w700);
    semantics.dispose();
  });

  testWidgets('renders the sunrise note in an RTL layout', (tester) async {
    await pumpRow(
      tester,
      time: DateTime(2026, 10, 1, 6, 30),
      note: 'ليست صلاة فرض',
    );

    expect(find.text('ليست صلاة فرض'), findsOneWidget);
    final element = tester.element(find.byType(PrayerTimeRow));
    expect(Directionality.of(element), TextDirection.rtl);
  });

  testWidgets('renders the inline note beside the label (Commit A)', (
    tester,
  ) async {
    await pumpRow(
      tester,
      time: DateTime(2026, 10, 1, 6, 30),
      inlineNote: 'ليست صلاة فريضة',
    );

    // Same row: label + inline note + time all visible, no overflow.
    expect(find.text('الفجر'), findsOneWidget);
    expect(find.text('ليست صلاة فريضة'), findsOneWidget);
    expect(find.text('06:30'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
