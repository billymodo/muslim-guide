import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:muslim_guide/app/theme/app_theme.dart';
import 'package:muslim_guide/l10n/app_localizations.dart';

/// Root presentational widget for the application.
class MuslimGuideApp extends StatelessWidget {
  /// Creates the application with its router.
  const new({required this.router, super.key});

  /// Router used to resolve application pages.
  final GoRouter router;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context)!.app_name,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      routerConfig: router,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('ar'),
    );
  }
}
