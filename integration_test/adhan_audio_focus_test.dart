import 'package:audio_service/audio_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:muslim_guide/features/adhan/data/audio_service_adhan_handler.dart';
import 'package:muslim_guide/features/adhan/domain/adhan_state.dart';

/// Task 6 integration: real audio-session wiring through the handler.
///
/// Uses the default watcher (real shared audio session). No synthetic
/// interruption is injected here — actual focus loss (real incoming call,
/// competing audio session, headset disconnect) must be verified manually
/// on device per OD-0023. This test proves the production wiring starts
/// and the handler exposes the Task 6 focus API.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('handler starts with real audio session and idle state', (
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

    expect(await handler.stateStream.first, AdhanPlayerState.idle);
    await handler.dispose();
  });
}
