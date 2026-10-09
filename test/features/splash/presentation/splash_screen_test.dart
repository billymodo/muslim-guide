import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:muslim_guide/app/providers/bootstrap_provider.dart';
import 'package:muslim_guide/features/splash/presentation/splash_screen.dart';
import 'package:muslim_guide/l10n/app_localizations.dart';

/// Bootstrap fake that completes immediately (gate scenario: bootstrap is
/// already done by the time the splash mounts).
class _ReadyBootstrap extends Bootstrap {
  @override
  Future<void> build() async {}
}

/// Bootstrap fake whose completion is controlled by [completer].
class _PendingBootstrap extends Bootstrap {
  new(this.completer);

  /// Completes the pending bootstrap build future.
  final Completer<void> completer;

  @override
  Future<void> build() => completer.future;
}

GoRouter _testRouter() {
  final router = GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(path: '/splash', builder: (_, _) => const SplashScreen()),
      GoRoute(
        path: '/home',
        builder: (_, _) => const Scaffold(body: Text('home route')),
      ),
    ],
  );
  addTearDown(router.dispose);
  return router;
}

Widget _app({required ProviderContainer container, required GoRouter router}) {
  return UncontrolledProviderScope(
    container: container,
    child: MaterialApp.router(
      routerConfig: router,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('ar'),
    ),
  );
}

void main() {
  testWidgets('navigates to /home when bootstrap already completed', (
    tester,
  ) async {
    // BUG-5 deadlock repro: the _AppBootstrap gate finishes bootstrap before
    // the router builds SplashScreen, so the build-time listener alone would
    // never fire.
    final container = ProviderContainer(
      overrides: [bootstrapProvider.overrideWith(_ReadyBootstrap.new)],
    );
    addTearDown(container.dispose);
    await container.read(bootstrapProvider.future);
    expect(container.read(bootstrapProvider).hasValue, isTrue);

    await tester.pumpWidget(
      _app(container: container, router: _testRouter()),
    );
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text('home route'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('stays on splash until bootstrap completes, then navigates', (
    tester,
  ) async {
    // Protects the pre-gate path: splash must wait for a pending bootstrap
    // (BUG-3 spirit — no navigation before initialization) and navigate when
    // it completes afterwards.
    final completer = Completer<void>();
    final container = ProviderContainer(
      overrides: [
        bootstrapProvider.overrideWith(() => _PendingBootstrap(completer)),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      _app(container: container, router: _testRouter()),
    );
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(SplashScreen), findsOneWidget);
    expect(find.text('home route'), findsNothing);
    expect(tester.takeException(), isNull);

    completer.complete();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pumpAndSettle();

    expect(find.text('home route'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  test('settings unavailable before bootstrap provides storage (BUG-3)', () {
    // The invariant the _AppBootstrap gate enforces: settings-dependent
    // providers must throw while the Hive store is still null.
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(
      () => container.read(settingsRepositoryProvider),
      throwsA(isA<StateError>()),
    );
  });
}
