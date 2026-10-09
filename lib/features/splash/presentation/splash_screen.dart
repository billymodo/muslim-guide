import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:muslim_guide/app/providers/bootstrap_provider.dart';
import 'package:muslim_guide/app/theme/app_colors.dart';
import 'package:muslim_guide/app/theme/app_spacing.dart';
import 'package:muslim_guide/l10n/app_localizations.dart';

/// Displays the application identity while local services initialize.
class SplashScreen extends ConsumerStatefulWidget {
  /// Creates the splash screen.
  const new({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // BUG-5: the _AppBootstrap gate completes bootstrap before the router
    // (and this screen) is ever built, so the build-time ref.listen below
    // would register on an already-complete value and never fire. Check the
    // current state once after the first frame; the listener in build()
    // still covers transitions that complete later.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (ref.read(bootstrapProvider).hasValue) {
        context.go('/home');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<void>>(bootstrapProvider, (previous, next) {
      next.whenData((_) {
        if (!mounted) return;
        context.go('/home');
      });
    });
    final bootstrap = ref.watch(bootstrapProvider);
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
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.menu_book_rounded,
                    size: 120,
                    color: onPrimary,
                  ),
                  const SizedBox(height: AppSpacing.l),
                  Text(
                    localizations.app_name,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      color: onPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s),
                  Text(
                    localizations.app_tagline,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: onPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  if (bootstrap.isLoading)
                    Text(
                      localizations.splash_loading,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: onPrimary,
                      ),
                    ),
                  if (bootstrap.hasError) ...[
                    Text(
                      localizations.splash_error,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: onPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.m),
                    FilledButton(
                      onPressed: () => ref.invalidate(bootstrapProvider),
                      child: Text(localizations.splash_retry),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
