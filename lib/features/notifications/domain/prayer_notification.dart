import 'package:timezone/timezone.dart' as tz;

/// The five obligatory prayers that can have scheduled notifications.
enum PrayerNotification {
  /// Fajr prayer.
  fajr,

  /// Dhuhr prayer.
  dhuhr,

  /// Asr prayer.
  asr,

  /// Maghrib prayer.
  maghrib,

  /// Isha prayer.
  isha,
}

/// One scheduled notification for a prayer in the rolling schedule horizon.
class ScheduledPrayerNotification {
  /// Creates a localized prayer notification.
  const new({
    required this.prayer,
    required this.dayOffset,
    required this.scheduledAt,
    required this.title,
    required this.body,
  }) : assert(
         dayOffset >= 0 && dayOffset < horizonDays,
         'dayOffset must be in the range 0..6.',
       );

  /// Number of local calendar days represented by the rolling schedule.
  static const int horizonDays = 7;

  /// Prayer this notification represents.
  final PrayerNotification prayer;

  /// Local-calendar day offset in the current schedule horizon.
  final int dayOffset;

  /// Timezone-aware time at which to deliver the notification.
  final tz.TZDateTime scheduledAt;

  /// Localized notification title.
  final String title;

  /// Localized notification body.
  final String body;

  /// Stable plugin notification ID: prayer index times 1000 plus day offset.
  int get id => prayer.index * 1000 + dayOffset;

  /// ARB localization key for the prayer title.
  String get titleKey => switch (prayer) {
    PrayerNotification.fajr => 'notif_prayer_title_fajr',
    PrayerNotification.dhuhr => 'notif_prayer_title_dhuhr',
    PrayerNotification.asr => 'notif_prayer_title_asr',
    PrayerNotification.maghrib => 'notif_prayer_title_maghrib',
    PrayerNotification.isha => 'notif_prayer_title_isha',
  };
}

/// A complete set of notifications to reconcile with the OS scheduler.
class PrayerNotificationSchedule {
  /// Creates a schedule using location-local calendar dates.
  const new({
    required this.timeZoneId,
    required this.notifications,
  });

  /// IANA timezone used to calculate and schedule these occurrences.
  final String timeZoneId;

  /// Notifications within the seven-day rolling horizon.
  final List<ScheduledPrayerNotification> notifications;
}
