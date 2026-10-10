import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muslim_guide/features/adhan/data/adhan_player_service.dart';
import 'package:muslim_guide/features/adhan/domain/adhan_state.dart';

/// Provides an injected in-app adhan player implementation.
final adhanPlayerServiceProvider = Provider<AdhanPlayerService>(
  (ref) => throw StateError('AdhanPlayerService was not initialized.'),
);

/// Exposes the player's state stream to UI consumers.
final adhanPlayerStateProvider = StreamProvider<AdhanPlayerState>(
  (ref) => ref.watch(adhanPlayerServiceProvider).stateStream,
);
