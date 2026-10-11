import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muslim_guide/features/adhan/application/adhan_player_provider.dart';
import 'package:muslim_guide/features/adhan/domain/adhan_state.dart';
import 'package:muslim_guide/l10n/app_localizations.dart';

/// Basic in-app controls for playing and stopping the adhan audio.
class AdhanPlayerControls extends ConsumerWidget {
  /// Creates adhan player controls.
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = AppLocalizations.of(context)!;
    final playerState = ref.watch(adhanPlayerStateProvider);
    final currentState = playerState.when(
      data: (value) => value,
      error: (_, _) => AdhanPlayerState.error,
      loading: () => AdhanPlayerState.idle,
    );
    final service = ref.read(adhanPlayerServiceProvider);
    final isActive =
        currentState == AdhanPlayerState.playing ||
        currentState == AdhanPlayerState.loading;
    // M-4: restart is offered only after an interruption stop.
    final isInterrupted = currentState == AdhanPlayerState.interrupted;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(_stateLabel(localizations, currentState)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            FilledButton.icon(
              onPressed: isActive || isInterrupted
                  ? null
                  : () => unawaited(service.play()),
              icon: const Icon(Icons.play_arrow),
              label: Text(localizations.adhan_player_play),
            ),
            OutlinedButton.icon(
              onPressed: isActive ? () => unawaited(service.stop()) : null,
              icon: const Icon(Icons.stop),
              label: Text(localizations.adhan_player_stop),
            ),
            if (isInterrupted)
              FilledButton.tonalIcon(
                onPressed: () => unawaited(service.play()),
                icon: const Icon(Icons.refresh),
                label: Text(localizations.adhan_player_restart),
              ),
          ],
        ),
      ],
    );
  }

  String _stateLabel(AppLocalizations localizations, AdhanPlayerState state) {
    return switch (state) {
      AdhanPlayerState.idle => localizations.adhan_player_state_idle,
      AdhanPlayerState.loading => localizations.adhan_player_state_loading,
      AdhanPlayerState.playing => localizations.adhan_player_state_playing,
      AdhanPlayerState.paused => localizations.adhan_player_state_paused,
      AdhanPlayerState.completed => localizations.adhan_player_state_completed,
      AdhanPlayerState.error => localizations.adhan_player_state_error,
      AdhanPlayerState.interrupted =>
        localizations.adhan_player_state_interrupted,
    };
  }
}
