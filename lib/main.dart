import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muslim_guide/app/muslim_guide_app.dart';
import 'package:muslim_guide/app/providers/bootstrap_provider.dart';
import 'package:muslim_guide/app/router.dart';
import 'package:muslim_guide/app/theme/app_colors.dart';
import 'package:muslim_guide/app/theme/app_spacing.dart';
import 'package:muslim_guide/app/theme/app_theme.dart';
import 'package:muslim_guide/l10n/app_localizations.dart';

/// Gates the whole application on one-time bootstrap initialization so no
/// route (including cold-start deep links) can reach settings-dependent
/// providers before storage is ready (BUG-3).
class _AppBootstrap extends ConsumerWidget {
  const new();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bootstrap = ref.watch(bootstrapProvider);
    return bootstrap.when(
      loading: () => const _BootstrapLoadingScreen(),
      error: (error, stackTrace) => _BootstrapErrorScreen(
        error: error,
        onRetry: () => ref.invalidate(bootstrapProvider),
      ),
      data: (_) => MuslimGuideApp(router: ref.watch(routerProvider)),
    );
  }
}

/// Shown while bootstrap initialization runs.
class _BootstrapLoadingScreen extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: const Locale('ar'),
      theme: AppTheme.light(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const _BootstrapLoadingBody(),
    );
  }
}

class _BootstrapLoadingBody extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final onPrimary = Theme.of(context).colorScheme.onPrimary;
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.primaryDark, AppColors.primary],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: AppSpacing.l),
                Text(
                  localizations.splash_loading,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: onPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Shown when bootstrap initialization fails, with a retry action.
class _BootstrapErrorScreen extends StatelessWidget {
  const new({required this.error, required this.onRetry});

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: const Locale('ar'),
      theme: AppTheme.light(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: _BootstrapErrorBody(error: error, onRetry: onRetry),
    );
  }
}

class _BootstrapErrorBody extends StatelessWidget {
  const new({required this.error, required this.onRetry});

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.l),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  localizations.splash_error,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: AppSpacing.m),
                Text(
                  error.toString(),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: AppSpacing.m),
                FilledButton(
                  onPressed: onRetry,
                  child: Text(localizations.splash_retry),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Entry point for the application.
void main() {
  runApp(const ProviderScope(child: _AppBootstrap()));
}
