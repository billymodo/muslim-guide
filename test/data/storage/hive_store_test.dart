import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_guide/data/storage/hive_store.dart';

void main() {
  test('close is safe before initialization', () async {
    final store = HiveStore();

    await store.close();

    expect(store.isAvailable, isFalse);
  });
}
