import 'package:muslim_guide/features/notifications/data/local_notification_api.dart';
import 'package:timezone/timezone.dart' as tz;

class FakeLocalNotificationApi implements LocalNotificationApi {
  bool? initializeResult = true;
  int initializeCalls = 0;
  int cancelCalls = 0;
  int? failScheduleId;
  final List<int> cancelledIds = [];
  final List<({int id, tz.TZDateTime scheduledAt, String title, String body})>
  scheduledNotifications = [];

  @override
  Future<bool?> initialize() async {
    initializeCalls++;
    return initializeResult;
  }

  @override
  Future<void> zonedSchedule({
    required int id,
    required tz.TZDateTime scheduledAt,
    required String title,
    required String body,
  }) async {
    if (failScheduleId == id) throw StateError('injected schedule failure');
    scheduledNotifications.add((
      id: id,
      scheduledAt: scheduledAt,
      title: title,
      body: body,
    ));
  }

  @override
  Future<void> cancel(int id) async {
    cancelCalls++;
    cancelledIds.add(id);
    scheduledNotifications.removeWhere((notification) => notification.id == id);
  }
}
