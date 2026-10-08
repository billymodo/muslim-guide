import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_guide/features/prayer/application/countdown_provider.dart';
import 'package:muslim_guide/features/prayer/application/prayer_times_provider.dart';
import 'package:muslim_guide/features/prayer/domain/models/asr_method.dart';
import 'package:muslim_guide/features/prayer/domain/models/calculation_method.dart';
import 'package:muslim_guide/features/prayer/domain/models/high_latitude_rule.dart';
import 'package:muslim_guide/features/prayer/domain/models/location_data.dart';
import 'package:muslim_guide/features/prayer/domain/models/prayer_times_result.dart';

PrayerTimesResult _times({
  DateTime? sunrise,
  DateTime? fajr,
  DateTime? dhuhr,
  DateTime? asr,
  DateTime? maghrib,
  DateTime? isha,
}) {
  return PrayerTimesResult(
    fajr: fajr,
    sunrise: sunrise,
    dhuhr: dhuhr,
    asr: asr,
    maghrib: maghrib,
    isha: isha,
    polarState: PolarState.normal,
    location: const LocationData(
      latitude: 24.7136,
      longitude: 46.6753,
      timeZoneId: 'Asia/Riyadh',
    ),
    date: DateTime(2026, 10, 8),
    method: CalculationMethod.mwl,
    asrMethod: AsrMethod.standard,
    highLatRule: HighLatitudeRule.middleOfNight,
  );
}

class _FixedPrayerTimesNotifier extends PrayerTimesNotifier {
  new(this._result);

  final PrayerTimesResult? _result;

  @override
  Future<PrayerTimesResult?> build() async => _result;
}

void main() {
  ProviderContainer createContainer(PrayerTimesResult? result) {
    final container = ProviderContainer(
      overrides: [
        prayerTimesProvider
            .overrideWith(() => _FixedPrayerTimesNotifier(result)),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  ProviderSubscription<AsyncValue<Duration>> collectDurations(
    ProviderContainer container,
    List<AsyncValue<Duration>> events,
    List<Duration> durations,
  ) {
    final subscription = container.listen(
      countdownProvider,
      (_, next) {
        events.add(next);
        final remaining = next.valueOrNull;
        if (remaining != null) durations.add(remaining);
      },
      fireImmediately: true,
    );
    addTearDown(subscription.close);
    return subscription;
  }

  test('nextPrayerTime picks the earliest upcoming prayer', () {
    final times = _times(
      sunrise: DateTime(2026, 10, 8, 6),
      fajr: DateTime(2026, 10, 8, 5),
      dhuhr: DateTime(2026, 10, 8, 12),
      asr: DateTime(2026, 10, 8, 15),
      maghrib: DateTime(2026, 10, 8, 18),
      isha: DateTime(2026, 10, 8, 19, 30),
    );

    expect(
      nextPrayerTime(times, DateTime(2026, 10, 8, 4)),
      DateTime(2026, 10, 8, 5),
    );
    expect(
      nextPrayerTime(times, DateTime(2026, 10, 8, 10)),
      DateTime(2026, 10, 8, 12),
    );
    expect(
      nextPrayerTime(times, DateTime(2026, 10, 8, 5, 30)),
      DateTime(2026, 10, 8, 12),
    );
    expect(nextPrayerTime(times, DateTime(2026, 10, 8, 23)), isNull);
  });

  testWidgets('emits the remaining time once per second', (tester) async {
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    final target = DateTime.now().add(const Duration(seconds: 30));
    final container = createContainer(_times(dhuhr: target));
    final events = <AsyncValue<Duration>>[];
    final durations = <Duration>[];
    collectDurations(container, events, durations);

    await tester.pump(const Duration(milliseconds: 100));

    expect(durations, hasLength(1));
    expect(durations.first, lessThanOrEqualTo(const Duration(seconds: 30)));
    expect(durations.first, greaterThan(const Duration(seconds: 25)));

    await tester.pump(const Duration(seconds: 1));

    expect(durations, hasLength(2));
    expect(durations.last, lessThanOrEqualTo(durations.first));

    // Stop the ticker before the framework verifies that no timers remain.
    container.dispose();
  });

  testWidgets('stops ticking while the app is backgrounded', (tester) async {
    addTearDown(
      () => tester.binding
          .handleAppLifecycleStateChanged(AppLifecycleState.resumed),
    );
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    final target = DateTime.now().add(const Duration(minutes: 5));
    final container = createContainer(_times(dhuhr: target));
    final events = <AsyncValue<Duration>>[];
    final durations = <Duration>[];
    collectDurations(container, events, durations);

    await tester.pump(const Duration(milliseconds: 100));
    expect(durations, hasLength(1));

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pump(const Duration(seconds: 3));
    expect(durations, hasLength(1));

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump(const Duration(seconds: 1));
    expect(durations, hasLength(2));

    // Stop the ticker before the framework verifies that no timers remain.
    container.dispose();
  });

  testWidgets('is empty while prayer times are unavailable', (tester) async {
    final container = createContainer(null);
    final events = <AsyncValue<Duration>>[];
    final durations = <Duration>[];
    collectDurations(container, events, durations);

    await tester.pump(const Duration(seconds: 2));

    expect(events, isNotEmpty);
    expect(durations, isEmpty);
  });

  testWidgets("is empty once all of today's prayers have passed",
      (tester) async {
    final past = DateTime.now().subtract(const Duration(hours: 1));
    final container = createContainer(
      _times(
        fajr: past,
        dhuhr: past,
        asr: past,
        maghrib: past,
        isha: past,
      ),
    );
    final events = <AsyncValue<Duration>>[];
    final durations = <Duration>[];
    collectDurations(container, events, durations);

    await tester.pump(const Duration(seconds: 2));

    expect(events, isNotEmpty);
    expect(durations, isEmpty);
  });
}
