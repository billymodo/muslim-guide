import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:muslim_guide/app/router.dart';

GoRouter _buildRouter({
  required Future<void> Function(String uri) logUnknownUri,
}) {
  return GoRouter(
    initialLocation: '/prayer',
    redirect: (_, state) =>
        redirectDeepLink(state.uri, logUnknownUri: logUnknownUri),
    routes: [
      GoRoute(
        path: '/prayer',
        builder: (_, _) => const Scaffold(body: Text('prayer destination')),
      ),
      GoRoute(
        path: '/qibla',
        builder: (_, _) => const Scaffold(body: Text('qibla destination')),
      ),
      GoRoute(
        path: '/location-picker',
        builder: (_, _) => const Scaffold(body: Text('location destination')),
      ),
    ],
  );
}

Future<void> _openDeepLink(
  WidgetTester tester,
  GoRouter router,
  String uri,
) async {
  await tester.pumpWidget(MaterialApp.router(routerConfig: router));
  router.go(uri);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('routes prayer deep link to the prayer screen', (tester) async {
    final router = _buildRouter(logUnknownUri: (_) async {});
    addTearDown(router.dispose);

    await _openDeepLink(tester, router, 'muslimguide://prayer/now');

    expect(find.text('prayer destination'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('routes qibla deep link to the qibla screen', (tester) async {
    final router = _buildRouter(logUnknownUri: (_) async {});
    addTearDown(router.dispose);

    await _openDeepLink(tester, router, 'muslimguide://qibla/show');

    expect(find.text('qibla destination'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('routes location picker deep link to the location screen', (
    tester,
  ) async {
    final router = _buildRouter(logUnknownUri: (_) async {});
    addTearDown(router.dispose);

    await _openDeepLink(tester, router, 'muslimguide://location/pick');

    expect(find.text('location destination'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('routes unknown deep link to prayer and logs safe URI', (
    tester,
  ) async {
    final loggedUris = <String>[];
    final router = _buildRouter(
      logUnknownUri: (uri) async => loggedUris.add(uri),
    );
    addTearDown(router.dispose);

    await _openDeepLink(
      tester,
      router,
      'muslimguide://unknown/route?token=private#fragment',
    );

    expect(find.text('prayer destination'), findsOneWidget);
    expect(loggedUris, ['muslimguide://unknown/route']);
    expect(tester.takeException(), isNull);
  });

  testWidgets('does not process ordinary internal navigation as a deep link', (
    tester,
  ) async {
    final loggedUris = <String>[];
    final router = _buildRouter(
      logUnknownUri: (uri) async => loggedUris.add(uri),
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    router.go('/qibla');
    await tester.pumpAndSettle();

    expect(find.text('qibla destination'), findsOneWidget);
    expect(loggedUris, isEmpty);
    expect(tester.takeException(), isNull);
  });
}
