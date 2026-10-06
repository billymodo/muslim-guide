import 'dart:async';
import 'dart:isolate';
import 'dart:ui' as ui;

import 'package:hive_ce/hive.dart';
import 'package:path_provider/path_provider.dart';

/// Result of a Hive isolate bridge test.
class HiveIsolateResult {
  /// Creates a result with [ok] and a human-readable [message].
  const new({required this.ok, required this.message});

  /// Whether the background isolate write was visible in the main isolate.
  final bool ok;

  /// Human-readable result for the LogViewer.
  final String message;
}

/// Keeps Hive access on the main isolate and accepts writes over a named port.
class HiveIsolateBridge {
  /// Creates a bridge for an open Hive box and its receive port.
  new(this._box, this._receivePort);

  /// Isolate-name registration used by this bridge.
  static const String portName = 'hive_bridge';
  static const String _boxName = 'spike_hive_test';
  static const Duration _requestTimeout = Duration(seconds: 5);

  final Box<dynamic> _box;
  final ReceivePort _receivePort;
  bool _disposed = false;

  /// Initializes Hive and registers the main-isolate write endpoint.
  static Future<HiveIsolateBridge> initialize({
    Future<String> Function()? pathResolver,
  }) async {
    final path = await (pathResolver ?? _defaultPath)();
    Hive.init(path);
    final box = await Hive.openBox<dynamic>(_boxName);
    final receivePort = ReceivePort();

    ui.IsolateNameServer.removePortNameMapping(portName);
    if (!ui.IsolateNameServer.registerPortWithName(
      receivePort.sendPort,
      portName,
    )) {
      receivePort.close();
      await box.close();
      throw StateError('Could not register the Hive isolate bridge.');
    }

    final bridge = HiveIsolateBridge(box, receivePort);
    receivePort.listen(bridge._handleMessage);
    return bridge;
  }

  static Future<String> _defaultPath() async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<void> _handleMessage(Object? message) async {
    if (message is! Map) {
      return;
    }

    final replyPort = message['replyPort'];
    if (replyPort is! SendPort) {
      return;
    }

    try {
      if (message['action'] != 'write' ||
          message['key'] is! String ||
          message['value'] is! String) {
        throw const FormatException('Invalid Hive bridge request.');
      }
      final key = message['key']! as String;
      final value = message['value']! as String;
      await _box.put(key, value);
      replyPort.send(<String, Object?>{'status': 'ok', 'value': value});
    } on Exception catch (error) {
      replyPort.send(<String, Object?>{
        'status': 'error',
        'error': error.toString(),
      });
    }
  }

  /// Sends a write request and waits for its main-isolate ACK.
  Future<String> writeFromIsolate(String key, String value) async {
    if (_disposed) {
      return 'ERROR: Hive bridge is disposed';
    }

    final replyPort = ReceivePort();
    final replySendPort = replyPort.sendPort;
    try {
      final mainPort = ui.IsolateNameServer.lookupPortByName(portName);
      if (mainPort == null) {
        return 'ERROR: main isolate bridge not registered';
      }

      await Isolate.run<void>(() {
        final port = ui.IsolateNameServer.lookupPortByName(portName);
        if (port == null) {
          throw StateError('main isolate bridge not registered');
        }
        port.send(<String, Object?>{
          'action': 'write',
          'key': key,
          'value': value,
          'replyPort': replySendPort,
        });
      });

      final response = await replyPort.first.timeout(_requestTimeout);
      if (response is Map && response['status'] == 'ok') {
        return 'SUCCESS: wrote $key=$value';
      }
      if (response is Map && response['status'] == 'error') {
        return 'ERROR: ${response['error']}';
      }
      return 'ERROR: invalid response from main isolate';
    } on TimeoutException {
      return 'ERROR: Hive bridge ACK timed out after '
          '${_requestTimeout.inSeconds}s';
    } on Exception catch (error) {
      return 'ERROR: $error';
    } finally {
      replyPort.close();
    }
  }

  /// Reads a value from the box owned by the main isolate.
  String? read(String key) => _box.get(key) as String?;

  /// Unregisters the port and closes the main-isolate box.
  Future<void> dispose() async {
    if (_disposed) {
      return;
    }
    _disposed = true;
    ui.IsolateNameServer.removePortNameMapping(portName);
    _receivePort.close();
    await _box.close();
  }
}

/// Tests writing through the main-isolate Hive bridge.
class HiveIsolateTest {
  /// Creates the test with the initialized main-isolate [bridge].
  const new({required this.bridge});

  /// Main-isolate Hive bridge; null disables the test when not initialized.
  final HiveIsolateBridge? bridge;

  /// Requests a background-isolate write and verifies it through the main box.
  Future<HiveIsolateResult> run() async {
    final hiveBridge = bridge;
    if (hiveBridge == null) {
      return const HiveIsolateResult(
        ok: false,
        message: 'Hive main-isolate bridge is not initialized',
      );
    }

    final value = DateTime.now().toIso8601String();
    final outcome = await hiveBridge.writeFromIsolate('from_isolate', value);
    if (!outcome.startsWith('SUCCESS:')) {
      return HiveIsolateResult(ok: false, message: outcome);
    }

    final readValue = hiveBridge.read('from_isolate');
    if (readValue != value) {
      return HiveIsolateResult(
        ok: false,
        message: 'main isolate read mismatch: $readValue',
      );
    }
    return HiveIsolateResult(ok: true, message: 'isolate→main OK: $readValue');
  }
}
