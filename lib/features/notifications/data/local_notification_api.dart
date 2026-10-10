import 'package:timezone/timezone.dart' as tz;

/// Platform notification operations used by the prayer scheduler.
abstract interface class LocalNotificationApi {
  /// Initializes the Android notification plugin.
  Future<bool?> initialize();

  /// Schedules one silent notification at a timezone-aware instant.
  Future<void> zonedSchedule({
    required int id,
    required tz.TZDateTime scheduledAt,
    required String title,
    required String body,
  });

  /// Cancels a notification by its application-owned identifier.
  Future<void> cancel(int id);
}
