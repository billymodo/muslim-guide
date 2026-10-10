import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_guide/features/notifications/domain/permission_state.dart';
import 'package:muslim_guide/features/notifications/domain/permission_status.dart';
import 'package:muslim_guide/features/notifications/domain/prayer_notification.dart';
import 'package:muslim_guide/features/notifications/domain/schedule_result.dart';
import 'package:timezone/timezone.dart' as tz;

void main() {
  group('ScheduledPrayerNotification', () {
    test('uses the approved prayer index ordering', () {
      expect(PrayerNotification.values, [
        PrayerNotification.fajr,
        PrayerNotification.dhuhr,
        PrayerNotification.asr,
        PrayerNotification.maghrib,
        PrayerNotification.isha,
      ]);
    });

    test('uses prayer index times 1000 plus local calendar day offset', () {
      final ids = [
        for (final prayer in PrayerNotification.values)
          for (var dayOffset = 0; dayOffset < 7; dayOffset++)
            prayer.index * 1000 + dayOffset,
      ];

      expect(ids.toSet(), hasLength(ids.length));
      expect(ids.first, 0);
      expect(ids.last, 4006);
      expect(ids, everyElement(inInclusiveRange(0, 6006)));
    });

    test('defines seven local calendar days in the horizon', () {
      expect(ScheduledPrayerNotification.horizonDays, 7);
    });

    test('rejects day offsets outside the rolling horizon in debug mode', () {
      expect(
        () => ScheduledPrayerNotification(
          prayer: PrayerNotification.fajr,
          dayOffset: 7,
          scheduledAt: tz.TZDateTime.from(DateTime.utc(2026), tz.UTC),
          title: 'Fajr Prayer',
          body: 'Prayer time',
        ),
        throwsAssertionError,
      );
    });
  });

  group('ScheduleResult', () {
    test('represents no location explicitly', () {
      const result = ScheduleResult.noLocation();

      expect(result.status, ScheduleResultStatus.noLocation);
      expect(result.hasNoLocation, isTrue);
      expect(result.hasFailed, isFalse);
    });

    test('retains exact-alarm denial as a failed outcome', () {
      const result = ScheduleResult.failed(
        reason: ScheduleFailureReason.exactAlarmsDenied,
      );

      expect(result.status, ScheduleResultStatus.failed);
      expect(result.reason, ScheduleFailureReason.exactAlarmsDenied);
    });

    test('retains the current three-state permission values', () {
      expect(
        const PermissionState(
          notifications: PermissionStatus.granted,
          exactAlarms: PermissionStatus.denied,
        ).exactAlarms,
        PermissionStatus.denied,
      );
    });
  });
}
