import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

/// خدمة إشعارات Spike — flutter_local_notifications 22.3.1.
class NotificationService {
  /// Creates the service; [plugin] يسمح بالإقلاع في الاختبارات.
  new({FlutterLocalNotificationsPlugin? plugin})
      : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'spike_channel_main',
    'Spike Notifications',
    description: 'Test notifications for spike',
    importance: Importance.max,
  );

  static bool _tzReady = false;

  /// معرّف الإشعار المستخدم في اختبار الجدولة.
  static const int scheduledNotificationId = 1;

  Future<void> _createChannel() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await android?.createNotificationChannel(_channel);
  }

  static void _ensureTz() {
    if (!_tzReady) {
      tzdata.initializeTimeZones();
      tz.setLocalLocation(tz.getLocation('Asia/Riyadh'));
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
    await _createChannel();
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await android?.requestNotificationsPermission();
    await android?.requestExactAlarmsPermission();
  }

  /// اللحظة المطلوبة لجدولة [seconds] ثانية من الآن (بالتوقيت المحلي).
  tz.TZDateTime scheduleTime(int seconds) {
    _ensureTz();
    return tz.TZDateTime.now(tz.local).add(Duration(seconds: seconds));
  }

  NotificationDetails _details() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        'spike_channel_main',
        'Spike Notifications',
        channelDescription: 'Test notifications for spike',
        importance: Importance.max,
        priority: Priority.high,
      ),
    );
  }

  /// يجدول إشعارًا بعد [seconds] ثانية بتوقيت دقيق (exact alarm).
  Future<void> scheduleIn(int seconds) async {
    try {
      _ensureTz();
      await _createChannel();
      final details = _details();
      await _plugin.zonedSchedule(
        id: scheduledNotificationId,
        title: 'Spike 00B',
        body: 'إشعار بعد $seconds ثانية',
        scheduledDate: scheduleTime(seconds),
        notificationDetails: details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
      debugPrint('[SCHEDULE-OK] scheduled for ${scheduleTime(seconds)}');
    } on PlatformException catch (e, st) {
      debugPrint(
        '[SCHEDULE-FAIL] PlatformException: '
        '${e.code} — ${e.message}\n$st',
      );
      rethrow;
    } catch (e, st) {
      debugPrint('[SCHEDULE-FAIL] $e\n$st');
      rethrow;
    }
  }
}
