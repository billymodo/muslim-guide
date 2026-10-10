import 'dart:developer' as developer;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:muslim_guide/app/deep_link_parser.dart';
import 'package:muslim_guide/app/providers/bootstrap_provider.dart';
import 'package:muslim_guide/core/logging/local_error_log.dart';
import 'package:muslim_guide/features/home/presentation/home_placeholder.dart';
import 'package:muslim_guide/features/onboarding/presentation/language_selection_screen.dart';
import 'package:muslim_guide/features/prayer/presentation/screens/location_picker_screen.dart';
import 'package:muslim_guide/features/prayer/presentation/screens/prayer_times_screen.dart';
import 'package:muslim_guide/features/qibla/presentation/qibla_screen.dart';
import 'package:muslim_guide/features/splash/presentation/splash_screen.dart';

/// Provides the application router.
final routerProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) async {
      final deepLinkLocation = await redirectDeepLink(
        state.uri,
        logUnknownUri: (uri) => LocalErrorLog.instance.log(
          level: 'warning',
          message: 'Unknown deep link: $uri',
        ),
      );
      if (deepLinkLocation != null) return deepLinkLocation;

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
      GoRoute(path: '/qibla', builder: (context, state) => const QiblaScreen()),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});

/// Redirects a deep link to its internal route, or falls back for unknown URIs.
Future<String?> redirectDeepLink(
  Uri uri, {
  required Future<void> Function(String uri) logUnknownUri,
}) async {
  if (uri.scheme.toLowerCase() != DeepLinkParser.scheme) return null;

  final location = DeepLinkParser.parse(uri);
  if (location != null) return location;

  final safeUri = Uri(
    scheme: uri.scheme,
    host: uri.host,
    path: uri.path,
  ).toString();
  try {
    await logUnknownUri(safeUri);
  } on Object catch (error, stackTrace) {
    developer.log(
      'Failed to record an unknown deep link.',
      name: 'muslim_guide.router',
      error: error,
      stackTrace: stackTrace,
    );
  }
  return '/prayer';
}
