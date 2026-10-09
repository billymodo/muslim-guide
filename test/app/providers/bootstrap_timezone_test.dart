import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:muslim_guide/app/providers/bootstrap_provider.dart';
import 'package:muslim_guide/core/logging/local_error_log.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

void main() {
  late Directory tempDir;

  setUp(() {
    tz_data.initializeTimeZones();
    tempDir = Directory.systemTemp.createTempSync('cr0010_tz_');
  });

  tearDown(() {
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  String logPath() {
    return '${tempDir.path}${Platform.pathSeparator}logs'
        '${Platform.pathSeparator}errors.jsonl';
  }

  LocalErrorLog testLog() {
    return LocalErrorLog(documentsDirectoryProvider: () async => tempDir);
  }

  test('uses the device IANA identifier when the lookup succeeds', () async {
    await setLocalTimezone(
      getLocalTimezone: () async =>
          TimezoneInfo(identifier: 'Europe/Oslo'),
      errorLog: testLog(),
    );

    expect(tz.local.name, 'Europe/Oslo');
    expect(File(logPath()).existsSync(), isFalse);
  });

  test('falls back to Asia/Riyadh and logs a warning on failure', () async {
    await setLocalTimezone(
      getLocalTimezone: () async => throw StateError('platform down'),
      errorLog: testLog(),
    );

    expect(tz.local.name, 'Asia/Riyadh');
    final logFile = File(logPath());
    expect(logFile.existsSync(), isTrue);
    final lines = logFile.readAsLinesSync();
    expect(lines, hasLength(1));
    expect(lines.single, contains('warning'));
    expect(lines.single, contains('Asia/Riyadh'));
    expect(lines.single, contains('platform down'));
  });

  test('falls back when the identifier is unknown to tz', () async {
    await setLocalTimezone(
      getLocalTimezone: () async =>
          TimezoneInfo(identifier: 'Mars/Olympus_Mons'),
      errorLog: testLog(),
    );

    expect(tz.local.name, 'Asia/Riyadh');
  });
}
