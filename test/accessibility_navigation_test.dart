import 'dart:ui' as ui;
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zamzam_flutter/main.dart';
import 'package:zamzam_flutter/core/strings.dart';

void main() {
  testWidgets(
    'screen reader actions can select tabs, open a tile, and go Back',
    (tester) async {
      final handle = tester.ensureSemantics();
      try {
        await tester.pumpWidget(const ZamzamApp());
        Future<void> activate(String label) async {
          final node = tester.getSemantics(find.bySemanticsLabel(label).first);
          expect(
            node.getSemanticsData().hasAction(ui.SemanticsAction.tap),
            isTrue,
          );
          node.owner!.performAction(node.id, ui.SemanticsAction.tap);
          await tester.pumpAndSettle();
        }

        await activate(Dv.settingsNav);
        expect(find.text(Dv.settingsGeneral), findsOneWidget);
        await activate(Dv.homeNav);
        await activate(Dv.umrahTitle);
        expect(find.byKey(const ValueKey('back')), findsOneWidget);
        await activate('Back');
        expect(find.text(Dv.appName), findsOneWidget);
      } finally {
        handle.dispose();
      }
    },
  );
}
