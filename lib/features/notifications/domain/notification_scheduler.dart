import 'package:muslim_guide/features/notifications/domain/permission_state.dart';
import 'package:muslim_guide/features/notifications/domain/prayer_notification.dart';
import 'package:muslim_guide/features/notifications/domain/schedule_result.dart';

/// Schedules and reconciles local prayer notifications.
abstract interface class NotificationScheduler {
  /// Reconciles [schedule] with OS alarms.
  ///
  /// A null schedule represents no selected location and must return
  /// [ScheduleResult.noLocation] without invoking platform scheduling APIs.
  Future<ScheduleResult> schedule({
    required PrayerNotificationSchedule? schedule,
    required PermissionState permissions,
  });

  /// Cancels all notification IDs owned by the prayer scheduler.
  Future<void> cancelScheduledNotifications();
}
