import 'package:audio_service/audio_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:muslim_guide/features/adhan/data/audio_service_adhan_handler.dart';
import 'package:muslim_guide/features/adhan/domain/adhan_state.dart';
import 'package:muslim_guide/features/notifications/data/flutter_local_notification_api.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('initializes audio service and prayer notification channel', (
    tester,
  ) async {
    final handler = await AudioService.init<AudioServiceAdhanHandler>(
      builder: AudioServiceAdhanHandler.new,
      config: const AudioServiceConfig(
        androidNotificationChannelId: 'muslim_guide_audio_test',
        androidNotificationChannelName: 'Prayer audio test',
      ),
    );
    await handler.init();

    final notificationApi = FlutterLocalNotificationApi(
      FlutterLocalNotificationsPlugin(),
    );
    expect(await notificationApi.initialize(), isTrue);
    await notificationApi.createPrayerAdhanChannel(
      name: 'Prayer notifications test',
      description: 'Audible prayer notification test channel',
    );

    expect(await handler.stateStream.first, AdhanPlayerState.idle);
    await handler.dispose();
  });
}
