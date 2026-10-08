/// A platform or service error while accessing device location.
class LocationServiceException implements Exception {
  /// Creates a location service exception.
  const new({required this.message, this.cause});

  /// Human-readable diagnostic message.
  final String message;

  /// Original platform error, when available.
  final Object? cause;

  @override
  String toString() =>
      'LocationServiceException: $message'
      '${cause == null ? '' : ' ($cause)'}';
}
