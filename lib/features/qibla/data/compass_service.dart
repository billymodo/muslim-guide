/// Abstract compass heading source.
///
/// Emits device headings in degrees `[0, 360)` (0 = magnetic north), or
/// `null` when the device has no magnetometer (flutter_compass Android
/// contract).
abstract class CompassService {
  /// The live heading stream. May emit `null` (no sensor) or an error
  /// (sensor failure).
  Stream<double?> get headingStream;
}
