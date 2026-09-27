import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zamzam_flutter/main.dart';
import 'package:zamzam_flutter/app/router.dart';
import 'package:zamzam_flutter/features/artwork/checklist_view.dart';

void main() {
  testWidgets(
    'four artwork pages swipe LTR, announce their page and retain the bottom bar',
    (tester) async {
      final router = createRouter()..go('/home/checklist');
      await tester.pumpWidget(ZamzamApp(router: router));
      await tester.pumpAndSettle();
      String? page() => tester
          .widget<Semantics>(find.byKey(const ValueKey('checklist-page')))
          .properties
          .label;
      expect(page(), '1 / 4');
      final pager = find.byType(PageView);
      await tester.drag(pager, const Offset(700, 0));
      await tester.pumpAndSettle();
      expect(page(), '1 / 4');
      for (var i = 2; i <= 4; i++) {
        await tester.drag(pager, const Offset(-700, 0));
        await tester.pumpAndSettle();
        expect(page(), '$i / 4');
      }
      await tester.drag(pager, const Offset(-700, 0));
      await tester.pumpAndSettle();
      expect(page(), '4 / 4');
      expect(find.byKey(const ValueKey('tab-home')), findsOneWidget);
      expect(find.byType(ChecklistView), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('tab-settings')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('tab-home')));
      await tester.pumpAndSettle();
      expect(page(), '4 / 4');
      await tester.tap(find.byKey(const ValueKey('back')));
      await tester.pumpAndSettle();
      router.go('/home/checklist');
      await tester.pumpAndSettle();
      expect(page(), '1 / 4');
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'landscape artwork and page indicator fit above persistent navigation',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(844, 390));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final router = createRouter()..go('/home/checklist');
      await tester.pumpWidget(ZamzamApp(router: router));
      await tester.pumpAndSettle();
      final dots = tester.getBottomLeft(
        find.byKey(const ValueKey('checklist-page')),
      );
      final nav = tester.getTopLeft(find.byKey(const ValueKey('tab-home')));
      expect(dots.dy, lessThan(nav.dy));
      expect(tester.takeException(), isNull);
    },
  );
}
