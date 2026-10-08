import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:muslim_guide/app/providers/bootstrap_provider.dart';
import 'package:muslim_guide/features/home/presentation/home_placeholder.dart';
import 'package:muslim_guide/features/onboarding/presentation/language_selection_screen.dart';
import 'package:muslim_guide/features/prayer/presentation/screens/location_picker_screen.dart';
import 'package:muslim_guide/features/prayer/presentation/screens/prayer_times_screen.dart';
import 'package:muslim_guide/features/splash/presentation/splash_screen.dart';

/// Provides the application router.
final routerProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) async {
      if (state.matchedLocation == '/splash' ||
          state.matchedLocation == '/onboarding/language') {
        return null;
      }

      if (state.matchedLocation == '/home') {
        final settings = ref.read(settingsRepositoryProvider);
        if (!await settings.isOnboardingCompleted()) {
          return '/onboarding/language';
        }
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding/language',
        builder: (context, state) => const LanguageSelectionScreen(),
      ),
      GoRoute(
        path: '/home',
        // TODO(phase-01-followup): insert /onboarding/welcome between /language and /home.
        builder: (context, state) => const HomePlaceholder(),
      ),
      GoRoute(
        path: '/prayer',
        builder: (context, state) => const PrayerTimesScreen(),
      ),
      GoRoute(
        path: '/location-picker',
        builder: (context, state) => const LocationPickerScreen(),
      ),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});
