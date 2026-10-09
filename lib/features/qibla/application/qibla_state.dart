import 'package:meta/meta.dart';
import 'package:muslim_guide/features/qibla/domain/qibla_direction.dart';

/// Lifecycle of the device magnetometer as observed by the Qibla feature.
enum SensorStatus {
  /// Waiting for the first compass event.
  initializing,

  /// The compass is producing headings.
  available,

  /// The device reports no magnetometer (`heading == null` / empty stream).
  unavailable,

  /// The compass stream errored.
  error,
}

/// Combined Qibla UI state: absolute bearing + device heading + relative
/// rotation of the compass dial.
@immutable
class QiblaState {
  /// Creates a state directly. Prefer the named factories.
  const new({
    required this.locationSource,
    required this.sensorStatus,
    this.qiblaBearing,
    this.deviceHeading,
    this.relativeAngle,
  });

  /// Nothing resolved yet: no bearing, sensor initializing.
  factory initializing() => const QiblaState(
    locationSource: QiblaLocationSource.unavailable,
    sensorStatus: SensorStatus.initializing,
  );

  /// The sensor reports no magnetometer; the location (if any) is kept so
  /// the numeric fallback can still show the absolute bearing.
  factory noSensor({
    required QiblaLocationSource locationSource,
    double? qiblaBearing,
  }) => QiblaState(
    qiblaBearing: qiblaBearing,
    locationSource: locationSource,
    sensorStatus: SensorStatus.unavailable,
  );

  /// No location available; [sensorStatus] reports the sensor lifecycle.
  factory noLocation({required SensorStatus sensorStatus}) => QiblaState(
    locationSource: QiblaLocationSource.unavailable,
    sensorStatus: sensorStatus,
  );

  /// Both bearing and heading known: computes [relativeAngle] so the dial
  /// points at `(bearing − heading) mod 360`.
  factory ready({
    required double qiblaBearing,
    required double deviceHeading,
    required QiblaLocationSource locationSource,
  }) => QiblaState(
    qiblaBearing: qiblaBearing,
    deviceHeading: deviceHeading,
    relativeAngle: (qiblaBearing - deviceHeading + 360) % 360,
    locationSource: locationSource,
    sensorStatus: SensorStatus.available,
  );

  /// Absolute Qibla bearing from the user to the Kaaba `[0, 360)`;
  /// `null` when no location is available.
  final double? qiblaBearing;

  /// Latest device heading `[0, 360)`; `null` before the first event.
  final double? deviceHeading;

  /// Dial rotation = `(qiblaBearing − deviceHeading + 360) % 360`;
  /// `null` unless both inputs are known.
  final double? relativeAngle;

  /// Where the coordinates came from.
  final QiblaLocationSource locationSource;

  /// Sensor lifecycle for this state.
  final SensorStatus sensorStatus;
}
