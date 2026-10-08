import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:muslim_guide/app/theme/app_colors.dart';
import 'package:muslim_guide/features/prayer/application/countdown_provider.dart';
import 'package:muslim_guide/features/prayer/application/prayer_times_provider.dart';
import 'package:muslim_guide/l10n/app_localizations.dart';

/// Formats [duration] as a zero-padded `HH:MM:SS` string.
String _formatCountdown(Duration duration) {
  final hours = duration.inHours.toString().padLeft(2, '0');
  final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
  final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
  return '$hours:$minutes:$seconds';
}

/// Live countdown to the next prayer, shown inside the hero card.
///
/// Displays "no more prayers today" when every prayer for the day has
/// passed (the countdown stream is empty after Isha) and renders nothing
/// while prayer times are unavailable.
class CountdownTimer extends ConsumerWidget {
  /// Creates the countdown widget.
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // The provider ticker stops at zero (Task 4); invalidate so the
    // countdown advances to the next prayer instead of freezing.
    ref.listen(countdownProvider, (previous, next) {
      if (next.valueOrNull == Duration.zero) {
        ref.invalidate(countdownProvider);
      }
    });

    final times = ref.watch(prayerTimesProvider).valueOrNull;
    if (times == null) {
      return const SizedBox.shrink();
    }

    final localizations = AppLocalizations.of(context)!;
    final next = nextPrayerTime(times, DateTime.now());
    if (next == null) {
      return Text(
        localizations.prayer_no_next_today,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodyLarge
            ?.copyWith(color: AppColors.surface),
      );
    }

    final remaining = ref.watch(countdownProvider).valueOrNull;
    final effective = (remaining == null || remaining == Duration.zero)
        ? next.difference(DateTime.now())
        : remaining;
    final clamped = effective.isNegative ? Duration.zero : effective;

    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Text(
        _formatCountdown(clamped),
        style: Theme.of(context).textTheme.headlineLarge
            ?.copyWith(color: AppColors.surface, fontWeight: FontWeight.w600),
      ),
    );
  }
}
