import 'dart:async';

import 'package:flutter_compass/flutter_compass.dart';
import 'package:muslim_guide/features/qibla/data/compass_service.dart';

/// Supplies the plugin event stream, or `null` when no magnetometer exists.
typedef CompassEventsProvider = Stream<CompassEvent>? Function();

/// Real [CompassService] backed by the flutter_compass plugin.
///
/// `FlutterCompass.events` is `null` on platforms without a magnetometer
/// channel; emit a single null heading so consumers show the numeric fallback.
class FlutterCompassService implements CompassService {
  /// Creates the service with an optional source of compass events.
  new({CompassEventsProvider? eventsProvider})
    : _eventsProvider = eventsProvider ?? _defaultEventsProvider;

  final CompassEventsProvider _eventsProvider;

  static Stream<CompassEvent>? _defaultEventsProvider() =>
      FlutterCompass.events;

  @override
  Stream<double?> get headingStream {
    final events = _eventsProvider();
    if (events == null) {
      return Stream.value(null);
    }
    return events.map((event) => event.heading);
  }
}
