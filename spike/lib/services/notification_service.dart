import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

/// خدمة إشعارات Spike — flutter_local_notifications 22.3.1.
class NotificationService {
  /// Creates the service; [plugin] يسمح بالإقلاع في الاختبارات.
  new({FlutterLocalNotificationsPlugin? plugin})
      : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;

  static bool _tzReady = false;

  /// معرّف الإشعار المستخدم في اختبار الجدولة.
  static const int scheduledNotificationId = 1;

  static void _ensureTz() {
    if (!_tzReady) {
      tzdata.initializeTimeZones();
      _tzReady = true;
    }
  }

  /// يهيّئ القناة ويطلب صلاحيات Android 13+ و exact alarm.
  Future<void> init() async {
    _ensureTz();
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const initSettings = InitializationSettings(android: androidSettings);
    await _plugin.initialize(settings: initSettings);
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await android?.requestNotificationsPermission();
    await android?.requestExactAlarmsPermission();
  }

  /// اللحظة المطلوبة لجدولة [seconds] ثانية من الآن (بوقت مطلق UTC).
  tz.TZDateTime scheduleTime(int seconds) {
    _ensureTz();
    return tz.TZDateTime.from(
      DateTime.now().add(Duration(seconds: seconds)),
      tz.UTC,
    );
  }

  /// يجدول إشعارًا بعد [seconds] ثانية بتوقيت دقيق (exact alarm).
  Future<void> scheduleIn(int seconds) async {
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'spike_channel',
        'Spike 00B',
        channelDescription: 'إشعارات Spike المؤقتة',
        importance: Importance.max,
        priority: Priority.high,
      ),
    );
    await _plugin.zonedSchedule(
      id: scheduledNotificationId,
      title: 'Spike 00B',
      body: 'إشعار بعد $seconds ثانية',
      scheduledDate: scheduleTime(seconds),
      notificationDetails: details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }
}
