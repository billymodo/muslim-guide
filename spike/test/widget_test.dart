import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_guide_spike/main.dart';
import 'package:muslim_guide_spike/widgets/log_viewer.dart';

/// اختبارات الواجهة — UI فقط (Option A): بلا audio داخل FakeAsync.
void main() {
  testWidgets('الواجهة تعرض ثلاثة أزرار + سجلًا', (tester) async {
    await tester.pumpWidget(const SpikeApp(handler: null));

    expect(find.text('جدولة إشعار بعد 30 ثانية'), findsOneWidget);
    expect(find.text('تشغيل صوت 10 ثوانٍ'), findsOneWidget);
    expect(find.text('اختبار Hive من isolate'), findsOneWidget);
    expect(find.byType(LogViewer), findsOneWidget);

    final audioButton = tester.widget<ElevatedButton>(
      find.widgetWithText(ElevatedButton, 'تشغيل صوت 10 ثوانٍ'),
    );
    expect(audioButton.onPressed, isNull, reason: 'الزر معطّل بلا handler');

    final notifyButton = tester.widget<ElevatedButton>(
      find.widgetWithText(ElevatedButton, 'جدولة إشعار بعد 30 ثانية'),
    );
    expect(notifyButton.onPressed, isNotNull);

    final hiveButton = tester.widget<ElevatedButton>(
      find.widgetWithText(ElevatedButton, 'اختبار Hive من isolate'),
    );
    expect(hiveButton.onPressed, isNotNull);
  });
}
