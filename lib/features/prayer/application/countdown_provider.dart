import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muslim_guide/features/prayer/application/prayer_times_provider.dart';
import 'package:muslim_guide/features/prayer/domain/models/prayer_times_result.dart';

/// Emits the time remaining until the next prayer, once per second, while
/// the app is in the foreground.
///
/// The stream is empty when no location has been selected, while the times
/// are loading, or when all of today's prayers have passed. The ticker runs
/// only in the foreground (paused in background to save battery) and stops
/// itself once the countdown reaches [Duration.zero]. Each tick recomputes
/// the remainder from the wall clock, so ticks never drift.
final AutoDisposeStreamProvider<Duration> countdownProvider =
    StreamProvider.autoDispose<Duration>((ref) {
  final times = ref.watch(prayerTimesProvider).valueOrNull;
  if (times == null) {
    return const Stream<Duration>.empty();
  }
  final target = nextPrayerTime(times, DateTime.now());
  if (target == null) {
    return const Stream<Duration>.empty();
  }

  final controller = StreamController<Duration>();
  final binding = WidgetsBinding.instance;
  Timer? timer;

  void tick() {
    if (controller.isClosed) return;
    final now = DateTime.now();
    final remaining = target.isAfter(now)
        ? target.difference(now)
        : Duration.zero;
    controller.add(remaining);
    if (remaining == Duration.zero) {
      timer?.cancel();
      timer = null;
    }
  }

  void startTicker() {
    timer ??= Timer.periodic(const Duration(seconds: 1), (_) => tick());
  }

  void stopTicker() {
    timer?.cancel();
    timer = null;
  }

  tick();
  final observer = _CountdownLifecycleObserver(
    onResume: startTicker,
    onPause: stopTicker,
  );
  binding.addObserver(observer);
  final lifecycleState = binding.lifecycleState;
  if (lifecycleState == null ||
      lifecycleState == AppLifecycleState.resumed ||
      lifecycleState == AppLifecycleState.inactive) {
    startTicker();
  }

  ref.onDispose(() {
    binding.removeObserver(observer);
    stopTicker();
    unawaited(controller.close());
  });
  return controller.stream;
});

/// Returns the earliest prayer time in [times] that is strictly after
/// [now], or `null` when every prayer for the day has passed.
///
/// Sunrise is intentionally excluded: the countdown targets the five
/// prayers, and sunrise is only a reference time.
@visibleForTesting
DateTime? nextPrayerTime(PrayerTimesResult times, DateTime now) {
  DateTime? target;
  final candidates = <DateTime?>[
    times.fajr,
    times.dhuhr,
    times.asr,
    times.maghrib,
    times.isha,
  ];
  for (final candidate in candidates) {
    if (candidate == null || !candidate.isAfter(now)) continue;
    if (target == null || candidate.isBefore(target)) {
      target = candidate;
    }
  }
  return target;
}

class _CountdownLifecycleObserver extends WidgetsBindingObserver {
  new({required this.onResume, required this.onPause});

  final VoidCallback onResume;
  final VoidCallback onPause;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      onResume();
    } else {
      onPause();
    }
  }
}
