import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:muslim_guide/app/theme/app_spacing.dart';
import 'package:muslim_guide/features/azkar/application/azkar_providers.dart';
import 'package:muslim_guide/features/azkar/domain/azkar_category.dart';
import 'package:muslim_guide/l10n/app_localizations.dart';

/// Azkar library screen: category list, or pending-pack Empty state.
class AzkarLibraryScreen extends ConsumerWidget {
  /// Creates the library screen.
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = AppLocalizations.of(context)!;
    final packAsync = ref.watch(azkarLibraryProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.azkar_library_title),
      ),
      body: SafeArea(
        child: packAsync.when(
          loading: () =>
              Center(child: Text(localizations.azkar_library_loading)),
          error: (error, stackTrace) => _LibraryError(
            message: localizations.azkar_library_error,
            retryLabel: localizations.azkar_retry,
            onRetry: () => ref.invalidate(azkarLibraryProvider),
          ),
          data: (pack) {
            if (pack == null || pack.categories.isEmpty) {
              return _PendingPack(
                message: localizations.azkar_empty_pending_pack,
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.l),
              itemCount: pack.categories.length,
              separatorBuilder: (context, index) =>
                  const SizedBox(height: AppSpacing.s),
              itemBuilder: (context, index) {
                final category = pack.categories[index];
                return _CategoryRow(
                  categoryId: category.id,
                  title: _titleFor(localizations, category.id),
                  subtitle: '${category.totalCount}',
                );
              },
            );
          },
        ),
      ),
    );
  }

  String _titleFor(AppLocalizations localizations, AzkarCategoryId id) {
    return switch (id) {
      AzkarCategoryId.morning => localizations.azkar_category_morning,
      AzkarCategoryId.evening => localizations.azkar_category_evening,
      AzkarCategoryId.sleep => localizations.azkar_category_sleep,
      AzkarCategoryId.wakeUp => localizations.azkar_category_wake_up,
      AzkarCategoryId.tasbih => localizations.azkar_category_tasbih,
    };
  }
}

/// One category row (48dp target, semantics label).
class _CategoryRow extends StatelessWidget {
  /// Creates a category row.
  const new({
    required this.categoryId,
    required this.title,
    required this.subtitle,
  });

  /// Category opened on tap.
  final AzkarCategoryId categoryId;

  /// Localized title.
  final String title;

  /// Item count label.
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: title,
      child: SizedBox(
        height: 48,
        child: ListTile(
          title: Text(title),
          subtitle: Text(subtitle),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {},
        ),
      ),
    );
  }
}

/// Pending-pack Empty state (verified pack not approved yet — Rule 020).
class _PendingPack extends StatelessWidget {
  /// Creates the pending-pack view.
  const new({required this.message});

  /// Localized pending message.
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.l),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.menu_book_outlined, size: 48),
            const SizedBox(height: AppSpacing.m),
            Text(message, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

/// Error state with retry.
class _LibraryError extends StatelessWidget {
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
