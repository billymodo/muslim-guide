import 'package:timezone/timezone.dart' as tz;

/// Android channel used by scheduled prayer notifications.
const String prayerAdhanNotificationChannelId = 'prayer_adhan_v1';

/// Platform notification operations used by the prayer scheduler.
abstract interface class LocalNotificationApi {
  /// Initializes the Android notification plugin.
  Future<bool?> initialize();

  /// Creates the prayer notification channel before scheduling.
  Future<void> createPrayerAdhanChannel({
    required String name,
    required String description,
  });

  /// Schedules one notification at a timezone-aware instant.
  Future<void> zonedSchedule({
    required int id,
    required tz.TZDateTime scheduledAt,
    required String title,
    required String body,
    required String channelId,
  });

  /// Cancels a notification by its application-owned identifier.
  Future<void> cancel(int id);
}
