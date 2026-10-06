import 'dart:isolate';

import 'package:hive_ce/hive.dart';
import 'package:path_provider/path_provider.dart';

/// نتيجة اختبار Hive عبر isolates.
class HiveIsolateResult {
  /// Creates a result with [ok] and a human-readable [message].
  const new({required this.ok, required this.message});

  /// true إذا نجحت القراءة بعد كتابة الـisolate.
  final bool ok;

  /// وصف النتيجة للمستخدم.
  final String message;
}

/// سيناريو: كتابة من isolate خلفي ثم قراءة من isolate رئيسي.
///
/// الوصول المتزامن لنفس الـbox من عزلتين هو ما يُختبر؛ الفشل مُتوقع
/// ويُوثَّق في spike/RESULTS.md (هذا هو هدف الاختبار).
class HiveIsolateTest {
  /// Creates the test; [pathResolver] يحقن مسار التخزين في الاختبارات.
  new({Future<String> Function()? pathResolver})
      : _pathResolver = pathResolver ?? _defaultPath;

  final Future<String> Function() _pathResolver;

  static Future<String> _defaultPath() async {
    final dir = await getApplicationDocumentsDirectory();
    return dir.path;
  }

  /// ينفّذ: (1) كتابة في الرئيسي (2) كتابة من isolate (3) قراءة في الرئيسي.
  Future<HiveIsolateResult> run() async {
    final path = await _pathResolver();
    Hive.init(path);

    final mainBox = await Hive.openBox<dynamic>('spike_hive_test');
    await mainBox.put('from_main', DateTime.now().toIso8601String());

    // الاختبار الحقيقي: isolate ثانية تفتح نفس المجلد ونفس اسم الـbox.
    final outcome = await Isolate.run<String>(() async {
      try {
        Hive.init(path);
        final box = await Hive.openBox<dynamic>('spike_hive_test');
        await box.put(
          'from_isolate',
          DateTime.now().toIso8601String(),
        );
        await box.close();
        return 'ok';
      } on Exception catch (e) {
        return 'error: $e';
      }
    });

    String? value;
    try {
      value = mainBox.get('from_isolate') as String?;
    } on Exception catch (e) {
      await mainBox.close();
      return HiveIsolateResult(ok: false, message: 'read failed: $e');
    }
    await mainBox.close();

    if (outcome != 'ok') {
      return HiveIsolateResult(
        ok: false,
        message: 'isolate write failed: $outcome',
      );
    }
    if (value == null) {
      return const HiveIsolateResult(
        ok: false,
        message: 'main read null — النمط غير موثوق',
      );
    }
    return HiveIsolateResult(
      ok: true,
      message: 'isolate→main OK: $value',
    );
  }
}
