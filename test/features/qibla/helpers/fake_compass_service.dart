import 'dart:async';

import 'package:muslim_guide/features/qibla/data/compass_service.dart';

/// Test-only [CompassService] with a manually driven broadcast stream.
///
/// Tracks active listeners so tests can assert that the provider cancels
/// its subscription on dispose (no leaks).
class FakeCompassService implements CompassService {
  /// Creates the fake and wires listener counters.
  new() {
    _controller = StreamController<double?>.broadcast(
      onListen: () => _activeListeners++,
      onCancel: () => _activeListeners--,
    );
  }

  late final StreamController<double?> _controller;
  int _activeListeners = 0;
  bool _closed = false;

  /// Number of current subscriptions to [headingStream].
  int get activeListeners => _activeListeners;

  /// Whether the underlying controller has been closed.
  bool get isClosed => _closed;

  @override
  Stream<double?> get headingStream => _controller.stream;

  /// Emits a heading (degrees) or `null` (no sensor).
  void emit(double? heading) => _controller.add(heading);

  /// Emits a stream error (sensor failure).
  void emitError(Object error) => _controller.addError(error);

  /// Closes the stream.
  Future<void> dispose() {
    _closed = true;
    return _controller.close();
  }
}
