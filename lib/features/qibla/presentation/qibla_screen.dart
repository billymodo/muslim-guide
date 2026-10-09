import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:muslim_guide/app/theme/app_spacing.dart';
import 'package:muslim_guide/features/qibla/application/qibla_providers.dart';
import 'package:muslim_guide/features/qibla/application/qibla_state.dart';
import 'package:muslim_guide/features/qibla/domain/qibla_direction.dart';
import 'package:muslim_guide/features/qibla/presentation/widgets/qibla_compass.dart';
import 'package:muslim_guide/l10n/app_localizations.dart';

/// Qibla screen: live compass when the sensor is available, numeric
/// fallback otherwise (REQ-QIBLA-001: direction + no-sensor fallback).
class QiblaScreen extends ConsumerWidget {
  /// Creates the Qibla screen.
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = AppLocalizations.of(context)!;
    final asyncState = ref.watch(qiblaStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.qibla_title),
        actions: [
          if (asyncState.valueOrNull?.sensorStatus !=
              SensorStatus.available)
            IconButton(
              icon: const Icon(Icons.edit_location_alt),
              tooltip: localizations.qibla_open_settings,
              onPressed: () => context.go('/location-picker'),
            ),
        ],
      ),
      body: SafeArea(
        child: asyncState.when(
          loading: () => Center(child: _loadingView(localizations)),
          error: (error, stack) => _errorView(localizations, ref),
          data: (state) => _buildState(context, ref, state, localizations),
        ),
      ),
    );
  }

  Widget _buildState(
    BuildContext context,
    WidgetRef ref,
    QiblaState state,
    AppLocalizations localizations,
  ) {
    if (state.sensorStatus == SensorStatus.initializing) {
      return _loadingView(localizations);
    }
    if (state.sensorStatus == SensorStatus.error) {
      return _errorView(localizations, ref);
    }
    if (state.locationSource == QiblaLocationSource.unavailable) {
      return _messageView(
        icon: Icons.location_off,
        message: localizations.qibla_no_location,
        actionLabel: localizations.qibla_open_settings,
        onAction: () => context.go('/location-picker'),
      );
    }
    if (state.sensorStatus == SensorStatus.unavailable) {
      final bearing = state.qiblaBearing;
      return _messageView(
        icon: Icons.explore_off,
        message: localizations.qibla_no_sensor,
        trailing: bearing == null
            ? null
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${bearing.toStringAsFixed(0)}°',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  Text(localizations.qibla_direction_label),
                ],
              ),
      );
    }

    // Success: sensor available and location known.
    final relative = state.relativeAngle;
    if (relative == null) {
      return _loadingView(localizations);
    }
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.m),
      child: Column(
        children: [
          Expanded(
            child: Center(
              child: QiblaCompass(
                relativeAngle: relative,
                deviceHeading: state.deviceHeading,
              ),
            ),
          ),
          Text(
            '${relative.toStringAsFixed(0)}°',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            localizations.qibla_calibrate,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _loadingView(AppLocalizations localizations) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: AppSpacing.m),
          Text(localizations.qibla_title),
        ],
      ),
    );
  }

  Widget _errorView(AppLocalizations localizations, WidgetRef ref) {
    return _messageView(
      icon: Icons.error_outline,
      message: localizations.qibla_error,
      actionLabel: localizations.qibla_retry,
      onAction: () => ref.invalidate(qiblaStateProvider),
    );
  }

  Widget _messageView({
    required IconData icon,
    required String message,
    String? actionLabel,
    VoidCallback? onAction,
    Widget? trailing,
  }) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.l),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64),
            const SizedBox(height: AppSpacing.m),
            Text(message, textAlign: TextAlign.center),
            if (trailing != null) ...[
              const SizedBox(height: AppSpacing.m),
              trailing,
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: AppSpacing.m),
              FilledButton(onPressed: onAction, child: Text(actionLabel)),
            ],
          ],
        ),
      ),
    );
  }
}
