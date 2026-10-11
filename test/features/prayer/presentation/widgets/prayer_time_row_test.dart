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

  testWidgets('shows no switch without toggle params (sunrise row)', (
    tester,
  ) async {
    await pumpRow(tester, time: DateTime(2026, 10, 1, 6, 30));

    expect(find.byType(Switch), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('shows an enabled switch and reports toggles', (tester) async {
    final semantics = tester.ensureSemantics();
    var toggledTo = true;
    final localizations = await loadL10n(arabic);
    await tester.pumpWidget(
      buildTestApp(
        child: Scaffold(
          body: Center(
            child: PrayerTimeRow(
              label: localizations.prayer_fajr,
              time: DateTime(2026, 10, 1, 5, 15),
              notificationEnabled: true,
              notificationToggleSemantics: 'إشعار الصلاة مفعّل',
              onNotificationToggle: (enabled) => toggledTo = enabled,
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    final toggle = tester.widget<Switch>(find.byType(Switch));
    expect(toggle.value, isTrue);
    expect(
      find.bySemanticsLabel('الفجر: 05:15 إشعار الصلاة مفعّل'),
      findsOneWidget,
    );

    await tester.tap(find.byType(Switch));
    await tester.pump();

    expect(toggledTo, isFalse);
    expect(tester.takeException(), isNull);
    semantics.dispose();
  });

  testWidgets('dims only the label when notifications are disabled', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    final localizations = await loadL10n(arabic);
    await tester.pumpWidget(
      buildTestApp(
        child: Scaffold(
          body: Center(
            child: PrayerTimeRow(
              label: localizations.prayer_fajr,
              time: DateTime(2026, 10, 1, 5, 15),
              notificationEnabled: false,
              notificationToggleSemantics: 'إشعار الصلاة معطّل',
              onNotificationToggle: (_) {},
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    // Director 3.5: the time keeps its normal color; only the label dims.
    final timeText = tester.widget<Text>(find.text('05:15'));
    expect(timeText.style?.color, isNotNull);
    final labelText = tester.widget<Text>(find.text('الفجر'));
    expect(labelText.style?.color, isNotNull);
    expect(labelText.style?.color, isNot(timeText.style?.color));
    expect(
      find.bySemanticsLabel('الفجر: 05:15 إشعار الصلاة معطّل'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
    semantics.dispose();
  });
}
