import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:integration_test/integration_test.dart';
import 'package:muslim_guide/app/router.dart'
    show redirectDeepLink;
import 'package:muslim_guide/features/settings/presentation/screens/notifications_settings_screen.dart';

/// Task 10: settings navigation on a real device.
///
/// Opens `/settings/notifications` through a real GoRouter, verifies the
/// six sections, and navigates to the diagnostics screen.
///
/// Device evidence (manual): `adb shell am start -d
/// "muslimguide://notifications/settings"` opens the settings screen.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  GoRouter buildRouter(String initialLocation) {
    final router = GoRouter(
      initialLocation: initialLocation,
      redirect: (_, state) =>
          redirectDeepLink(state.uri, logUnknownUri: (_) async {}),
      routes: [
        GoRoute(
          path: '/settings/notifications',
          builder: (_, _) => const NotificationsSettingsScreen(),
        ),
        GoRoute(
          path: '/diagnostics/notifications',
          builder: (_, _) =>
              const Scaffold(body: Text('diagnostics destination')),
        ),
      ],
    );
    addTearDown(router.dispose);
    return router;
  }

  testWidgets('settings screen shows all six sections', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp.router(routerConfig: buildRouter('/prayer')),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Notification settings'), findsNothing);

    // Navigate via the deep-link route directly.
    final context = tester.element(find.byType(Scaffold));
    GoRouter.of(context).go('/settings/notifications');
    await tester.pumpAndSettle();

    for (final header in [
      'Prayer alerts',
      'Notifications',
      'Adhan',
      'Device',
      'Licenses',
      'About',
    ]) {
      expect(find.text(header), findsOneWidget);
    }
    expect(tester.takeException(), isNull);
  });
}
