import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_guide/shared/utils/time_format.dart';

void main() {
  test('formats single-digit hour and minute with padding', () {
    expect(formatTimeHm(DateTime(2026, 1, 1, 5, 7)), '05:07');
  });

  test('formats double-digit hour and minute unchanged', () {
    expect(formatTimeHm(DateTime(2026, 1, 1, 14, 31)), '14:31');
  });

  test('formats midnight and end of day', () {
    expect(formatTimeHm(DateTime(2026, 1, 2)), '00:00');
    expect(formatTimeHm(DateTime(2026, 1, 1, 23, 59)), '23:59');
  });

  test('drops seconds (floor for display, DEC-0026)', () {
    expect(formatTimeHm(DateTime(2026, 1, 1, 5, 15, 45)), '05:15');
  });
}
