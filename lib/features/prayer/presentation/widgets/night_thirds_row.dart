import 'package:flutter/material.dart';

import 'package:muslim_guide/app/theme/app_spacing.dart';
import 'package:muslim_guide/features/prayer/domain/models/night_thirds.dart';
import 'package:muslim_guide/l10n/app_localizations.dart';
import 'package:muslim_guide/shared/utils/time_format.dart';

/// A two-cell row showing the first and last thirds of the night.
///
/// Hides itself entirely ([SizedBox.shrink]) when [thirds] is `null` or
/// unavailable (polar conditions).
class NightThirdsRow extends StatelessWidget {
  /// Creates the night-thirds row for [thirds].
  const new({required this.thirds, super.key});

  /// The computed thirds, or `null` while unavailable.
  final NightThirds? thirds;

  @override
  Widget build(BuildContext context) {
    final thirds = this.thirds;
    if (thirds == null || !thirds.isAvailable) {
      return const SizedBox.shrink();
    }
    final localizations = AppLocalizations.of(context)!;
    return Row(
      children: [
        Expanded(
          child: _NightThirdCell(
            label: localizations.night_first_third,
            time: thirds.firstThirdEnd!,
          ),
        ),
        const SizedBox(width: AppSpacing.m),
        Expanded(
          child: _NightThirdCell(
            label: localizations.night_last_third_tahajjud,
            time: thirds.lastThirdStart!,
          ),
        ),
      ],
    );
  }
}

/// One labeled time cell inside [NightThirdsRow].
class _NightThirdCell extends StatelessWidget {
  /// Creates a cell with [label] shown at [time].
  const new({required this.label, required this.time});

  /// The localized cell name.
  final String label;

  /// The boundary time shown in this cell.
  final DateTime time;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final timeText = formatTimeHm(time);
    return Semantics(
      label: '$label: $timeText',
      excludeSemantics: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: theme.textTheme.bodyLarge),
          const SizedBox(height: AppSpacing.xs),
          Text(
            timeText,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
