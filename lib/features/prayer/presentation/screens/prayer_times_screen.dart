import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:muslim_guide/app/theme/app_colors.dart';
import 'package:muslim_guide/app/theme/app_spacing.dart';
import 'package:muslim_guide/features/adhan/presentation/adhan_player_controls.dart';
import 'package:muslim_guide/features/prayer/application/countdown_provider.dart';
import 'package:muslim_guide/features/prayer/application/night_thirds_provider.dart';
import 'package:muslim_guide/features/prayer/application/prayer_times_provider.dart';
import 'package:muslim_guide/features/prayer/presentation/widgets/night_thirds_row.dart';
import 'package:muslim_guide/features/prayer/presentation/widgets/prayer_hero_card.dart';
import 'package:muslim_guide/features/prayer/presentation/widgets/prayer_time_row.dart';
import 'package:muslim_guide/l10n/app_localizations.dart';

/// Whether [time] is the next upcoming prayer (highlighted row).
bool _isNext(DateTime? time, DateTime? next) => next != null && time == next;

/// Pull-to-refresh: recomputes prayer times for the current location.
///
/// Errors are swallowed on purpose: the AsyncValue `error` branch renders
/// the failure, and the RefreshIndicator future must not surface an
/// unhandled exception.
Future<void> _refreshTimes(WidgetRef ref) {
  return ref
      .refresh(prayerTimesProvider.future)
      .then<void>((_) {})
      .catchError((_) {});
}

/// The prayer times screen: hero (location + countdown) over the list of
/// the five prayers plus the sunrise reference row.
///
/// States: loading skeleton, empty (no location), error (retry), success,
/// and pull-to-refresh (data stays visible while refreshing).
class PrayerTimesScreen extends ConsumerWidget {
  /// Creates the prayer times screen.
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = AppLocalizations.of(context)!;
    final timesAsync = ref.watch(prayerTimesProvider);

    return Scaffold(
      body: timesAsync.when(
        skipLoadingOnRefresh: true,
        loading: () => const _PrayerSkeleton(),
        error: (error, stackTrace) =>
            _ErrorView(onRetry: () => ref.invalidate(prayerTimesProvider)),
        data: (times) {
          if (times == null) {
            return _EmptyView(
              onPickLocation: () => context.push('/location-picker'),
            );
          }
          final next = nextPrayerTime(times, DateTime.now());
          final thirdsAsync = ref.watch(nightThirdsProvider);
          return Column(
            children: [
              const PrayerHeroCard(),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.l,
                  vertical: AppSpacing.s,
                ),
                child: thirdsAsync.when(
                  data: (thirds) => NightThirdsRow(thirds: thirds),
                  loading: () => const SizedBox.shrink(),
                  error: (_, _) => const SizedBox.shrink(),
                ),
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => _refreshTimes(ref),
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.s),
                    children: [
                      PrayerTimeRow(
                        label: localizations.prayer_fajr,
                        time: times.fajr,
                        isNext: _isNext(times.fajr, next),
                      ),
                      PrayerTimeRow(
                        label: localizations.prayer_dhuhr,
                        time: times.dhuhr,
                        isNext: _isNext(times.dhuhr, next),
                      ),
                      PrayerTimeRow(
                        label: localizations.prayer_asr,
                        time: times.asr,
                        isNext: _isNext(times.asr, next),
                      ),
                      PrayerTimeRow(
                        label: localizations.prayer_maghrib,
                        time: times.maghrib,
                        isNext: _isNext(times.maghrib, next),
                      ),
                      PrayerTimeRow(
                        label: localizations.prayer_isha,
                        time: times.isha,
                        isNext: _isNext(times.isha, next),
                      ),
                      PrayerTimeRow(
                        label: localizations.prayer_sunrise,
                        time: times.sunrise,
                        note: localizations.sunrise_not_prayer,
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.l,
                          vertical: AppSpacing.m,
                        ),
                        child: AdhanPlayerControls(),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.l,
                          AppSpacing.l,
                          AppSpacing.l,
                          AppSpacing.xxl,
                        ),
                        child: Tooltip(
                          message: localizations.prayer_settings_coming_soon,
                          child: FilledButton.tonal(
                            style: FilledButton.styleFrom(
                              minimumSize: const Size.fromHeight(48),
                            ),
                            // TODO(phase-04): enable with notifications.
                            onPressed: null,
                            child: Text(
                              localizations.prayer_notification_settings,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Loading state: static skeleton shaped like the hero and the rows.
class _PrayerSkeleton extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ColoredBox(
      key: const ValueKey('prayer_skeleton'),
      color: colorScheme.surface,
      child: Column(
        children: [
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primaryDark, AppColors.primary],
              ),
            ),
            child: SizedBox(width: double.infinity, height: 180),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.l),
              itemCount: 6,
              separatorBuilder: (context, index) =>
                  const SizedBox(height: AppSpacing.s),
              itemBuilder: (context, index) => Container(
                height: 48,
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(AppSpacing.s),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Empty state: no location selected yet.
class _EmptyView extends StatelessWidget {
  const new({required this.onPickLocation});

  /// Opens the location picker.
  final VoidCallback onPickLocation;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.l),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.location_off,
              size: 48,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: AppSpacing.m),
            Text(
              localizations.prayer_title,
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: AppSpacing.s),
            Text(
              localizations.prayer_no_location,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.l),
            FilledButton(
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
              onPressed: onPickLocation,
              child: Text(localizations.prayer_set_location),
            ),
          ],
        ),
      ),
    );
  }
}

/// Error state: calculation failed, with a retry action.
class _ErrorView extends StatelessWidget {
  const new({required this.onRetry});

  /// Retries the prayer times computation.
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.l),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cloud_off,
              size: 48,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: AppSpacing.m),
            Text(
              localizations.prayer_calc_error,
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: AppSpacing.l),
            FilledButton(
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
              onPressed: onRetry,
              child: Text(localizations.prayer_retry),
            ),
          ],
        ),
      ),
    );
  }
}
