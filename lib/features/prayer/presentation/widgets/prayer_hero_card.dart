import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:muslim_guide/app/theme/app_colors.dart';
import 'package:muslim_guide/app/theme/app_spacing.dart';
import 'package:muslim_guide/features/prayer/application/location_provider.dart';
import 'package:muslim_guide/features/prayer/domain/models/city.dart';
import 'package:muslim_guide/features/prayer/presentation/widgets/countdown_timer.dart';
import 'package:muslim_guide/l10n/app_localizations.dart';

/// The full-bleed hero header of the prayer times screen: gradient,
/// location label, live countdown, and the (disabled) settings button.
class PrayerHeroCard extends ConsumerWidget {
  /// Creates the hero card.
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = AppLocalizations.of(context)!;

    return DecoratedBox(
      // Gradient fallback until prayer_hero_haram.webp lands (Phase 04).
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.primaryDark, AppColors.primary],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.l,
            AppSpacing.m,
            AppSpacing.l,
            AppSpacing.l,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const _CityLabel(),
              const SizedBox(height: AppSpacing.s),
              const Center(child: CountdownTimer()),
              const SizedBox(height: AppSpacing.s),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: const Icon(Icons.settings),
                    color: AppColors.surface,
                    tooltip: localizations.prayer_settings_coming_soon,
                    // TODO(phase-05): open Settings when the screen exists.
                    onPressed: null,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Resolves the location label: the bundled city name for a city
/// selection, "current location" for coordinates, or a safe fallback
/// while cities are still loading.
class _CityLabel extends ConsumerWidget {
  const new();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = AppLocalizations.of(context)!;
    final selection = ref.watch(locationProvider);
    final style = Theme.of(context).textTheme.headlineLarge
        ?.copyWith(color: AppColors.surface);

    if (selection is! CitySelection) {
      return Text(
        localizations.prayer_current_location,
        textAlign: TextAlign.center,
        style: style,
      );
    }

    final cityId = selection.cityId;
    return FutureBuilder<List<City>>(
      future: ref.watch(citiesLoaderProvider).load(),
      builder: (context, snapshot) {
        final cities = snapshot.data;
        City? match;
        if (cities != null) {
          for (final city in cities) {
            if (city.id == cityId) {
              match = city;
              break;
            }
          }
        }
        final isArabic = Localizations.localeOf(context).languageCode == 'ar';
        final name = match == null
            ? localizations.prayer_current_location
            : (isArabic ? match.nameAr : match.nameEn);
        return Text(name, textAlign: TextAlign.center, style: style);
      },
    );
  }
}
