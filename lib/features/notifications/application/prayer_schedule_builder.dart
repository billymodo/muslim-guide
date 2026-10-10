import 'package:muslim_guide/features/notifications/domain/prayer_notification.dart';
import 'package:muslim_guide/features/prayer/domain/models/prayer_times_result.dart';
import 'package:muslim_guide/features/prayer/domain/repositories/prayer_times_repository.dart';
import 'package:timezone/timezone.dart' as tz;

/// Builds a seven-day local-calendar schedule from prayer-calculation inputs.
PrayerNotificationSchedule buildPrayerNotificationSchedule({
  required PrayerTimesResult calculationTemplate,
  required PrayerTimesRepository repository,
  required DateTime now,
  required String body,
  required String Function(PrayerNotification prayer) titleForPrayer,
}) {
  final location = tz.getLocation(calculationTemplate.location.timeZoneId);
  final localNow = tz.TZDateTime.from(now, location);
  final firstDay = tz.TZDateTime(
    location,
    localNow.year,
    localNow.month,
    localNow.day,
  );
  final notifications = <ScheduledPrayerNotification>[];

  for (var dayOffset = 0;
      dayOffset < ScheduledPrayerNotification.horizonDays;
      dayOffset++) {
    final localDate = tz.TZDateTime(
      location,
      firstDay.year,
      firstDay.month,
      firstDay.day + dayOffset,
    );
    final prayerTimes = repository.calculate(
      location: calculationTemplate.location,
      date: localDate,
      method: calculationTemplate.method,
      asrMethod: calculationTemplate.asrMethod,
      highLatRule: calculationTemplate.highLatRule,
    );
    final times = <PrayerNotification, DateTime?>{
      PrayerNotification.fajr: prayerTimes.fajr,
      PrayerNotification.dhuhr: prayerTimes.dhuhr,
      PrayerNotification.asr: prayerTimes.asr,
      PrayerNotification.maghrib: prayerTimes.maghrib,
      PrayerNotification.isha: prayerTimes.isha,
    };

    for (final entry in times.entries) {
      final prayerTime = entry.value;
      if (prayerTime == null || !prayerTime.isAfter(localNow)) continue;
      notifications.add(
        ScheduledPrayerNotification(
          prayer: entry.key,
          dayOffset: dayOffset,
          scheduledAt: tz.TZDateTime.from(prayerTime, location),
          title: titleForPrayer(entry.key),
          body: body,
        ),
      );
    }
  }

  return PrayerNotificationSchedule(
    timeZoneId: calculationTemplate.location.timeZoneId,
    notifications: List.unmodifiable(notifications),
  );
}
