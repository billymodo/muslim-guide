import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_guide/features/notifications/application/enabled_prayers_provider.dart';
import 'package:muslim_guide/features/notifications/application/permission_provider.dart';
import 'package:muslim_guide/features/notifications/domain/permission_state.dart';
import 'package:muslim_guide/features/notifications/domain/permission_status.dart';
import 'package:muslim_guide/features/notifications/domain/prayer_notification.dart';
import 'package:muslim_guide/features/settings/presentation/screens/notifications_settings_screen.dart';
import 'package:muslim_guide/l10n/app_localizations.dart';

import '../../notifications/notification_test_fakes.dart';

/// In-memory enabled-prayers notifier (no Hive).
class _MemoryEnabledPrayersNotifier extends EnabledPrayersNotifier {
  new(this.fixed);

  final Set<PrayerNotification> fixed;

  @override
  Set<PrayerNotification> build() => Set.of(fixed);

  @override
  Future<void> setPrayerEnabled(
    PrayerNotification prayer,
    bool enabled,
  ) async {
    final updated = Set<PrayerNotification>.of(state);
    if (enabled) {
      updated.add(prayer);
    } else {
      updated.remove(prayer);
    }
    state = updated;
  }
}

Widget _buildScreen({
  FakePermissionService? permissionService,
  Set<PrayerNotification>? enabled,
  void Function(BuildContext context)? onOpenDiagnostics,
  void Function(BuildContext context)? onShowLicenses,
}) {
  return ProviderScope(
    overrides: [
      // Always fake: the real service calls a MethodChannel (forbidden
      // in widget tests and hanging without a device).
      permissionServiceProvider.overrideWithValue(
        permissionService ?? FakePermissionService(),
      ),
      enabledPrayersProvider.overrideWith(
        () => _MemoryEnabledPrayersNotifier(
          enabled ?? PrayerNotification.values.toSet(),
        ),
      ),
    ],
    child: MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: NotificationsSettingsScreen(
        onOpenDiagnostics: onOpenDiagnostics,
        onShowLicenses: onShowLicenses,
      ),
    ),
  );
}

void main() {
  testWidgets('shows all six sections', (tester) async {
    await tester.pumpWidget(_buildScreen());
    await tester.pumpAndSettle();

    expect(find.text('Notification settings'), findsOneWidget);
    for (final header in [
      'Prayer alerts',
      'Notifications',
      'Adhan',
    ]) {
      expect(find.text(header), findsOneWidget);
    }
    await tester.drag(find.byType(ListView), const Offset(0, -800));
    await tester.pumpAndSettle();
    for (final header in [
      'Device',
      'Licenses',
      'About',
    ]) {
      expect(find.text(header), findsOneWidget);
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('shows five prayer switches and no sunrise entry', (
    tester,
  ) async {
    await tester.pumpWidget(_buildScreen());
    await tester.pumpAndSettle();

    expect(find.byType(Switch), findsNWidgets(5));
    expect(find.text('Sunrise'), findsNothing);
    for (final label in ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha']) {
      expect(find.text(label), findsOneWidget);
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('toggling a prayer updates its switch', (tester) async {
    await tester.pumpWidget(_buildScreen());
    await tester.pumpAndSettle();

    await tester.tap(find.byType(Switch).first);
    await tester.pump();
    await tester.pump();

    final switches = tester.widgetList<Switch>(find.byType(Switch)).toList();
    expect(switches.first.value, isFalse);
    expect(switches.skip(1).every((toggle) => toggle.value), isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('shows the permission summary', (tester) async {
    await tester.pumpWidget(
      _buildScreen(permissionService: FakePermissionService()),
    );
    await tester.pumpAndSettle();

    expect(find.text('Notifications are enabled.'), findsOneWidget);
    expect(find.text('Open notification diagnostics'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('shows the denied summary', (tester) async {
    await tester.pumpWidget(
      _buildScreen(
        permissionService: FakePermissionService(
          state: const PermissionState(
            notifications: PermissionStatus.denied,
            exactAlarms: PermissionStatus.denied,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Notifications are not fully enabled.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('diagnostics tile calls the navigation callback', (
    tester,
  ) async {
    var opened = false;
    await tester.pumpWidget(
      _buildScreen(onOpenDiagnostics: (_) => opened = true),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Open notification diagnostics'));
    await tester.pump();

    expect(opened, isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('licenses tile calls the show callback', (tester) async {
    var shown = false;
    await tester.pumpWidget(
      _buildScreen(onShowLicenses: (_) => shown = true),
    );
    await tester.pumpAndSettle();

    await tester.drag(find.byType(ListView), const Offset(0, -800));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Open-source licenses'));
    await tester.pump();

    expect(shown, isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('adhan sound entry is disabled coming-soon', (tester) async {
    await tester.pumpWidget(_buildScreen());
    await tester.pumpAndSettle();

    expect(find.text('Adhan sound'), findsOneWidget);
    expect(find.text('Coming soon'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('shows device guidance and version', (tester) async {
    await tester.pumpWidget(_buildScreen());
    await tester.pumpAndSettle();

    await tester.drag(find.byType(ListView), const Offset(0, -1200));
    await tester.pumpAndSettle();
    expect(find.textContaining('ColorOS'), findsOneWidget);
    expect(find.textContaining('MIUI'), findsOneWidget);
    expect(find.textContaining('0.1.0+1'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('renders in Arabic without overflow at 200% text scale', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          permissionServiceProvider.overrideWithValue(
            FakePermissionService(),
          ),
          enabledPrayersProvider.overrideWith(
            () => _MemoryEnabledPrayersNotifier(
              PrayerNotification.values.toSet(),
            ),
          ),
        ],
        child: const MediaQuery(
          data: MediaQueryData(
            textScaler: TextScaler.linear(2),
          ),
          child: MaterialApp(
            locale: Locale('ar'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: NotificationsSettingsScreen(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('إعدادات الإشعارات'), findsOneWidget);
    expect(find.text('تنبيهات الصلوات'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
