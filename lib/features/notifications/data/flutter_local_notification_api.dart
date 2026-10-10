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
  Future<void> zonedSchedule({
    required int id,
    required tz.TZDateTime scheduledAt,
    required String title,
    required String body,
  }) {
    return _plugin.zonedSchedule(
      id: id,
      scheduledDate: scheduledAt,
      title: title,
      body: body,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'prayer_notifications',
          'Prayer notifications',
          channelDescription: 'Scheduled prayer time notifications',
          importance: Importance.max,
          priority: Priority.high,
          playSound: false,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  @override
  Future<void> cancel(int id) => _plugin.cancel(id: id);
}
