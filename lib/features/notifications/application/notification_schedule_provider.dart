import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muslim_guide/app/providers/bootstrap_provider.dart';
import 'package:muslim_guide/features/notifications/application/permission_provider.dart';
import 'package:muslim_guide/features/notifications/application/prayer_schedule_builder.dart';
import 'package:muslim_guide/features/notifications/data/flutter_local_notification_api.dart';
import 'package:muslim_guide/features/notifications/data/flutter_local_notification_scheduler.dart';
import 'package:muslim_guide/features/notifications/data/local_notification_api.dart';
import 'package:muslim_guide/features/notifications/domain/notification_scheduler.dart';
import 'package:muslim_guide/features/notifications/domain/permission_state.dart';
import 'package:muslim_guide/features/notifications/domain/permission_status.dart';
import 'package:muslim_guide/features/notifications/domain/prayer_notification.dart';
import 'package:muslim_guide/features/notifications/domain/schedule_result.dart';
import 'package:muslim_guide/features/prayer/application/asr_method_provider.dart';
import 'package:muslim_guide/features/prayer/application/calculation_method_provider.dart';
import 'package:muslim_guide/features/prayer/application/high_latitude_rule_provider.dart';
import 'package:muslim_guide/features/prayer/application/location_provider.dart';
import 'package:muslim_guide/features/prayer/application/prayer_times_provider.dart';
import 'package:muslim_guide/l10n/app_localizations.dart';
import 'package:timezone/timezone.dart' as tz;

/// Debounce interval for changes that invalidate scheduled prayer times.
const Duration notificationScheduleDebounce = Duration(milliseconds: 500);

/// Provides the local-notification plugin instance shared with permission APIs.
final Provider<LocalNotificationApi> localNotificationApiProvider =
    Provider<LocalNotificationApi>((ref) {
      final plugin = ref.watch(notificationPluginProvider);
      return FlutterLocalNotificationApi(plugin);
    });

/// Provides the scheduler abstraction.
final Provider<NotificationScheduler> notificationSchedulerProvider =
    Provider<NotificationScheduler>((ref) {
      return FlutterLocalNotificationScheduler(
        ref.watch(localNotificationApiProvider),
      );
    });

/// Provides the current scheduling outcome and starts automatic reconciliation.
final NotifierProvider<NotificationScheduleNotifier, ScheduleResult?>
notificationScheduleProvider =
    NotifierProvider<NotificationScheduleNotifier, ScheduleResult?>(
      NotificationScheduleNotifier.new,
    );

/// Coordinates rescheduling when prayer inputs or app lifecycle change.
class NotificationScheduleNotifier extends Notifier<ScheduleResult?> {
  Timer? _debounceTimer;
  Future<void> _rescheduleQueue = Future<void>.value();
  bool _disposed = false;
  late _ScheduleLifecycleObserver _lifecycleObserver;

  @override
  ScheduleResult? build() {
    _disposed = false;
    ref.listen(prayerTimesProvider, (_, _) => _scheduleDebounced());
    ref.listen(locationProvider, (_, _) => _scheduleDebounced());
    ref.listen(calculationMethodProvider, (_, _) => _scheduleDebounced());
    ref.listen(asrMethodProvider, (_, _) => _scheduleDebounced());
    ref.listen(highLatitudeRuleProvider, (_, _) => _scheduleDebounced());
    ref.listen(permissionStateProvider, (_, _) => _scheduleDebounced());

    _lifecycleObserver = _ScheduleLifecycleObserver(
      onResumed: _refreshTimezoneAndSchedule,
    );
    WidgetsBinding.instance.addObserver(_lifecycleObserver);
    ref.onDispose(() {
      _disposed = true;
      _debounceTimer?.cancel();
      WidgetsBinding.instance.removeObserver(_lifecycleObserver);
    });

    _scheduleDebounced();
    return null;
  }

  /// Requests an immediate, debounced schedule reconciliation.
  void reschedule() => _scheduleDebounced();

  void _scheduleDebounced() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(notificationScheduleDebounce, () {
      unawaited(_enqueueReschedule());
    });
  }

  Future<void> _enqueueReschedule() {
    return _rescheduleQueue = _rescheduleQueue.then((_) => _reschedule());
  }

  Future<void> _refreshTimezoneAndSchedule() async {
    await setLocalTimezone();
    _scheduleDebounced();
  }

  Future<void> _reschedule() async {
    try {
      final scheduler = ref.read(notificationSchedulerProvider);
      final localizations = await AppLocalizations.delegate.load(
        ref.read(appLocaleProvider),
      );
      if (ref.read(locationProvider) == null) {
        await scheduler.cancelScheduledNotifications();
        final noLocation = await scheduler.schedule(
          schedule: null,
          permissions: const PermissionState(
            notifications: PermissionStatus.notApplicable,
            exactAlarms: PermissionStatus.notApplicable,
          ),
          channelName: localizations.notif_channel_prayer_adhan_name,
          channelDescription:
              localizations.notif_channel_prayer_adhan_description,
        );
        if (!_disposed) state = noLocation;
        return;
      }

      final calculation = await ref.read(prayerTimesProvider.future);
      if (calculation == null) {
        await scheduler.cancelScheduledNotifications();
        final result = await scheduler.schedule(
          schedule: null,
          permissions: const PermissionState(
            notifications: PermissionStatus.notApplicable,
            exactAlarms: PermissionStatus.notApplicable,
          ),
          channelName: localizations.notif_channel_prayer_adhan_name,
          channelDescription:
              localizations.notif_channel_prayer_adhan_description,
        );
        if (!_disposed) state = result;
        return;
      }

      final permissionService = ref.read(permissionServiceProvider);
      final permissionState = await permissionService.getStatus();
      final schedule = buildPrayerNotificationSchedule(
        calculationTemplate: calculation,
        repository: ref.read(prayerTimesRepositoryProvider),
        now: tz.TZDateTime.now(tz.getLocation(calculation.location.timeZoneId)),
        body: localizations.notif_prayer_body,
        titleForPrayer: (prayer) => switch (prayer) {
          PrayerNotification.fajr => localizations.notif_prayer_title_fajr,
          PrayerNotification.dhuhr => localizations.notif_prayer_title_dhuhr,
          PrayerNotification.asr => localizations.notif_prayer_title_asr,
          PrayerNotification.maghrib =>
            localizations.notif_prayer_title_maghrib,
          PrayerNotification.isha => localizations.notif_prayer_title_isha,
        },
      );
      final result = await scheduler.schedule(
        schedule: schedule,
        permissions: permissionState,
        channelName: localizations.notif_channel_prayer_adhan_name,
        channelDescription:
            localizations.notif_channel_prayer_adhan_description,
      );
      if (!_disposed) state = result;
    } on Object catch (error) {
      if (!_disposed) {
        state = ScheduleResult.failed(
          reason: ScheduleFailureReason.schedulingFailed,
          error: error,
        );
      }
    }
  }
}

class _ScheduleLifecycleObserver with WidgetsBindingObserver {
  new({required this.onResumed});

  final Future<void> Function() onResumed;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) unawaited(onResumed());
  }
}
