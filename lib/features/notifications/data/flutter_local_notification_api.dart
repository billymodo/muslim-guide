import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:muslim_guide/features/notifications/data/local_notification_api.dart';
import 'package:timezone/timezone.dart' as tz;

/// `flutter_local_notifications` implementation of [LocalNotificationApi].
class FlutterLocalNotificationApi implements LocalNotificationApi {
  /// Creates the adapter around the shared plugin instance.
  new(this._plugin);

  final FlutterLocalNotificationsPlugin _plugin;

  @override
  Future<bool?> initialize() {
    return _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      ),
    );
  }

  @override
  Future<void> createPrayerAdhanChannel({
    required String name,
    required String description,
  }) async {
    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (androidPlugin == null) {
      throw StateError('Android notification channel is unavailable.');
    }
    await androidPlugin.createNotificationChannel(
      AndroidNotificationChannel(
        prayerAdhanNotificationChannelId,
        name,
        description: description,
        importance: Importance.max,
        sound: const RawResourceAndroidNotificationSound(
          'adhan',
        ),
      ),
    );
  }

  @override
  Future<void> zonedSchedule({
    required int id,
    required tz.TZDateTime scheduledAt,
    required String title,
    required String body,
    required String channelId,
  }) {
    return _plugin.zonedSchedule(
      id: id,
      scheduledDate: scheduledAt,
      title: title,
      body: body,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          'Prayer notifications',
          channelDescription: 'Scheduled prayer time notifications',
          importance: Importance.max,
          priority: Priority.high,
          sound: const RawResourceAndroidNotificationSound(
            'adhan',
          ),
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  @override
  Future<void> cancel(int id) => _plugin.cancel(id: id);
}
