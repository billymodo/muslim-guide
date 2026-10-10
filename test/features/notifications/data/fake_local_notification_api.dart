import 'package:muslim_guide/features/notifications/data/local_notification_api.dart';
import 'package:timezone/timezone.dart' as tz;

class FakeLocalNotificationApi implements LocalNotificationApi {
  bool? initializeResult = true;
  int initializeCalls = 0;
  int createChannelCalls = 0;
  int cancelCalls = 0;
  int? failScheduleId;
  final List<int> cancelledIds = [];
  String? createdChannelName;
  String? createdChannelDescription;
  final List<
    ({
      int id,
      tz.TZDateTime scheduledAt,
      String title,
      String body,
      String channelId,
    })
  >
  scheduledNotifications = [];

  @override
  Future<bool?> initialize() async {
    initializeCalls++;
    return initializeResult;
  }

  @override
  Future<void> createPrayerAdhanChannel({
    required String name,
    required String description,
  }) async {
    createChannelCalls++;
    createdChannelName = name;
    createdChannelDescription = description;
  }

  @override
  Future<void> zonedSchedule({
    required int id,
    required tz.TZDateTime scheduledAt,
    required String title,
    required String body,
    required String channelId,
  }) async {
    if (failScheduleId == id) throw StateError('injected schedule failure');
    if (channelId != prayerAdhanNotificationChannelId) {
      throw StateError('Unexpected prayer notification channel: $channelId');
    }
    scheduledNotifications.add((
      id: id,
      scheduledAt: scheduledAt,
      title: title,
      body: body,
      channelId: channelId,
    ));
  }

  @override
  Future<void> cancel(int id) async {
    cancelCalls++;
    cancelledIds.add(id);
    scheduledNotifications.removeWhere((notification) => notification.id == id);
  }
}
