import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:muslim_guide/app/theme/app_theme.dart';
import 'package:muslim_guide/features/azkar/application/azkar_providers.dart';
import 'package:muslim_guide/features/azkar/data/azkar_pack_loader.dart';
import 'package:muslim_guide/features/azkar/data/azkar_progress_repository.dart';
import 'package:muslim_guide/features/azkar/data/azkar_progress_storage.dart';
import 'package:muslim_guide/features/azkar/domain/azkar_category.dart';
import 'package:muslim_guide/features/azkar/domain/azkar_pack.dart';
import 'package:muslim_guide/features/azkar/domain/dhikr.dart';
import 'package:muslim_guide/features/azkar/presentation/azkar_detail_screen.dart';
import 'package:muslim_guide/features/azkar/presentation/azkar_library_screen.dart';
import 'package:muslim_guide/l10n/app_localizations.dart';

/// Asset bundle serving [payload] for any requested key.
class FakeAzkarAssetBundle extends CachingAssetBundle {
  /// Creates a bundle answering with [payload].
  /// Plain form required: `const new(...)` errors on the non-const super.
  // ignore: unnecessary_type_name_in_constructor
  FakeAzkarAssetBundle(this.payload);

  /// JSON payload served for every load.
  final String payload;

  @override
  Future<ByteData> load(String key) async {
    return ByteData.sublistView(utf8.encode(payload));
  }

  @override
  Future<String> loadString(String key, {bool cache = true}) async {
    return payload;
  }
}

/// Pack override serving an in-memory [pack] (null = pending pack).
Override azkarPackOverride(AzkarPack? pack) {
  return azkarLibraryProvider.overrideWith(
    () => _FixedAzkarLibrary(pack),
  );
}

/// In-memory library notifier used by widget tests.
class _FixedAzkarLibrary extends AzkarLibraryNotifier {
  /// Creates a fixed library.
  new(this.pack);

  /// Pack to serve (null = pending pack Empty state).
  final AzkarPack? pack;

  @override
  Future<AzkarPack?> build() async => pack;
}

/// Progress repository override backed by [storage].
Override azkarProgressOverride(AzkarProgressStorage storage) {
  return azkarProgressRepositoryProvider.overrideWithValue(
    AzkarProgressRepository(storage: storage),
  );
}

/// Loader override serving [json] for any requested key.
Override azkarLoaderOverride(String json) {
  return azkarPackLoaderProvider.overrideWithValue(
    AzkarPackLoader(assetBundle: FakeAzkarAssetBundle(json)),
  );
}

/// Placeholder pack with the five Phase 06 categories.
AzkarPack stubAzkarPack() {
  Dhikr item(String id, AzkarCategoryId category, {int repeat = 1}) {
    return Dhikr(
      id: id,
      categoryId: category,
      textPlaceholder: '[PLACEHOLDER-DHIKR-$id]',
      virtuePlaceholder: '[PLACEHOLDER-VIRTUE-$id]',
      repeatCount: repeat,
      sourcePlaceholder: '[PLACEHOLDER-SOURCE]',
    );
  }

  return AzkarPack(
    categories: const [
      AzkarCategory(id: AzkarCategoryId.morning, totalCount: 2),
      AzkarCategory(id: AzkarCategoryId.evening, totalCount: 1),
      AzkarCategory(id: AzkarCategoryId.sleep, totalCount: 1),
      AzkarCategory(id: AzkarCategoryId.wakeUp, totalCount: 1),
      AzkarCategory(id: AzkarCategoryId.tasbih, totalCount: 1),
    ],
    items: [
      item('morning-01', AzkarCategoryId.morning),
      item('morning-02', AzkarCategoryId.morning, repeat: 3),
      item('evening-01', AzkarCategoryId.evening),
      item('sleep-01', AzkarCategoryId.sleep),
      item('wake-up-01', AzkarCategoryId.wakeUp),
      item('tasbih-01', AzkarCategoryId.tasbih, repeat: 33),
    ],
  );
}

/// Wraps [child] with ProviderScope, theme, delegates, and locale.
Widget buildAzkarTestApp({
  required Widget child,
  List<Override> overrides = const <Override>[],
  Locale locale = const Locale('ar'),
}) {
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp(
      theme: AppTheme.light(),
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: child,
    ),
  );
}

/// Builds a router exposing library + detail routes.
GoRouter buildAzkarRouter({
  String initialLocation = '/azkar',
  List<Override> overrides = const <Override>[],
}) {
  final router = GoRouter(
    initialLocation: initialLocation,
    routes: [
      GoRoute(
        path: '/azkar',
        builder: (_, _) => const AzkarLibraryScreen(),
        routes: [
          GoRoute(
            path: ':category',
            builder: (_, state) {
              final category = AzkarCategoryId.fromValue(
                    state.pathParameters['category'],
                  ) ??
                  AzkarCategoryId.morning;
              return AzkarDetailScreen(categoryId: category);
            },
          ),
        ],
      ),
    ],
  );
  addTearDown(router.dispose);
  return router;
}

/// Wraps [router] with ProviderScope, theme, delegates, and locale.
Widget buildAzkarRouterApp({
  required GoRouter router,
  List<Override> overrides = const <Override>[],
  Locale locale = const Locale('ar'),
}) {
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp.router(
      theme: AppTheme.light(),
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: router,
    ),
  );
}

/// Loads localized strings for [locale].
Future<AppLocalizations> loadAzkarL10n(Locale locale) {
  return AppLocalizations.delegate.load(locale);
}
