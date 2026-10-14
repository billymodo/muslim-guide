import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_guide/features/azkar/presentation/azkar_counter_widget.dart';

import '../azkar_test_helpers.dart';

void main() {
  group('AzkarCounterWidget', () {
    testWidgets('shows completed/total and a 48dp action', (
      tester,
    ) async {
      var completed = 0;
      await tester.pumpWidget(
        buildAzkarTestApp(
          child: Scaffold(
            body: AzkarCounterWidget(
              completed: 1,
              total: 3,
              onCompleteOne: () => completed++,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('1 / 3'), findsOneWidget);
      final buttonSize = tester.getSize(find.byType(FilledButton));
      expect(buttonSize.height, greaterThanOrEqualTo(48));
      await tester.tap(find.text('تم'));
      expect(completed, 1);
    });
  });
}
