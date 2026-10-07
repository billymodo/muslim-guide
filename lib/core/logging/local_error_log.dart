import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

// ignore_for_file: avoid_slow_async_io // File I/O must remain async to avoid blocking UI

/// Writes a bounded, privacy-filtered JSON Lines error log to local storage.
class LocalErrorLog {
  /// Creates a log using the app documents directory.
  new({Future<Directory> Function()? documentsDirectoryProvider})
    : _documentsDirectoryProvider =
          documentsDirectoryProvider ?? getApplicationDocumentsDirectory;

  static const int _maxBytes = 1024 * 1024;
  static const int _maxEvents = 1000;

  static final RegExp _sensitiveKey = RegExp(
    '(password|passcode|token|secret|authorization|auth.?key|api.?key|'
    'credential|cookie|email|phone|address|location|latitude|longitude|'
    'coordinate|birth|name|user.?id|device.?id|session.?id|personal)',
    caseSensitive: false,
  );
  static final RegExp _email = RegExp(r'\b[\w.+-]+@[\w.-]+\.[A-Za-z]{2,}\b');
  static final RegExp _phone = RegExp(r'(?<!\w)\+?\d[\d\s().-]{7,}\d(?!\w)');

  final Future<Directory> Function() _documentsDirectoryProvider;
  Future<void> _operationQueue = Future<void>.value();

  /// Appends a privacy-filtered event to `logs/errors.jsonl`.
  Future<void> log({
    required String level,
    required String message,
    StackTrace? stack,
    Map<String, dynamic>? context,
  }) {
    return _enqueue(() async {
      final event = <String, Object?>{
        'timestamp': DateTime.now().toUtc().toIso8601String(),
        'level': _redactText(level),
        'message': _redactText(message),
        if (stack != null) 'stack': _redactText(stack.toString()),
        if (context != null) 'context': _sanitizeValue(context),
      };
      final line = '${jsonEncode(event)}\n';
      final lineBytes = utf8.encode(line).length;
      if (lineBytes > _maxBytes) {
        throw ArgumentError.value(
          lineBytes,
          'event',
          'A single event cannot exceed 1 MB.',
        );
      }

      final file = await _logFile();
      await file.parent.create(recursive: true);
      final existingBytes = await file.exists() ? await file.length() : 0;
      if (existingBytes + lineBytes <= _maxBytes) {
        await file.writeAsString(line, mode: FileMode.append, flush: true);
        return;
      }

      final events =
          (await file.exists() ? await file.readAsLines() : <String>[])
            ..add(line.trimRight());
      while (events.length > _maxEvents ||
          _encodedEventsLength(events) > _maxBytes) {
        events.removeAt(0);
      }
      await file.writeAsString('${events.join('\n')}\n', flush: true);
    });
  }

  /// Shares the log file using the system share sheet.
  Future<void> export() {
    return _enqueue(() async {
      final file = await _logFile();
      if (!await file.exists()) {
        throw StateError('There is no local error log to export.');
      }
      await SharePlus.instance.share(
        ShareParams(files: [XFile(file.path)], title: 'Application error log'),
      );
    });
  }

  /// Deletes the local error log if it exists.
  Future<void> clear() {
    return _enqueue(() async {
      final file = await _logFile();
      if (await file.exists()) await file.delete();
    });
  }

  Future<File> _logFile() async {
    final documentsDirectory = await _documentsDirectoryProvider();
    return File(
      '${documentsDirectory.path}${Platform.pathSeparator}'
      'logs${Platform.pathSeparator}errors.jsonl',
    );
  }

  Future<void> _enqueue(Future<void> Function() operation) {
    final result = Completer<void>();
    _operationQueue = _operationQueue.then((_) async {
      try {
        await operation();
        result.complete();
      } on Object catch (error, stackTrace) {
        result.completeError(error, stackTrace);
      }
    });
    return result.future;
  }

  static int _encodedEventsLength(List<String> events) {
    return events.fold<int>(
      0,
      (total, event) => total + utf8.encode('$event\n').length,
    );
  }

  static Object? _sanitizeValue(Object? value) {
    if (value is Map) {
      return value.map((key, value) {
        final keyString = key.toString();
        return MapEntry(
          keyString,
          _sensitiveKey.hasMatch(keyString)
              ? '[REDACTED]'
              : _sanitizeValue(value),
        );
      });
    }
    if (value is Iterable) {
      return value.map(_sanitizeValue).toList();
    }
    if (value is String) return _redactText(value);
    return value;
  }

  static String _redactText(String value) {
    return value
        .replaceAll(_email, '[REDACTED]')
        .replaceAll(_phone, '[REDACTED]');
  }
}
