import 'package:muslim_guide/features/notifications/data/local_notification_api.dart';
import 'package:muslim_guide/features/notifications/domain/notification_scheduler.dart';
import 'package:muslim_guide/features/notifications/domain/permission_state.dart';
import 'package:muslim_guide/features/notifications/domain/permission_status.dart';
import 'package:muslim_guide/features/notifications/domain/prayer_notification.dart';
import 'package:muslim_guide/features/notifications/domain/schedule_result.dart';

/// OS scheduler backed by `flutter_local_notifications`.
class FlutterLocalNotificationScheduler implements NotificationScheduler {
  /// Creates the scheduler with a platform API that can be replaced by fakes.
  new(this._api);

  final LocalNotificationApi _api;
  Future<void>? _initialization;
  Future<void>? _channelCreation;

  @override
  Future<ScheduleResult> schedule({
    required PrayerNotificationSchedule? schedule,
    required PermissionState permissions,
    required String channelName,
    required String channelDescription,
  }) async {
    if (schedule == null) return const ScheduleResult.noLocation();
    if (permissions.notifications == PermissionStatus.denied) {
      return const ScheduleResult.failed(
        reason: ScheduleFailureReason.notificationsDenied,
      );
    }
    if (permissions.exactAlarms == PermissionStatus.denied) {
      return const ScheduleResult.failed(
        reason: ScheduleFailureReason.exactAlarmsDenied,
      );
    }
    var canCleanUp = false;
    try {
      await initialize(
        channelName: channelName,
        channelDescription: channelDescription,
      );
      canCleanUp = true;
      await _cancelPrayerNotifications();
      if (schedule.notifications.isEmpty) {
        return const ScheduleResult.failed(
          reason: ScheduleFailureReason.noPrayerTimes,
        );
      }
      for (final notification in schedule.notifications) {
        await _api.zonedSchedule(
          id: notification.id,
          scheduledAt: notification.scheduledAt,
          title: notification.title,
          body: notification.body,
          channelId: prayerAdhanNotificationChannelId,
        );
      }
      return ScheduleResult.scheduled(
        scheduledCount: schedule.notifications.length,
      );
    } on Object catch (error) {
      if (canCleanUp) {
        try {
          await _cancelPrayerNotifications();
        } on Object catch (cleanupError) {
          return ScheduleResult.failed(
            reason: ScheduleFailureReason.schedulingFailed,
            error: StateError(
              'Scheduling failed: $error; cleanup failed: $cleanupError',
            ),
          );
        }
      }
      return ScheduleResult.failed(
        reason: ScheduleFailureReason.schedulingFailed,
        error: error,
      );
    }
  }

  @override
  Future<void> cancelScheduledNotifications() async {
    await _ensureInitialized();
    await _cancelPrayerNotifications();
  }

  /// Creates the versioned prayer channel before its first scheduled use.
  Future<void> initialize({
    required String channelName,
    required String channelDescription,
  }) async {
    await _ensureInitialized();
    await (_channelCreation ??= _createPrayerAdhanChannel(
      name: channelName,
      description: channelDescription,
    ));
  }

  Future<void> _createPrayerAdhanChannel({
    required String name,
    required String description,
  }) async {
    try {
      await _api.createPrayerAdhanChannel(name: name, description: description);
    } on Object {
      _channelCreation = null;
      rethrow;
    }
  }

  Future<void> _cancelPrayerNotifications() async {
    for (final prayer in PrayerNotification.values) {
      for (
        var dayOffset = 0;
        dayOffset < ScheduledPrayerNotification.horizonDays;
        dayOffset++
      ) {
        await _api.cancel(prayer.index * 1000 + dayOffset);
      }
    }
  }

  Future<void> _ensureInitialized() {
    return _initialization ??= _initialize();
  }

  Future<void> _initialize() async {
    final initialized = await _api.initialize();
    if (initialized != true) {
      _initialization = null;
      throw StateError('Could not initialize local notifications.');
    }
  }
}
