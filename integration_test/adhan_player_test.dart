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
///
/// Hardening (GAP-integration-test-hang): every async step has a timeout
/// and `stop()` runs in `finally`, so a ColorOS hang can neither stall
/// the suite nor leave the foreground service alive (which previously
/// held the Hive lock and corrupted app state).
///
/// Race-free assertion (GAP-integration-player-race): subscribes to the
/// state stream BEFORE `play()` and asserts on the observed sequence
/// (`any non-idle` then back to `idle`) instead of waiting for a
/// specific `playing` event that a short asset or ColorOS stall could
/// deliver before the listener attaches.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'adhan plays and stops',
    (tester) async {
      final handler = await AudioService.init<AudioServiceAdhanHandler>(
        builder: AudioServiceAdhanHandler.new,
        config: const AudioServiceConfig(
          androidNotificationChannelId: 'muslim_guide_audio_test',
          androidNotificationChannelName: 'Prayer audio test',
        ),
      );
      await handler.init().timeout(const Duration(seconds: 15));

      // Subscribe BEFORE play (avoid race).
      final observedStates = <AdhanPlayerState>[];
      final subscription = handler.stateStream.listen(observedStates.add);

      try {
        // Pre-check: the handler must start idle.
        expect(
          await handler.stateStream.first.timeout(
            const Duration(seconds: 3),
          ),
          AdhanPlayerState.idle,
        );

        await handler.play().timeout(const Duration(seconds: 10));
        await tester.pump(const Duration(milliseconds: 500));

        // Any non-idle state (loading, playing, or even completed on a
        // short asset) proves playback started.
        expect(
          observedStates.any((state) => state != AdhanPlayerState.idle),
          isTrue,
          reason: 'Expected loading or playing state, got: $observedStates',
        );

        await handler.stop().timeout(const Duration(seconds: 5));
        await tester.pumpAndSettle(const Duration(seconds: 2));

        expect(
          observedStates.last,
          AdhanPlayerState.idle,
          reason:
              'Expected idle after stop, got: ${observedStates.last} '
              '(full sequence: $observedStates)',
        );
      } finally {
        await subscription.cancel();
        await handler.stop().timeout(const Duration(seconds: 5)).catchError((
          _,
        ) {
          // Best-effort cleanup: the service must not outlive the test.
        });
        await handler.dispose().catchError((_) {});
      }
    },
    timeout: const Timeout(Duration(seconds: 45)),
  );
}
