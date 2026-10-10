import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_guide/features/notifications/data/flutter_local_notification_scheduler.dart';
import 'package:muslim_guide/features/notifications/domain/permission_state.dart';
import 'package:muslim_guide/features/notifications/domain/permission_status.dart';
import 'package:muslim_guide/features/notifications/domain/prayer_notification.dart';
import 'package:muslim_guide/features/notifications/domain/schedule_result.dart';
import 'package:timezone/timezone.dart' as tz;

import 'fake_local_notification_api.dart';

const PermissionState _granted = PermissionState(
  notifications: PermissionStatus.granted,
  exactAlarms: PermissionStatus.granted,
);

PrayerNotificationSchedule _schedule({
  List<ScheduledPrayerNotification>? notifications,
}) {
  return PrayerNotificationSchedule(
    timeZoneId: 'Asia/Riyadh',
    notifications:
        notifications ??
        [
          ScheduledPrayerNotification(
            prayer: PrayerNotification.fajr,
            dayOffset: 0,
            scheduledAt: tz.TZDateTime.from(DateTime.utc(2026), tz.UTC),
            title: 'Fajr Prayer',
            body: 'Prayer time',
          ),
        ],
  );
}

void main() {
  test(
    'returns noLocation without initializing or calling the platform API',
    () async {
      final api = FakeLocalNotificationApi();
      final scheduler = FlutterLocalNotificationScheduler(api);

      final result = await scheduler.schedule(
        schedule: null,
        permissions: _granted,
        channelName: 'Prayer Adhan',
        channelDescription: 'Adhan alerts',
      );

      expect(result.status, ScheduleResultStatus.noLocation);
      expect(api.initializeCalls, 0);
      expect(api.createChannelCalls, 0);
      expect(api.cancelCalls, 0);
      expect(api.scheduledNotifications, isEmpty);
    },
  );

  test(
    'returns exactAlarmsDenied without inexact scheduling fallback',
    () async {
      final api = FakeLocalNotificationApi();
      final scheduler = FlutterLocalNotificationScheduler(api);
      const deniedExactAlarm = PermissionState(
        notifications: PermissionStatus.granted,
        exactAlarms: PermissionStatus.denied,
      );

      final result = await scheduler.schedule(
        schedule: _schedule(),
        permissions: deniedExactAlarm,
        channelName: 'Prayer Adhan',
        channelDescription: 'Adhan alerts',
      );

      expect(result.status, ScheduleResultStatus.failed);
      expect(result.reason, ScheduleFailureReason.exactAlarmsDenied);
      expect(api.initializeCalls, 0);
      expect(api.createChannelCalls, 0);
      expect(api.cancelCalls, 0);
      expect(api.scheduledNotifications, isEmpty);
    },
  );

  test('does not schedule when notification permission is denied', () async {
    final api = FakeLocalNotificationApi();
    final scheduler = FlutterLocalNotificationScheduler(api);
    const deniedNotifications = PermissionState(
      notifications: PermissionStatus.denied,
      exactAlarms: PermissionStatus.granted,
    );

    final result = await scheduler.schedule(
      schedule: _schedule(),
      permissions: deniedNotifications,
      channelName: 'Prayer Adhan',
      channelDescription: 'Adhan alerts',
    );

    expect(result.reason, ScheduleFailureReason.notificationsDenied);
    expect(api.initializeCalls, 0);
    expect(api.scheduledNotifications, isEmpty);
  });

  test(
    'schedules exact-eligible notifications and cancels stale horizon IDs',
    () async {
      final api = FakeLocalNotificationApi();
      final scheduler = FlutterLocalNotificationScheduler(api);

      final result = await scheduler.schedule(
        schedule: _schedule(),
        permissions: _granted,
        channelName: 'Prayer Adhan',
        channelDescription: 'Adhan alerts',
      );

      expect(result.isScheduled, isTrue);
      expect(result.scheduledCount, 1);
      expect(api.initializeCalls, 1);
      expect(api.createChannelCalls, 1);
      expect(api.createdChannelName, 'Prayer Adhan');
      expect(api.createdChannelDescription, 'Adhan alerts');
      expect(api.cancelledIds, hasLength(35));
      expect(api.cancelledIds.toSet(), hasLength(35));
      expect(api.scheduledNotifications.single.id, 0);
      expect(api.scheduledNotifications.single.channelId, 'prayer_adhan_v1');
      expect(api.scheduledNotifications.single.title, 'Fajr Prayer');
    },
  );

  test(
    'reports scheduling failure and cancels partially scheduled alarms',
    () async {
      final api = FakeLocalNotificationApi()..failScheduleId = 1000;
      final scheduler = FlutterLocalNotificationScheduler(api);
      final schedule = _schedule(
        notifications: [
          ScheduledPrayerNotification(
            prayer: PrayerNotification.fajr,
            dayOffset: 0,
            scheduledAt: tz.TZDateTime.from(DateTime.utc(2026), tz.UTC),
            title: 'Fajr Prayer',
            body: 'Prayer time',
          ),
          ScheduledPrayerNotification(
            prayer: PrayerNotification.dhuhr,
            dayOffset: 0,
            scheduledAt: tz.TZDateTime.from(DateTime.utc(2026, 1, 2), tz.UTC),
            title: 'Dhuhr Prayer',
            body: 'Prayer time',
          ),
        ],
      );

      final result = await scheduler.schedule(
        schedule: schedule,
        permissions: _granted,
        channelName: 'Prayer Adhan',
        channelDescription: 'Adhan alerts',
      );

      expect(result.reason, ScheduleFailureReason.schedulingFailed);
      expect(result.error, isA<StateError>());
      expect(api.scheduledNotifications, isEmpty);
      expect(api.cancelledIds, hasLength(70));
    },
  );

  test('reports plugin initialization failure', () async {
    final api = FakeLocalNotificationApi()..initializeResult = false;
    final scheduler = FlutterLocalNotificationScheduler(api);

    final result = await scheduler.schedule(
      schedule: _schedule(),
      permissions: _granted,
      channelName: 'Prayer Adhan',
      channelDescription: 'Adhan alerts',
    );

    expect(result.reason, ScheduleFailureReason.schedulingFailed);
    expect(api.initializeCalls, 1);
    expect(api.scheduledNotifications, isEmpty);
  });

  test(
    'allows exact alarms on Android versions where access is not applicable',
    () async {
      final api = FakeLocalNotificationApi();
      final scheduler = FlutterLocalNotificationScheduler(api);
      const preExactAlarmApi = PermissionState(
        notifications: PermissionStatus.notApplicable,
        exactAlarms: PermissionStatus.notApplicable,
      );

      final result = await scheduler.schedule(
        schedule: _schedule(),
        permissions: preExactAlarmApi,
        channelName: 'Prayer Adhan',
        channelDescription: 'Adhan alerts',
      );

      expect(result.isScheduled, isTrue);
      expect(api.scheduledNotifications, hasLength(1));
    },
  );
}
