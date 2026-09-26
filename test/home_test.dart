import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zamzam_flutter/main.dart';
import 'package:zamzam_flutter/features/home/home_view.dart';
import 'package:zamzam_flutter/app/glass_tab_bar.dart';

void main() {
  testWidgets(
    'every Home destination opens and returns with the navbar retained',
    (tester) async {
      await tester.pumpWidget(const ZamzamApp());
      for (final module in HomeModule.values) {
        final tile = find.byKey(ValueKey('home-${module.name}'));
        await tester.ensureVisible(tile);
        await tester.tap(tile);
        await tester.pumpAndSettle();
        expect(find.byType(GlassTabBar), findsOneWidget);
        expect(find.byKey(const ValueKey('back')), findsOneWidget);
        await tester.tap(find.byKey(const ValueKey('back')));
        await tester.pumpAndSettle();
        expect(find.byType(HomeView), findsOneWidget);
      }
    },
  );
}
