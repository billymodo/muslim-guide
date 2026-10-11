import 'package:audio_service/audio_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:muslim_guide/features/adhan/data/audio_service_adhan_handler.dart';
import 'package:muslim_guide/features/adhan/domain/adhan_state.dart';

/// Task 10: adhan player play/stop on a real device.
///
/// Extends the existing audio-service init coverage with a full
/// play → playing → stop → idle cycle using the bundled placeholder.
/// The 8-second placeholder keeps this fast on device.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('adhan plays and stops', (tester) async {
    final handler = await AudioService.init<AudioServiceAdhanHandler>(
      builder: AudioServiceAdhanHandler.new,
      config: const AudioServiceConfig(
        androidNotificationChannelId: 'muslim_guide_audio_test',
        androidNotificationChannelName: 'Prayer audio test',
      ),
    );
    await handler.init();
    expect(await handler.stateStream.first, AdhanPlayerState.idle);

    await handler.play();
    expect(
      await handler.stateStream.firstWhere(
        (state) =>
            state == AdhanPlayerState.playing ||
            state == AdhanPlayerState.error,
      ),
      AdhanPlayerState.playing,
    );

    await handler.stop();
    expect(await handler.stateStream.first, AdhanPlayerState.idle);

    await handler.dispose();
  });
}
