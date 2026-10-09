import 'package:flutter_compass/flutter_compass.dart';
import 'package:muslim_guide/features/qibla/data/compass_service.dart';

/// Real [CompassService] backed by the flutter_compass plugin.
///
/// `FlutterCompass.events` is `null` on platforms without a magnetometer
/// channel; in that case an empty stream is exposed so subscribers simply
/// never receive headings (the state stays `initializing` until the UI
/// layer handles the sensor lifecycle).
class FlutterCompassService implements CompassService {
  @override
  Stream<double?> get headingStream =>
      FlutterCompass.events?.map((event) => event.heading) ??
      const Stream<double?>.empty();
}
