import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_guide/features/notifications/application/prayer_schedule_builder.dart';
import 'package:muslim_guide/features/notifications/domain/prayer_notification.dart';
import 'package:muslim_guide/features/prayer/data/repositories/prayer_times_repository_impl.dart';
import 'package:muslim_guide/features/prayer/domain/models/location_data.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

void main() {
  setUpAll(tz_data.initializeTimeZones);

  test('builds five local prayer notifications for each of seven days', () {
    const repository = PrayerTimesRepositoryImpl();
    const location = LocationData(
      latitude: 40.7128,
      longitude: -74.006,
      timeZoneId: 'America/New_York',
    );
    final zone = tz.getLocation(location.timeZoneId);
    final now = tz.TZDateTime(zone, 2026, 3, 7);
    final template = repository.calculate(location: location, date: now);

    final schedule = buildPrayerNotificationSchedule(
      calculationTemplate: template,
      repository: repository,
      now: now,
      body: 'Prayer time',
      titleForPrayer: (prayer) => prayer.name,
    );

    expect(schedule.timeZoneId, 'America/New_York');
    expect(schedule.notifications, hasLength(35));
    expect(
      schedule.notifications.map((notification) => notification.id).toSet(),
      hasLength(35),
    );
    expect(
      schedule.notifications
          .map((notification) => notification.dayOffset)
          .toSet(),
      {0, 1, 2, 3, 4, 5, 6},
    );
    expect(
      schedule.notifications.every(
        (notification) => notification.scheduledAt.isAfter(now),
      ),
      isTrue,
    );
  });

  test('uses IANA timezone rules across a daylight-saving transition', () {
    const repository = PrayerTimesRepositoryImpl();
    const location = LocationData(
      latitude: 40.7128,
      longitude: -74.006,
      timeZoneId: 'America/New_York',
    );
    final zone = tz.getLocation(location.timeZoneId);
    final now = tz.TZDateTime(zone, 2026, 3, 7);
    final template = repository.calculate(location: location, date: now);

    final schedule = buildPrayerNotificationSchedule(
      calculationTemplate: template,
      repository: repository,
      now: now,
      body: 'Prayer time',
      titleForPrayer: (prayer) => prayer.name,
    );
    final offsets = schedule.notifications
        .map((notification) => notification.scheduledAt.timeZoneOffset.inHours)
        .toSet();

    expect(offsets, containsAll([-5, -4]));
  });

  test('uses the specified title and body for each prayer', () {
    const repository = PrayerTimesRepositoryImpl();
    const location = LocationData(
      latitude: 24.6333,
      longitude: 46.7167,
      timeZoneId: 'Asia/Riyadh',
    );
    final zone = tz.getLocation(location.timeZoneId);
    final now = tz.TZDateTime(zone, 2026, 10, 10);
    final template = repository.calculate(location: location, date: now);

    final schedule = buildPrayerNotificationSchedule(
      calculationTemplate: template,
      repository: repository,
      now: now,
      body: 'Prayer time',
      titleForPrayer: (prayer) => '${prayer.name} prayer',
    );

    expect(schedule.notifications, isNotEmpty);
    expect(
      schedule.notifications.every(
        (notification) =>
            notification.title.endsWith(' prayer') &&
            notification.body == 'Prayer time',
      ),
      isTrue,
    );
    expect(
      schedule.notifications.any(
        (notification) => notification.prayer == PrayerNotification.fajr,
      ),
      isTrue,
    );
  });
}
