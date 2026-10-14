import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_guide/features/azkar/data/azkar_progress_storage.dart';
import 'package:muslim_guide/features/azkar/domain/azkar_category.dart';
import 'package:muslim_guide/features/azkar/presentation/azkar_detail_screen.dart';

import '../azkar_test_helpers.dart';

void main() {
  group('AzkarDetailScreen', () {
    testWidgets('shows placeholder items for the category', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildAzkarTestApp(
          overrides: [
            azkarPackOverride(stubAzkarPack()),
            azkarProgressOverride(MemoryAzkarProgressStorage()),
          ],
          child: const AzkarDetailScreen(
            categoryId: AzkarCategoryId.morning,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.text('[PLACEHOLDER-DHIKR-morning-01]'),
        findsOneWidget,
      );
      expect(
        find.text('[PLACEHOLDER-DHIKR-morning-02]'),
        findsOneWidget,
      );
      expect(
        find.text('[PLACEHOLDER-DHIKR-evening-01]'),
        findsNothing,
      );
    });

    testWidgets('completing one item updates the counter label', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildAzkarTestApp(
          overrides: [
            azkarPackOverride(stubAzkarPack()),
            azkarProgressOverride(MemoryAzkarProgressStorage()),
          ],
          child: const AzkarDetailScreen(
            categoryId: AzkarCategoryId.morning,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('0 / 2'), findsOneWidget);
      await tester.tap(find.text('تم'));
      await tester.pumpAndSettle();
      expect(find.text('1 / 2'), findsOneWidget);
    });
  });
}
