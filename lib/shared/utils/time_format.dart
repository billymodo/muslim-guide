/// Shared time formatting (Phase 05-A: GAP-format-time-dup).
///
/// Formats [time] as a 24-hour `HH:mm` string with Latin digits (DEC-0026).
/// Extracted from the private duplicates in `prayer_time_row.dart` and
/// `night_thirds_row.dart`.
String formatTimeHm(DateTime time) {
  final hour = time.hour.toString().padLeft(2, '0');
  final minute = time.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}
