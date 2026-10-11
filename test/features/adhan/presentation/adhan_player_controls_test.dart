import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_guide/features/adhan/application/adhan_player_provider.dart';
import 'package:muslim_guide/features/adhan/presentation/adhan_player_controls.dart';
import 'package:muslim_guide/l10n/app_localizations.dart';

import '../fake_adhan_player_service.dart';

void main() {
  testWidgets('play and stop controls call the injected player', (
    tester,
  ) async {
    final player = FakeAdhanPlayerService();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [adhanPlayerServiceProvider.overrideWithValue(player)],
        child: const MaterialApp(
          locale: Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: AdhanPlayerControls()),
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.text('Play adhan'));
    await tester.pump();

    expect(player.playCalls, 1);
    expect(find.text('Playing'), findsOneWidget);
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
      isNull,
    );

    await tester.tap(find.text('Stop adhan'));
    await tester.pump();

    expect(player.stopCalls, 1);
    expect(find.text('Ready'), findsOneWidget);
  });

  testWidgets('restart button is hidden in normal states (M-4)', (
    tester,
  ) async {
    final player = FakeAdhanPlayerService();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [adhanPlayerServiceProvider.overrideWithValue(player)],
        child: const MaterialApp(
          locale: Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: AdhanPlayerControls()),
        ),
      ),
    );
    await tester.pump();

    // idle: no restart button.
    expect(find.text('Restart adhan'), findsNothing);

    await tester.tap(find.text('Play adhan'));
    await tester.pump();

    // playing: still no restart button.
    expect(find.text('Restart adhan'), findsNothing);
  });

  testWidgets('interrupted state shows restart only (M-4)', (
    tester,
  ) async {
    final player = FakeAdhanPlayerService();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [adhanPlayerServiceProvider.overrideWithValue(player)],
        child: const MaterialApp(
          locale: Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: AdhanPlayerControls()),
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.text('Play adhan'));
    await tester.pump();

    player.interrupt();
    await tester.pump();

    expect(find.text('Stopped by interruption'), findsOneWidget);
    expect(find.text('Restart adhan'), findsOneWidget);
    // Play stays disabled while interrupted; restart is the only path.
    final playButton =
        find.widgetWithText(FilledButton, 'Play adhan').evaluate().single;
    expect(
      (playButton.widget as FilledButton).onPressed,
      isNull,
    );
  });

  testWidgets('tapping restart calls play and returns to playing', (
    tester,
  ) async {
    final player = FakeAdhanPlayerService();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [adhanPlayerServiceProvider.overrideWithValue(player)],
        child: const MaterialApp(
          locale: Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: AdhanPlayerControls()),
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.text('Play adhan'));
    await tester.pump();
    player.interrupt();
    await tester.pump();
    expect(find.text('Restart adhan'), findsOneWidget);

    await tester.tap(find.text('Restart adhan'));
    await tester.pump();

    // One play from setup + one from restart.
    expect(player.playCalls, 2);
    expect(find.text('Playing'), findsOneWidget);
    expect(find.text('Restart adhan'), findsNothing);
  });
}
