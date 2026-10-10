import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_guide/features/notifications/application/permission_provider.dart';
import 'package:muslim_guide/features/notifications/domain/permission_state.dart';
import 'package:muslim_guide/features/notifications/domain/permission_status.dart';
import 'package:muslim_guide/features/notifications/presentation/notification_diagnostics_screen.dart';
import 'package:muslim_guide/l10n/app_localizations.dart';

import '../notification_test_fakes.dart';

Widget _buildScreen(FakePermissionService service) {
  return ProviderScope(
    overrides: [permissionServiceProvider.overrideWithValue(service)],
    child: const MaterialApp(
      locale: Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: NotificationDiagnosticsScreen(),
    ),
  );
}

void main() {
  testWidgets('shows the granted state for both permissions', (tester) async {
    await tester.pumpWidget(_buildScreen(FakePermissionService()));
    await tester.pumpAndSettle();

    expect(find.text('Notification permission is granted.'), findsOneWidget);
    expect(find.text('Exact-alarm access is granted.'), findsOneWidget);
    expect(find.text('Request permission'), findsNothing);
  });

  testWidgets('shows the notification-denied recovery actions', (tester) async {
    final service = FakePermissionService(
      state: const PermissionState(
        notifications: PermissionStatus.denied,
        exactAlarms: PermissionStatus.granted,
      ),
    );
    await tester.pumpWidget(_buildScreen(service));
    await tester.pumpAndSettle();

    expect(
      find.text('Notification permission is not granted.'),
      findsOneWidget,
    );
    expect(find.text('Request permission'), findsOneWidget);
    expect(find.text('Open notification settings'), findsOneWidget);
  });

  testWidgets('shows the exact-alarm request action when denied', (
    tester,
  ) async {
    final service = FakePermissionService(
      state: const PermissionState(
        notifications: PermissionStatus.granted,
        exactAlarms: PermissionStatus.denied,
      ),
    );
    await tester.pumpWidget(_buildScreen(service));
    await tester.pumpAndSettle();

    expect(find.text('Exact-alarm access is not granted.'), findsOneWidget);
    expect(find.text('Request permission'), findsOneWidget);
    expect(find.text('Open notification settings'), findsNothing);
  });

  testWidgets('shows recovery actions for both denied permissions', (
    tester,
  ) async {
    final service = FakePermissionService(
      state: const PermissionState(
        notifications: PermissionStatus.denied,
        exactAlarms: PermissionStatus.denied,
      ),
    );
    await tester.pumpWidget(_buildScreen(service));
    await tester.pumpAndSettle();

    expect(find.text('Request permission'), findsNWidgets(2));
    expect(find.text('Open notification settings'), findsOneWidget);
  });

  testWidgets('does not show request buttons for not-applicable permissions', (
    tester,
  ) async {
    final service = FakePermissionService(
      state: const PermissionState(
        notifications: PermissionStatus.notApplicable,
        exactAlarms: PermissionStatus.notApplicable,
      ),
    );
    await tester.pumpWidget(_buildScreen(service));
    await tester.pumpAndSettle();

    expect(
      find.text('Not required on this Android version.'),
      findsNWidgets(2),
    );
    expect(find.text('Request permission'), findsNothing);
    expect(find.text('Open notification settings'), findsNothing);
  });

  testWidgets('shows progress while permission status is loading', (
    tester,
  ) async {
    final completer = Completer<PermissionState>();
    final service = FakePermissionService(getStatusCompleter: completer);
    await tester.pumpWidget(_buildScreen(service));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    completer.complete(
      const PermissionState(
        notifications: PermissionStatus.granted,
        exactAlarms: PermissionStatus.granted,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Notification permission is granted.'), findsOneWidget);
  });

  testWidgets('shows an error and retries a failed status read', (
    tester,
  ) async {
    final service = FakePermissionService(failStatusReads: true);
    await tester.pumpWidget(_buildScreen(service));
    await tester.pumpAndSettle();

    expect(
      find.text('Could not read permission status. Please retry.'),
      findsOneWidget,
    );
    service.failStatusReads = false;
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();

    expect(find.text('Notification permission is granted.'), findsOneWidget);
    expect(service.getStatusCalls, 2);
  });

  testWidgets('notification request refreshes the displayed status', (
    tester,
  ) async {
    final service = FakePermissionService(
      state: const PermissionState(
        notifications: PermissionStatus.denied,
        exactAlarms: PermissionStatus.granted,
      ),
    );
    await tester.pumpWidget(_buildScreen(service));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Request permission'));
    await tester.pumpAndSettle();

    expect(service.notificationRequests, 1);
    expect(find.text('Notification permission is granted.'), findsOneWidget);
  });

  testWidgets('exact-alarm request refreshes the displayed status', (
    tester,
  ) async {
    final service = FakePermissionService(
      state: const PermissionState(
        notifications: PermissionStatus.granted,
        exactAlarms: PermissionStatus.denied,
      ),
    );
    await tester.pumpWidget(_buildScreen(service));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Request permission'));
    await tester.pumpAndSettle();

    expect(service.exactAlarmRequests, 1);
    expect(find.text('Exact-alarm access is granted.'), findsOneWidget);
  });

  testWidgets('opens app notification settings when tapped', (tester) async {
    final service = FakePermissionService(
      state: const PermissionState(
        notifications: PermissionStatus.denied,
        exactAlarms: PermissionStatus.granted,
      ),
    );
    await tester.pumpWidget(_buildScreen(service));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Open notification settings'));
    await tester.pumpAndSettle();

    expect(service.notificationSettingsOpens, 1);
    expect(find.text('Notification permission is granted.'), findsOneWidget);
  });

  testWidgets('re-reads permission status when the app resumes', (
    tester,
  ) async {
    final service = FakePermissionService();
    await tester.pumpWidget(_buildScreen(service));
    await tester.pumpAndSettle();
    final initialReads = service.getStatusCalls;

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();

    expect(service.getStatusCalls, greaterThan(initialReads));
  });
}
