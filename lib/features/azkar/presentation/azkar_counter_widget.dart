import 'package:flutter/material.dart';

import 'package:muslim_guide/app/theme/app_spacing.dart';
import 'package:muslim_guide/l10n/app_localizations.dart';

/// Circular-progress counter with a 48dp complete action.
class AzkarCounterWidget extends StatelessWidget {
  /// Creates the counter.
  const new({
    required this.completed,
    required this.total,
    required this.onCompleteOne,
    super.key,
  });

  /// Items completed today.
  final int completed;

  /// Items in the category.
  final int total;

  /// Called when the user completes one item.
  final VoidCallback onCompleteOne;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final fraction = total <= 0 ? 0.0 : (completed / total).clamp(0.0, 1.0);
    return Semantics(
      label: localizations.azkar_counter_semantics,
      value: '$completed / $total',
      child: Row(
        children: [
          SizedBox(
            width: 48,
            height: 48,
            child: CircularProgressIndicator(value: fraction),
          ),
          const SizedBox(width: AppSpacing.m),
          Expanded(
            child: Text(
              '$completed / $total',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              minimumSize: const Size(48, 48),
            ),
            onPressed: onCompleteOne,
            child: Text(localizations.azkar_complete_one),
          ),
        ],
      ),
    );
  }
}
