import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_guide/app/providers/bootstrap_provider.dart';
import 'package:muslim_guide/data/settings/settings_repository.dart';
import 'package:muslim_guide/features/prayer/application/asr_method_provider.dart';
import 'package:muslim_guide/features/prayer/application/calculation_method_provider.dart';
import 'package:muslim_guide/features/prayer/application/high_latitude_rule_provider.dart';
import 'package:muslim_guide/features/prayer/application/location_provider.dart';
import 'package:muslim_guide/features/prayer/domain/models/asr_method.dart';
import 'package:muslim_guide/features/prayer/domain/models/calculation_method.dart';
import 'package:muslim_guide/features/prayer/domain/models/high_latitude_rule.dart';
import 'package:muslim_guide/features/settings/presentation/screens/calculation_settings_screen.dart';
import 'package:muslim_guide/l10n/app_localizations.dart';

import '../../prayer/presentation/presentation_test_utils.dart';

/// In-memory calculation-method notifier (no Hive).
class _MemoryCalculationMethodNotifier extends CalculationMethodNotifier {
  new(this.fixed);

  final CalculationMethod fixed;

  @override
  CalculationMethod build() => fixed;

  @override
  Future<void> setMethod(
    CalculationMethod method, {
    bool markExplicit = true,
  }) async {
    state = method;
  }
}

/// In-memory settings repository (no Hive; never explicit).
class _MemorySettingsRepository extends SettingsRepository {
  new() : super(null);

  @override
  Future<bool> isCalculationMethodExplicit() async => false;
}

/// In-memory Asr-method notifier (no Hive).
class _MemoryAsrMethodNotifier extends AsrMethodNotifier {
  new(this.fixed);

  final AsrMethod fixed;

  @override
  AsrMethod build() => fixed;

  @override
  Future<void> setMethod(AsrMethod method) async {
    state = method;
  }
}

/// In-memory high-latitude-rule notifier (no Hive).
class _MemoryHighLatitudeRuleNotifier extends HighLatitudeRuleNotifier {
  new(this.fixed);

  final HighLatitudeRule fixed;

  @override
  HighLatitudeRule build() => fixed;

  @override
  Future<void> setRule(HighLatitudeRule rule) async {
    state = rule;
  }
}

Widget _buildScreen({
  CalculationMethod method = CalculationMethod.mwl,
  LocationSelection? selection,
}) {
  return ProviderScope(
    overrides: [
      calculationMethodProvider.overrideWith(
        () => _MemoryCalculationMethodNotifier(method),
      ),
      asrMethodProvider.overrideWith(
        () => _MemoryAsrMethodNotifier(AsrMethod.standard),
      ),
      highLatitudeRuleProvider.overrideWith(
        () => _MemoryHighLatitudeRuleNotifier(
          HighLatitudeRule.middleOfNight,
        ),
      ),
      citiesOverride(),
      locationOverride(selection),
      settingsRepositoryProvider.overrideWithValue(
        _MemorySettingsRepository(),
      ),
    ],
    child: const _CalcTestApp(),
  );
}

/// Static test shell so the MaterialApp subtree can be const.
class _CalcTestApp extends StatelessWidget {
  /// Creates the shell.
  const new();

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      locale: Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: CalculationSettingsScreen(),
    );
  }
}


void main() {
  testWidgets('shows three dropdowns with current values', (tester) async {
    await tester.pumpWidget(_buildScreen());
    await tester.pumpAndSettle();

    expect(find.text('Calculation settings'), findsOneWidget);
    expect(find.text('Method'), findsOneWidget);
    expect(find.text('Asr school'), findsOneWidget);
    expect(find.text('High-latitude rule'), findsOneWidget);
    expect(find.text('Muslim World League'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('changing the method updates the provider', (tester) async {
    await tester.pumpWidget(_buildScreen());
    await tester.pumpAndSettle();

    await tester.tap(find.byType(DropdownButtonFormField<CalculationMethod>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Egyptian General Authority of Survey').last);
    await tester.pumpAndSettle();

    expect(find.text('Egyptian General Authority of Survey'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('suggestion hidden when method matches the country', (
    tester,
  ) async {
    await tester.pumpWidget(
      _buildScreen(
        method: CalculationMethod.egyptian,
        selection: const CitySelection('cairo'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('Suggested for your country'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('suggestion shown on mismatch and applies on tap', (
    tester,
  ) async {
    await tester.pumpWidget(
      _buildScreen(selection: const CitySelection('cairo')),
    );
    await tester.pumpAndSettle();

    expect(
      find.textContaining('Suggested for your country'),
      findsOneWidget,
    );
    expect(find.text('Apply'), findsOneWidget);

    await tester.tap(find.text('Apply'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });
}
