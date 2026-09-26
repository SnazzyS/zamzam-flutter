import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zamzam_flutter/main.dart';
import 'package:zamzam_flutter/app/glass_tab_bar.dart';

void main() {
  testWidgets(
    'all five RTL tab controls select and expose accessibility state',
    (tester) async {
      final semantics = tester.ensureSemantics();
      await tester.pumpWidget(const ZamzamApp());
      for (final tab in RootTab.values) {
        await tester.tap(find.byKey(ValueKey('tab-${tab.name}')));
        await tester.pumpAndSettle();
        expect(
          tester.widget<GlassTabBar>(find.byType(GlassTabBar)).selectedIndex,
          tab.index,
        );
      }
      final home = tester.getCenter(find.byKey(const ValueKey('tab-home')));
      final settings = tester.getCenter(
        find.byKey(const ValueKey('tab-settings')),
      );
      expect(home.dx, greaterThan(settings.dx));
      semantics.dispose();
    },
  );
}
