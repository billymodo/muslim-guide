import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:muslim_guide/app/theme/app_spacing.dart';
import 'package:muslim_guide/features/azkar/application/azkar_providers.dart';
import 'package:muslim_guide/features/azkar/domain/azkar_category.dart';
import 'package:muslim_guide/l10n/app_localizations.dart';

/// Home card showing today's morning progress (conditional).
class TodayAzkarCard extends ConsumerWidget {
  /// Creates the card.
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = AppLocalizations.of(context)!;
    final progressAsync =
        ref.watch(todayAzkarProvider(AzkarCategoryId.morning));
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.m),
        child: progressAsync.when(
          loading: () => Text(localizations.azkar_home_loading),
          error: (error, stackTrace) =>
              Text(localizations.azkar_home_error),
          data: (progress) {
            final completed = progress?.completed ?? 0;
            final total = progress?.total ?? 0;
            return Semantics(
              button: true,
              label: localizations.azkar_home_title,
              value: '$completed / $total',
              child: InkWell(
                onTap: () => context.go('/azkar/morning'),
                child: Row(
                  children: [
                    const Icon(Icons.menu_book_outlined),
                    const SizedBox(width: AppSpacing.m),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            localizations.azkar_home_title,
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          Text('$completed / $total'),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
