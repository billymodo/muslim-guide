import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:muslim_guide/features/notifications/application/prayer_schedule_builder.dart';
import 'package:muslim_guide/features/notifications/domain/prayer_notification.dart';
import 'package:muslim_guide/features/prayer/data/repositories/prayer_times_repository_impl.dart';
import 'package:muslim_guide/features/prayer/domain/models/location_data.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// Task 10: end-to-end schedule flow on a real device.
///
/// Builds a real 7-day schedule for Riyadh, then rebuilds with Fajr
/// disabled and with everything disabled — proving the toggle-to-schedule
/// path that the unit tests cover with fakes.
///
/// Device evidence (manual): `adb shell dumpsys alarm | grep muslimguide`
/// shows the live alarms; toggling Fajr off removes its entries.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  tz_data.initializeTimeZones();

  testWidgets('schedule shrinks as prayers are disabled', (tester) async {
    const repository = PrayerTimesRepositoryImpl();
    const location = LocationData(
      latitude: 24.7136,
      longitude: 46.6753,
      timeZoneId: 'Asia/Riyadh',
    );
    final zone = tz.getLocation(location.timeZoneId);
    final now = tz.TZDateTime.now(zone);
    final template = repository.calculate(location: location, date: now);

    PrayerNotificationSchedule buildWith(Set<PrayerNotification> enabled) =>
        buildPrayerNotificationSchedule(
          calculationTemplate: template,
          repository: repository,
          now: now,
          body: 'Prayer time',
          titleForPrayer: (prayer) => prayer.name,
          enabledPrayers: enabled,
        );

    final full = buildWith(PrayerNotification.values.toSet());
    expect(full.notifications, isNotEmpty);
    final fullCount = full.notifications.length;

    final withoutFajr = buildWith(
      PrayerNotification.values.toSet()..remove(PrayerNotification.fajr),
    );
    expect(
      withoutFajr.notifications.any(
        (notification) => notification.prayer == PrayerNotification.fajr,
      ),
      isFalse,
    );
    expect(withoutFajr.notifications.length, lessThan(fullCount));

    final empty = buildWith(const {});
    expect(empty.notifications, isEmpty);
  });
}
