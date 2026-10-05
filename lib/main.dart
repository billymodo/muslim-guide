import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// التطبيق الجذري — Phase 00: أساس فارغ بلا أي شاشات.
///
/// خارج النطاق حاليًا: Splash، Theme، Localization، Hive، الشبكة،
/// وأي ميزة إسلامية (انظر `phases/00-foundation.md`).
class MuslimGuideApp extends StatelessWidget {
  /// يُنشئ التطبيق الجذري مع [ProviderScope] (DEC-0002).
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return const ProviderScope(
      child: SizedBox.expand(),
    );
  }
}

/// نقطة تشغيل التطبيق.
void main() {
  runApp(const MuslimGuideApp());
}
