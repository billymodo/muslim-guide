import 'package:flutter/material.dart';
import 'package:muslim_guide/l10n/app_localizations.dart';

/// Placeholder screen shown after successful bootstrap.
///
/// Will be replaced by the full dashboard in Phase 10.
class HomePlaceholder extends StatelessWidget {
  /// Creates the placeholder home screen.
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              localizations.home_greeting,
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: 16),
            Text(
              'Placeholder — Phase 10 will build the full dashboard',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
