import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_guide/core/logging/local_error_log.dart';

void main() {
  late Directory tempDirectory;

  setUp(() async {
    tempDirectory = await Directory.systemTemp.createTemp('error_log_test_');
  });

  tearDown(() async {
    await tempDirectory.delete(recursive: true);
  });

  test('redacts personal data and clears the JSONL file', () async {
    final errorLog = LocalErrorLog(
      documentsDirectoryProvider: () async => tempDirectory,
    );

    await errorLog.log(
      level: 'error',
      message: 'Failed for user@example.com',
      context: {
        'email': 'user@example.com',
        'details': {'phone': '+1 555 123 4567', 'attempt': 2},
      },
    );

    final file = File(
      '${tempDirectory.path}${Platform.pathSeparator}'
      'logs${Platform.pathSeparator}errors.jsonl',
    );
    final event = jsonDecode(await file.readAsString()) as Map<String, dynamic>;
    final context = event['context'] as Map<String, dynamic>;
    final details = context['details'] as Map<String, dynamic>;
    expect(event['message'], 'Failed for [REDACTED]');
    expect(context['email'], '[REDACTED]');
    expect(details['phone'], '[REDACTED]');

    await errorLog.clear();
    expect(file.existsSync(), isFalse);
  });
}
