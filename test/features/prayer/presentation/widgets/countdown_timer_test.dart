import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:muslim_guide/features/prayer/presentation/widgets/countdown_timer.dart';

import '../presentation_test_utils.dart';

void main() {
  Future<void> pumpCountdown(
    WidgetTester tester, {
    required List<Override> overrides,
  }) async {
    await tester.pumpWidget(
      buildTestApp(
        child: const Center(child: CountdownTimer()),
        overrides: overrides,
      ),
    );
    await tester.pump();
    await tester.pump();
  }

  testWidgets('formats the remaining time as HH:MM:SS', (tester) async {
    await pumpCountdown(
      tester,
      overrides: [
        prayerTimesOverride(buildTestTimes()),
        countdownOverride(
          () => const Duration(hours: 1, minutes: 2, seconds: 3),
        ),
      ],
    );

    expect(find.text('01:02:03'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('shows the after-Isha message when no prayer remains', (
    tester,
  ) async {
    await pumpCountdown(
      tester,
      overrides: [
        prayerTimesOverride(buildTestTimes(dayOffset: -1)),
        emptyCountdownOverride(),
      ],
    );

    expect(find.text('لا صلاة قادمة اليوم'), findsOneWidget);
  });

  testWidgets('renders nothing while prayer times are unavailable', (
    tester,
  ) async {
    await pumpCountdown(
      tester,
      overrides: [
        prayerTimesOverride(null),
        emptyCountdownOverride(),
        locationOverride(null),
      ],
    );

    expect(find.textContaining(':'), findsNothing);
    expect(find.text('لا صلاة قادمة اليوم'), findsNothing);
  });
}
