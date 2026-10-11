import 'package:flutter/material.dart';

import 'package:muslim_guide/app/theme/app_spacing.dart';

/// Small section header for settings screens.
class SettingsSectionHeader extends StatelessWidget {
  /// Creates a section header with [title].
  const new({required this.title, super.key});

  /// The section title (localized).
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.m,
        AppSpacing.m,
        AppSpacing.m,
        AppSpacing.s,
      ),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
