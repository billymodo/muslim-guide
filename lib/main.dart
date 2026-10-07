import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muslim_guide/app/muslim_guide_app.dart';
import 'package:muslim_guide/app/router.dart';

class _AppBootstrap extends ConsumerWidget {
  const new();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    return MuslimGuideApp(router: router);
  }
}

/// Entry point for the application.
void main() {
  runApp(const ProviderScope(child: _AppBootstrap()));
}
