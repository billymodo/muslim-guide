import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_guide/features/notifications/application/notification_schedule_provider.dart';
import 'package:muslim_guide/features/notifications/application/permission_provider.dart';
import 'package:muslim_guide/features/prayer/application/location_provider.dart';
import 'package:muslim_guide/features/prayer/application/prayer_times_provider.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;

import '../fake_notification_scheduler.dart';
import '../notification_test_fakes.dart';

class _FakeLocationNotifier extends LocationNotifier {
  @override
  LocationSelection? build() => null;

  @override
  Future<void> selectCity(String cityId) async {
    state = CitySelection(cityId);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(tz_data.initializeTimeZones);

  test('debounces repeated reschedule requests for 500 milliseconds', () async {
    final scheduler = FakeNotificationScheduler();
    final container = ProviderContainer(
      overrides: [notificationSchedulerProvider.overrideWithValue(scheduler)],
    );
    final subscription = container.listen(
      notificationScheduleProvider,
      (_, _) {},
    );
    addTearDown(subscription.close);
    addTearDown(container.dispose);

    await Future<void>.delayed(notificationScheduleDebounce);
    scheduler.scheduleRequests.clear();

    final notifier = container.read(notificationScheduleProvider.notifier);
    for (var index = 0; index < 3; index++) {
      notifier.reschedule();
    }
    await Future<void>.delayed(
      notificationScheduleDebounce + const Duration(milliseconds: 25),
    );

    expect(scheduler.scheduleRequests, hasLength(1));
    expect(scheduler.scheduleRequests.single, isNull);
  });

  test(
    'returns an explicit no-location state without platform scheduling',
    () async {
      final scheduler = FakeNotificationScheduler();
      final container = ProviderContainer(
        overrides: [notificationSchedulerProvider.overrideWithValue(scheduler)],
      );
      final subscription = container.listen(
        notificationScheduleProvider,
        (_, _) {},
      );
      addTearDown(subscription.close);
      addTearDown(container.dispose);

      await Future<void>.delayed(
        notificationScheduleDebounce + const Duration(milliseconds: 25),
      );

      expect(
        container.read(notificationScheduleProvider)?.hasNoLocation,
        isTrue,
      );
      expect(scheduler.scheduleRequests, [null]);
      expect(scheduler.cancelCalls, 1);
    },
  );

  test(
    'recalculates and schedules when the selected location changes',
    () async {
      const mecca = CitySelection('mecca');
      final scheduler = FakeNotificationScheduler();
      final permissionService = FakePermissionService();
      final container = ProviderContainer(
        overrides: [
          notificationSchedulerProvider.overrideWithValue(scheduler),
          permissionServiceProvider.overrideWithValue(permissionService),
          locationProvider.overrideWith(_FakeLocationNotifier.new),
        ],
      );
      final subscription = container.listen(
        notificationScheduleProvider,
        (_, _) {},
      );
      addTearDown(subscription.close);
      addTearDown(container.dispose);

      await Future<void>.delayed(
        notificationScheduleDebounce + const Duration(milliseconds: 25),
      );
      scheduler.scheduleRequests.clear();
      await container.read(locationProvider.notifier).selectCity(mecca.cityId);
      expect(await container.read(prayerTimesProvider.future), isNotNull);
      await Future<void>.delayed(
        notificationScheduleDebounce + const Duration(milliseconds: 75),
      );

      final schedule = scheduler.scheduleRequests.last;
      expect(schedule, isNotNull);
      expect(schedule!.timeZoneId, 'Asia/Riyadh');
      expect(schedule.notifications, isNotEmpty);
      expect(
        schedule.notifications.map((notification) => notification.id).toSet(),
        hasLength(schedule.notifications.length),
      );
      expect(container.read(notificationScheduleProvider)?.isScheduled, isTrue);
    },
  );
}
