import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_guide/main.dart';

/// اختبارات الجذر — Phase 00.
void main() {
  testWidgets('الجذر يُبنى بلا استثناءات', (tester) async {
    await tester.pumpWidget(const MuslimGuideApp());

    expect(tester.takeException(), isNull);
    expect(find.byType(SizedBox), findsWidgets);
  });
}
