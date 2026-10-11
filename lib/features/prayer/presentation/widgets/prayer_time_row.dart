import 'package:flutter/material.dart';

import 'package:muslim_guide/app/theme/app_spacing.dart';
import 'package:muslim_guide/l10n/app_localizations.dart';

/// Formats [time] as a 24-hour `HH:mm` string with Latin digits (DEC-0026).
String _formatTime(DateTime time) {
  final hour = time.hour.toString().padLeft(2, '0');
  final minute = time.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}

/// A single prayer-time row: label, formatted time, and an optional note.
///
/// Highlights the next upcoming prayer ([isNext]) and renders the
/// localized "unavailable" text when [time] is `null` (polar edge cases).
///
/// When [notificationEnabled] and [onNotificationToggle] are both provided
/// (Task 7), a notification [Switch] is shown after the time. The row
/// itself is never tappable (director decision 2.1: switch only, to avoid
/// accidental taps while scrolling).
class PrayerTimeRow extends StatelessWidget {
  /// Creates a prayer-time row for [label] shown at [time].
  const new({
    required this.label,
    required this.time,
    this.isNext = false,
    this.note,
    this.inlineNote,
    this.notificationEnabled,
    this.onNotificationToggle,
    this.notificationToggleSemantics,
    super.key,
  });

  /// The localized prayer name (for example `prayer_fajr`).
  final String label;

  /// The prayer time, or `null` when it is astronomically unavailable.
  final DateTime? time;

  /// Whether this row is the next upcoming prayer (highlighted).
  final bool isNext;

  /// Optional secondary note shown under the label, such as
  /// `sunrise_not_prayer`.
  final String? note;

  /// Optional small inline note shown beside the label (Commit A: sunrise
  /// "not an obligatory prayer" marker, same row height as normal rows).
  final String? inlineNote;

  /// Whether notifications are enabled for this prayer (Task 7).
  ///
  /// The switch is shown only when this and [onNotificationToggle] are
  /// both non-null (the sunrise row omits them).
  final bool? notificationEnabled;

  /// Called with the new value when the notification switch changes.
  final ValueChanged<bool>? onNotificationToggle;

  /// Semantics label describing the switch state (localized).
  final String? notificationToggleSemantics;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final noteText = note;
    final effectiveTime = time;

    final timeText = effectiveTime == null
        ? localizations.prayer_time_unavailable
        : _formatTime(effectiveTime);

    // Task 7: the switch is shown only when both toggle params are set
    // (the sunrise row omits them). The row itself is never tappable
    // (director decision 2.1: switch only, to avoid accidental taps).
    final toggleEnabled = notificationEnabled;
    final onToggle = onNotificationToggle;
    final showToggle = toggleEnabled != null && onToggle != null;
    final isToggleOn = toggleEnabled ?? true;

    final toggleStateText = notificationToggleSemantics != null
        ? ' ${notificationToggleSemantics!}'
        : '';
    final semanticsText = noteText == null
        ? '$label: $timeText$toggleStateText'
        : '$label: $timeText. $noteText$toggleStateText';

    final timeColor = effectiveTime == null
        ? colorScheme.onSurfaceVariant
        : isNext
        ? colorScheme.primary
        : colorScheme.onSurface;

    // Task 7 visual (director 3.5): a disabled notification dims only the
    // label; the time keeps its normal color so "notification off" can
    // never be confused with "time unavailable".
    final labelColor = showToggle && !isToggleOn
        ? colorScheme.onSurfaceVariant
        : isNext
        ? colorScheme.primary
        : colorScheme.onSurface;

    return Semantics(
      label: semanticsText,
      excludeSemantics: true,
      child: Container(
        constraints: const BoxConstraints(minHeight: 48),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.m,
          vertical: AppSpacing.s,
        ),
        decoration: isNext
            ? BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(AppSpacing.s),
              )
            : null,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          label,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: isNext
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: labelColor,
                          ),
                        ),
                      ),
                      if (inlineNote != null) ...[
                        const SizedBox(width: AppSpacing.xs),
                        Flexible(
                          child: Text(
                            inlineNote!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (noteText != null)
                    Text(
                      noteText,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.m),
            Text(
              timeText,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: isNext ? FontWeight.w700 : FontWeight.w600,
                color: timeColor,
              ),
            ),
            if (showToggle) ...[
              const SizedBox(width: AppSpacing.s),
              Switch(value: isToggleOn, onChanged: onToggle),
            ],
          ],
        ),
      ),
    );
  }
}
