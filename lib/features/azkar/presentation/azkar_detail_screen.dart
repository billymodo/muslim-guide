import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:muslim_guide/app/theme/app_spacing.dart';
import 'package:muslim_guide/features/azkar/application/azkar_providers.dart';
import 'package:muslim_guide/features/azkar/domain/azkar_category.dart';
import 'package:muslim_guide/features/azkar/domain/dhikr.dart';
import 'package:muslim_guide/features/azkar/presentation/azkar_counter_widget.dart';
import 'package:muslim_guide/l10n/app_localizations.dart';

/// Azkar detail screen: item list + counter, or pending-pack Empty state.
class AzkarDetailScreen extends ConsumerWidget {
  /// Creates the detail screen.
  const new({required this.categoryId, super.key});

  /// Category to display.
  final AzkarCategoryId categoryId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = AppLocalizations.of(context)!;
    final packAsync = ref.watch(azkarLibraryProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(_titleFor(localizations)),
      ),
      body: SafeArea(
        child: packAsync.when(
          loading: () =>
              Center(child: Text(localizations.azkar_detail_loading)),
          error: (error, stackTrace) => _DetailError(
            message: localizations.azkar_detail_error,
            retryLabel: localizations.azkar_retry,
            onRetry: () => ref.invalidate(azkarLibraryProvider),
          ),
          data: (pack) {
            if (pack == null) {
              return Center(
                child: Text(localizations.azkar_empty_pending_pack),
              );
            }
            final items = pack.itemsFor(categoryId);
            if (items.isEmpty) {
              return Center(
                child: Text(localizations.azkar_detail_empty),
              );
            }
            return _DetailList(categoryId: categoryId, items: items);
          },
        ),
      ),
    );
  }

  String _titleFor(AppLocalizations localizations) {
    return switch (categoryId) {
      AzkarCategoryId.morning => localizations.azkar_category_morning,
      AzkarCategoryId.evening => localizations.azkar_category_evening,
      AzkarCategoryId.sleep => localizations.azkar_category_sleep,
      AzkarCategoryId.wakeUp => localizations.azkar_category_wake_up,
      AzkarCategoryId.tasbih => localizations.azkar_category_tasbih,
    };
  }
}

/// Placeholder list with a session counter header.
class _DetailList extends ConsumerWidget {
  /// Creates the detail list.
  const new({required this.categoryId, required this.items});

  /// Category being displayed.
  final AzkarCategoryId categoryId;

  /// Placeholder items.
  final List<Dhikr> items;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressAsync = ref.watch(todayAzkarProvider(categoryId));
    final progressValue = progressAsync.valueOrNull;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(AppSpacing.l),
          child: AzkarCounterWidget(
            completed: progressValue?.completed ?? 0,
            total: progressValue?.total ?? items.length,
            onCompleteOne: () =>
                ref.read(todayAzkarProvider(categoryId).notifier).completeOne(),
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
            itemCount: items.length,
            separatorBuilder: (context, index) =>
                const SizedBox(height: AppSpacing.s),
            itemBuilder: (context, index) {
              final item = items[index];
              return _DhikrCard(item: item);
            },
          ),
        ),
      ],
    );
  }
}

/// One placeholder dhikr card.
class _DhikrCard extends StatelessWidget {
  /// Creates a card.
  const new({required this.item});

  /// Placeholder item.
  final Dhikr item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      label: item.id,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.m),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                item.textPlaceholder,
                textDirection: TextDirection.rtl,
                style: theme.textTheme.bodyLarge,
              ),
              const SizedBox(height: AppSpacing.s),
              Text(
                item.virtuePlaceholder,
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: AppSpacing.s),
              Text(
                '${item.sourcePlaceholder} • ${item.repeatCount}',
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Error state with retry.
class _DetailError extends StatelessWidget {
  /// Creates an error view.
  const new({
    required this.message,
    required this.retryLabel,
    required this.onRetry,
  });

  /// Error message.
  final String message;

  /// Retry label.
  final String retryLabel;

  /// Retry callback.
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.l),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48),
            const SizedBox(height: AppSpacing.m),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.l),
            FilledButton(
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
              onPressed: onRetry,
              child: Text(retryLabel),
            ),
          ],
        ),
      ),
    );
  }
}
