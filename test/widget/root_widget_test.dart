import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:muslim_guide/app/muslim_guide_app.dart';

void main() {
  testWidgets('renders MaterialApp with router', (tester) async {
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => const Scaffold(body: Text('test')),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(MuslimGuideApp(router: router));
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.text('test'), findsOneWidget);
  });

  testWidgets('uses Arabic as the initial locale', (tester) async {
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => Scaffold(
            body: Builder(
              builder: (context) =>
                  Text(Localizations.localeOf(context).languageCode),
            ),
          ),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(MuslimGuideApp(router: router));
    await tester.pump();

    expect(find.text('ar'), findsOneWidget);
  });
}
