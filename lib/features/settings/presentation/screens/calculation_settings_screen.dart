import 'dart:async';

import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:muslim_guide/app/theme/app_spacing.dart';
import 'package:muslim_guide/features/prayer/application/asr_method_provider.dart';
import 'package:muslim_guide/features/prayer/application/calculation_method_provider.dart';
import 'package:muslim_guide/features/prayer/application/high_latitude_rule_provider.dart';
import 'package:muslim_guide/features/prayer/application/location_provider.dart';
import 'package:muslim_guide/features/prayer/data/country_method_mapping.dart';
import 'package:muslim_guide/features/prayer/domain/models/asr_method.dart';
import 'package:muslim_guide/features/prayer/domain/models/calculation_method.dart';
import 'package:muslim_guide/features/prayer/domain/models/city.dart';
import 'package:muslim_guide/features/prayer/domain/models/high_latitude_rule.dart';
import 'package:muslim_guide/features/settings/presentation/widgets/settings_section_header.dart';
import 'package:muslim_guide/l10n/app_localizations.dart';

/// Calculation settings screen (Phase 05-B).
///
/// Three dropdowns: calculation method, Asr school, high-latitude rule.
/// When the method is explicit and differs from the selected city's
/// country default, a suggestion row offers one-tap apply.
class CalculationSettingsScreen extends ConsumerWidget {
  /// Creates the calculation settings screen.
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = AppLocalizations.of(context)!;
    final method = ref.watch(calculationMethodProvider);
    final asrMethod = ref.watch(asrMethodProvider);
    final highLatRule = ref.watch(highLatitudeRuleProvider);

    return Scaffold(
      appBar: AppBar(title: Text(localizations.settings_calculation_title)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.s),
          children: [
            SettingsSectionHeader(
              title: localizations.settings_section_calculation,
            ),
            _MethodDropdown<CalculationMethod>(
              label: localizations.settings_calculation_method,
              value: method,
              items: CalculationMethod.values,
              itemLabel: (value) => methodName(localizations, value),
              onChanged: (value) => ref
                  .read(calculationMethodProvider.notifier)
                  .setMethod(value),
            ),
            _MethodDropdown<AsrMethod>(
              label: localizations.settings_asr_method,
              value: asrMethod,
              items: AsrMethod.values,
              itemLabel: (value) => switch (value) {
                AsrMethod.standard => localizations.asr_method_standard,
                AsrMethod.hanafi => localizations.asr_method_hanafi,
              },
              onChanged: (value) =>
                  ref.read(asrMethodProvider.notifier).setMethod(value),
            ),
            _MethodDropdown<HighLatitudeRule>(
              label: localizations.settings_high_latitude_rule,
              value: highLatRule,
              items: HighLatitudeRule.values,
              itemLabel: (value) => switch (value) {
                HighLatitudeRule.middleOfNight =>
                  localizations.hlr_middle_of_night,
                HighLatitudeRule.seventhOfNight =>
                  localizations.hlr_seventh_of_night,
                HighLatitudeRule.twilightAngle =>
                  localizations.hlr_twilight_angle,
                HighLatitudeRule.none => localizations.hlr_none,
              },
              onChanged: (value) => ref
                  .read(highLatitudeRuleProvider.notifier)
                  .setRule(value),
            ),
            _CountrySuggestion(
              currentMethod: method,
              onApply: (suggested) => ref
                  .read(calculationMethodProvider.notifier)
                  .setMethod(suggested),
            ),
            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }

  /// Localized display name for a calculation method.
  static String methodName(
    AppLocalizations localizations,
    CalculationMethod method,
  ) {
    return switch (method) {
      CalculationMethod.mwl => localizations.calc_method_mwl,
      CalculationMethod.egyptian => localizations.calc_method_egyptian,
      CalculationMethod.ummAlQura => localizations.calc_method_umm_al_qura,
      CalculationMethod.karachi => localizations.calc_method_karachi,
      CalculationMethod.isna => localizations.calc_method_isna,
      CalculationMethod.tehran => localizations.calc_method_tehran,
      CalculationMethod.jafari => localizations.calc_method_jafari,
    };
  }
}


/// Finds the selected city in the bundled list (null for GPS selections).
City? _findCity(List<City> cities, LocationSelection selection) {
  if (selection is! CitySelection) return null;
  for (final city in cities) {
    if (city.id == selection.cityId) return city;
  }
  return null;
}

/// Suggestion row shown only when the method is explicit AND differs from
/// the selected city's country default (Phase 05-B Q2: explicit users are
/// never auto-applied, they only see this quiet suggestion).
class _CountrySuggestion extends ConsumerWidget {
  /// Creates the suggestion row.
  const new({required this.currentMethod, required this.onApply});

  /// The currently active method.
  final CalculationMethod currentMethod;

  /// Applies the suggested method (explicit user action).
  final Future<void> Function(CalculationMethod suggested) onApply;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selection = ref.watch(locationProvider);
    return FutureBuilder<List<City>>(
      future: ref.watch(citiesLoaderProvider).load(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();
        final cities = snapshot.data!;
        final city = selection == null ? null : _findCity(cities, selection);
        final suggested = city == null
            ? null
            : countryMethodMapping[city.countryCode.toUpperCase()];
        if (suggested == null || suggested == currentMethod) {
          return const SizedBox.shrink();
        }
        final localizations = AppLocalizations.of(context)!;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                localizations.settings_calculation_suggestion(
                  CalculationSettingsScreen.methodName(
                    localizations,
                    suggested,
                  ),
                ),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: TextButton(
                  onPressed: () => unawaited(onApply(suggested)),
                  child: Text(localizations.settings_calculation_apply),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// One labeled dropdown row for a settings enum.
class _MethodDropdown<T> extends StatelessWidget {
  /// Creates the dropdown row.
  const new({
    required this.label,
    required this.value,
    required this.items,
    required this.itemLabel,
    required this.onChanged,
  });

  /// Row label.
  final String label;

  /// Current value.
  final T value;

  /// All selectable values.
  final List<T> items;

  /// Display name for a value.
  final String Function(T value) itemLabel;

  /// Called when the user picks a value.
  final Future<void> Function(T value) onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.m,
        vertical: AppSpacing.s,
      ),
      child: DropdownButtonFormField<T>(
        initialValue: value,
        isExpanded: true,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        items: items
            .map(
              (item) => DropdownMenuItem<T>(
                value: item,
                child: Text(
                  itemLabel(item),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            )
            .toList(),
        onChanged: (selected) {
          if (selected != null) unawaited(onChanged(selected));
        },
      ),
    );
  }
}
