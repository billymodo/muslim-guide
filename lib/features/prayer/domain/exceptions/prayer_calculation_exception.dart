/// An invalid input or unsupported condition encountered during calculation.
class PrayerCalculationException implements Exception {
  /// Creates a calculation exception with a diagnostic message.
  const new(this.message);

  /// Explains why the calculation could not be completed.
  final String message;

  @override
  String toString() => 'PrayerCalculationException: $message';
}
