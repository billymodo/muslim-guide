import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:go_router/go_router.dart';

import 'package:muslim_guide/app/theme/app_spacing.dart';
import 'package:muslim_guide/features/notifications/application/enabled_prayers_provider.dart';
import 'package:muslim_guide/features/notifications/application/permission_provider.dart';
import 'package:muslim_guide/features/notifications/domain/permission_status.dart';
import 'package:muslim_guide/features/notifications/domain/prayer_notification.dart';
import 'package:muslim_guide/features/prayer/application/calculation_method_provider.dart';
import 'package:muslim_guide/features/settings/presentation/screens/calculation_settings_screen.dart';
import 'package:muslim_guide/features/settings/presentation/widgets/settings_navigation_tile.dart';
import 'package:muslim_guide/features/settings/presentation/widgets/settings_section_header.dart';
import 'package:muslim_guide/l10n/app_localizations.dart';

/// Notifications settings screen (Phase 04 Task 8).
///
/// Sections: prayer alerts (per-prayer switches), notification status
/// with diagnostics link, adhan sound placeholder, ColorOS/device
/// guidance, open-source licenses, and about.
class NotificationsSettingsScreen extends ConsumerWidget {
  /// Creates the notifications settings screen.
  ///
  /// [onOpenDiagnostics] and [onShowLicenses] are injectable so widget
  /// tests can verify navigation without a router or a real license
  /// route. In production they are null and the default navigation runs.
  const new({
    super.key,
    this.onOpenDiagnostics,
    this.onShowLicenses,
  });

  /// Test-only diagnostics navigation (null in production).
  final void Function(BuildContext context)? onOpenDiagnostics;

  /// Test-only licenses navigation (null in production).
  final void Function(BuildContext context)? onShowLicenses;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = AppLocalizations.of(context)!;
    final permissionAsync = ref.watch(permissionStateProvider);

    return Scaffold(
      appBar: AppBar(title: Text(localizations.settings_notifications_title)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.s),
          children: [
            SettingsSectionHeader(
              title: localizations.settings_section_prayer_alerts,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.m,
              ),
              child: Text(
                localizations.settings_prayer_alerts_hint,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.s),
            ...PrayerNotification.values.map(
              (prayer) => _PrayerAlertTile(prayer: prayer),
            ),
            const _AllOffHint(),
            const CalculationSectionTile(),
            SettingsSectionHeader(
              title: localizations.settings_section_notifications,
            ),
            permissionAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.all(AppSpacing.m),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (_, _) => const SizedBox.shrink(),
              data: (state) => Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.m,
                ),
                child: Text(
                  state.notifications == PermissionStatus.granted
                      ? localizations.settings_notifications_on
                      : localizations.settings_notifications_off,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ),
            SettingsNavigationTile(
              icon: Icons.health_and_safety_outlined,
              title: localizations.settings_open_diagnostics,
              onTap: () {
                final override = onOpenDiagnostics;
                if (override != null) {
                  override(context);
                }
              },
            ),
            SettingsSectionHeader(
              title: localizations.settings_section_adhan,
            ),
            SettingsNavigationTile(
              icon: Icons.music_note_outlined,
              title: localizations.settings_adhan_sound,
              subtitle: localizations.settings_adhan_sound_coming_soon,
            ),
            SettingsSectionHeader(
              title: localizations.settings_section_device,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
              child: Text(
                localizations.settings_coloros_guide,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
            const SizedBox(height: AppSpacing.s),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
              child: Text(
                localizations.settings_oem_note,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            SettingsSectionHeader(
              title: localizations.settings_section_licenses,
            ),
            SettingsNavigationTile(
              icon: Icons.description_outlined,
              title: localizations.settings_licenses,
              onTap: () {
                final override = onShowLicenses;
                if (override != null) {
                  override(context);
                } else {
                  showLicensePage(
                    context: context,
                    applicationName: localizations.app_name,
                  );
                }
              },
            ),
            SettingsSectionHeader(
              title: localizations.settings_section_about,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
              child: Text(
                '${localizations.app_name} '
                '${localizations.settings_app_version}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }
}

/// Calculation section linking to the calculation settings screen.
///
/// Extracted so the row is unit-testable (navigation is a plain push).
class CalculationSectionTile extends ConsumerWidget {
  /// Creates the tile.
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = AppLocalizations.of(context)!;
    return SettingsNavigationTile(
      icon: Icons.calculate_outlined,
      title: localizations.settings_section_calculation,
      subtitle: CalculationSettingsScreen.methodName(
        localizations,
        ref.watch(calculationMethodProvider),
      ),
      onTap: () => context.push('/settings/calculation'),
    );
  }
}


/// Hint shown under the prayer switches when every prayer is disabled
/// (GAP-all-prayers-disabled-hint).
class _AllOffHint extends ConsumerWidget {
  /// Creates the all-off hint.
  const new();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enabledPrayers = ref.watch(enabledPrayersProvider);
    if (enabledPrayers.isNotEmpty) return const SizedBox.shrink();
    final localizations = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
      child: Text(
        localizations.settings_prayer_alerts_all_off,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

/// One per-prayer notification switch row (Task 8 prayer-alerts section).
class _PrayerAlertTile extends ConsumerWidget {
  /// Creates the tile for [prayer].
  const new({required this.prayer});

  /// The prayer this tile toggles.
  final PrayerNotification prayer;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = AppLocalizations.of(context)!;
    final enabled = ref.watch(enabledPrayersProvider).contains(prayer);
    final label = switch (prayer) {
      PrayerNotification.fajr => localizations.prayer_fajr,
      PrayerNotification.dhuhr => localizations.prayer_dhuhr,
      PrayerNotification.asr => localizations.prayer_asr,
      PrayerNotification.maghrib => localizations.prayer_maghrib,
      PrayerNotification.isha => localizations.prayer_isha,
    };
    final stateText = enabled
        ? localizations.prayer_notification_enabled
        : localizations.prayer_notification_disabled;

    return Semantics(
      label: '$label: $stateText',
      toggled: enabled,
      excludeSemantics: true,
      child: SwitchListTile(
        title: Text(label),
        value: enabled,
        onChanged: (value) => ref
            .read(enabledPrayersProvider.notifier)
            .setPrayerEnabled(prayer, value),
      ),
    );
  }
}
