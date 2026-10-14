import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_guide/features/azkar/presentation/azkar_library_screen.dart';

import '../azkar_test_helpers.dart';

void main() {
  group('AzkarLibraryScreen', () {
    testWidgets('shows all five category titles', (tester) async {
      await tester.pumpWidget(
        buildAzkarTestApp(
          overrides: [azkarPackOverride(stubAzkarPack())],
          child: const AzkarLibraryScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('أذكار الصباح'), findsOneWidget);
      expect(find.text('أذكار المساء'), findsOneWidget);
      expect(find.text('أذكار النوم'), findsOneWidget);
      expect(find.text('أذكار الاستيقاظ'), findsOneWidget);
      expect(find.text('تسابيح'), findsOneWidget);
    });

    testWidgets('shows pending-pack Empty state when pack is null', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildAzkarTestApp(
          overrides: [azkarPackOverride(null)],
          child: const AzkarLibraryScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('مكتبة الأذكار قيد الإعداد'), findsOneWidget);
    });

    testWidgets('shows loading state before the first result', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildAzkarTestApp(child: const AzkarLibraryScreen()),
      );

      expect(find.text('جاري تحميل الأذكار'), findsOneWidget);
    });
  });
}
