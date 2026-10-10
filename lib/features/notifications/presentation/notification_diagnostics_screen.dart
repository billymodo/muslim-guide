import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muslim_guide/app/theme/app_spacing.dart';
import 'package:muslim_guide/features/notifications/application/permission_provider.dart';
import 'package:muslim_guide/features/notifications/domain/permission_state.dart';
import 'package:muslim_guide/features/notifications/domain/permission_status.dart';
import 'package:muslim_guide/l10n/app_localizations.dart';

/// Shows notification and exact-alarm permission status and recovery actions.
class NotificationDiagnosticsScreen extends ConsumerStatefulWidget {
  /// Creates the diagnostics screen.
  const new({super.key});

  @override
  ConsumerState<NotificationDiagnosticsScreen> createState() =>
      _NotificationDiagnosticsScreenState();
}

class _NotificationDiagnosticsScreenState
    extends ConsumerState<NotificationDiagnosticsScreen>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.invalidate(permissionStateProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final permissionAsync = ref.watch(permissionStateProvider);

    return Scaffold(
      appBar: AppBar(title: Text(localizations.notif_diag_title)),
      body: SafeArea(
        child: permissionAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) => _ErrorView(
            message: localizations.notif_diag_error,
            retryLabel: localizations.notif_diag_retry,
            onRetry: () => ref.read(permissionStateProvider.notifier).refresh(),
          ),
          data: (state) => _PermissionList(
            state: state,
            localizations: localizations,
            onRequestNotifications: () => ref
                .read(permissionStateProvider.notifier)
                .requestNotifications(),
            onRequestExactAlarms: () =>
                ref.read(permissionStateProvider.notifier).requestExactAlarms(),
            onOpenNotificationSettings: () => ref
                .read(permissionStateProvider.notifier)
                .openNotificationSettings(),
          ),
        ),
      ),
    );
  }
}

class _PermissionList extends StatelessWidget {
  const new({
    required this.state,
    required this.localizations,
    required this.onRequestNotifications,
    required this.onRequestExactAlarms,
    required this.onOpenNotificationSettings,
  });

  final PermissionState state;
  final AppLocalizations localizations;
  final VoidCallback onRequestNotifications;
  final VoidCallback onRequestExactAlarms;
  final VoidCallback onOpenNotificationSettings;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.l),
      children: [
        Text(localizations.notif_diag_explainer),
        const SizedBox(height: AppSpacing.m),
        _PermissionCard(
          title: localizations.notif_diag_notifications_title,
          status: state.notifications,
          grantedLabel: localizations.notif_diag_notifications_granted,
          deniedLabel: localizations.notif_diag_notifications_denied,
          notApplicableLabel: localizations.notif_diag_not_applicable,
          requestLabel: localizations.notif_diag_request,
          settingsLabel: localizations.notif_diag_open_settings,
          onRequest: onRequestNotifications,
          onOpenSettings: onOpenNotificationSettings,
        ),
        const SizedBox(height: AppSpacing.m),
        _PermissionCard(
          title: localizations.notif_diag_exact_alarms_title,
          status: state.exactAlarms,
          grantedLabel: localizations.notif_diag_exact_alarms_granted,
          deniedLabel: localizations.notif_diag_exact_alarms_denied,
          notApplicableLabel: localizations.notif_diag_not_applicable,
          requestLabel: localizations.notif_diag_request,
          settingsLabel: localizations.notif_diag_open_settings,
          onRequest: onRequestExactAlarms,
        ),
      ],
    );
  }
}

class _PermissionCard extends StatelessWidget {
  const new({
    required this.title,
    required this.status,
    required this.grantedLabel,
    required this.deniedLabel,
    required this.notApplicableLabel,
    required this.requestLabel,
    required this.settingsLabel,
    this.onRequest,
    this.onOpenSettings,
  });

  final String title;
  final PermissionStatus status;
  final String grantedLabel;
  final String deniedLabel;
  final String notApplicableLabel;
  final String requestLabel;
  final String settingsLabel;
  final VoidCallback? onRequest;
  final VoidCallback? onOpenSettings;

  @override
  Widget build(BuildContext context) {
    final statusText = switch (status) {
      PermissionStatus.granted => grantedLabel,
      PermissionStatus.denied => deniedLabel,
      PermissionStatus.notApplicable => notApplicableLabel,
    };

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.m),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppSpacing.s),
            Text(statusText),
            if (status == PermissionStatus.denied) ...[
              const SizedBox(height: AppSpacing.s),
              Wrap(
                spacing: AppSpacing.s,
                runSpacing: AppSpacing.s,
                children: [
                  if (onRequest case final request?)
                    OutlinedButton(
                      onPressed: request,
                      child: Text(requestLabel),
                    ),
                  if (onOpenSettings case final openSettings?)
                    FilledButton(
                      onPressed: openSettings,
                      child: Text(settingsLabel),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const new({
    required this.message,
    required this.retryLabel,
    required this.onRetry,
  });

  final String message;
  final String retryLabel;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.l),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.m),
            FilledButton(onPressed: onRetry, child: Text(retryLabel)),
          ],
        ),
      ),
    );
  }
}
