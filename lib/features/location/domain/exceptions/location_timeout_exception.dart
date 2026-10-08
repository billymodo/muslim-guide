/// A request for the current location exceeded its configured time limit.
class LocationTimeoutException implements Exception {
  /// Creates a timeout exception.
  const new({required this.timeout});

  /// Maximum time allowed for the location request.
  final Duration timeout;

  @override
  String toString() => 'Location request timed out after $timeout';
}
