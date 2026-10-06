import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_guide_spike/services/notification_service.dart';

/// اختبارات خدمة الإشعارات — Phase 00B.
void main() {
  test('scheduleTime يحسب لحظة بعد N ثوانٍ من الآن', () {
    final service = NotificationService();
    final earliest = DateTime.now().add(const Duration(seconds: 29));
    final result = service.scheduleTime(30);
    final latest = DateTime.now().add(const Duration(seconds: 31));

    expect(
      result.millisecondsSinceEpoch,
      greaterThanOrEqualTo(earliest.millisecondsSinceEpoch),
    );
    expect(
      result.millisecondsSinceEpoch,
      lessThanOrEqualTo(latest.millisecondsSinceEpoch),
    );
  });
}
