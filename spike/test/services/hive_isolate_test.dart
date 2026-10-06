import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_guide_spike/services/hive_isolate_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('background isolate writes through the main-isolate bridge', () async {
    final directory = await Directory.systemTemp.createTemp('spike-hive-');
    final bridge = await HiveIsolateBridge.initialize(
      pathResolver: () async => directory.path,
    );

    try {
      final result = await HiveIsolateTest(bridge: bridge).run();

      expect(result.ok, isTrue, reason: result.message);
      expect(bridge.read('from_isolate'), isNotNull);
    } finally {
      await bridge.dispose();
      await directory.delete(recursive: true);
    }
  });
}
