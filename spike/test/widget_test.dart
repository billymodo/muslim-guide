import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_guide_spike/main.dart';

void main() {
  testWidgets('SpikeApp يُبنى بلا استثناءات', (tester) async {
    await tester.pumpWidget(const SpikeApp());

    expect(tester.takeException(), isNull);
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
