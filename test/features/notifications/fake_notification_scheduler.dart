import 'package:muslim_guide/features/notifications/domain/notification_scheduler.dart';
import 'package:muslim_guide/features/notifications/domain/permission_state.dart';
import 'package:muslim_guide/features/notifications/domain/permission_status.dart';
import 'package:muslim_guide/features/notifications/domain/prayer_notification.dart';
import 'package:muslim_guide/features/notifications/domain/schedule_result.dart';

class FakeNotificationScheduler implements NotificationScheduler {
  final List<PrayerNotificationSchedule?> scheduleRequests = [];
  int cancelCalls = 0;

  @override
  Future<ScheduleResult> schedule({
    required PrayerNotificationSchedule? schedule,
    required PermissionState permissions,
  }) async {
    scheduleRequests.add(schedule);
    if (schedule == null) return const ScheduleResult.noLocation();
    if (permissions.notifications != PermissionStatus.granted) {
      return const ScheduleResult.failed(
        reason: ScheduleFailureReason.notificationsDenied,
      );
    }
    if (permissions.exactAlarms != PermissionStatus.granted) {
      return const ScheduleResult.failed(
        reason: ScheduleFailureReason.exactAlarmsDenied,
      );
    }
    return ScheduleResult.scheduled(
      scheduledCount: schedule.notifications.length,
    );
  }

  @override
  Future<void> cancelScheduledNotifications() async {
    cancelCalls++;
  }
}
