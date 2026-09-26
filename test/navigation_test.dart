import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:zamzam_flutter/app/router.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zamzam_flutter/main.dart';
import 'package:zamzam_flutter/app/glass_tab_bar.dart';

void main() {
  testWidgets(
    'switching and reselecting tabs preserves a pushed Home destination',
    (tester) async {
      final router = createRouter(
        homeChildren: [
          GoRoute(
            path: 'probe',
            builder: (context, state) =>
                const Center(child: Text('Detail screen')),
          ),
        ],
      );
      addTearDown(router.dispose);
      await tester.pumpWidget(ZamzamApp(router: router));
      unawaited(router.push('/home/probe'));
      await tester.pumpAndSettle();
      expect(find.text('Detail screen'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('tab-settings')));
      await tester.pumpAndSettle();
      expect(find.text('Detail screen'), findsNothing);
      await tester.tap(find.byKey(const ValueKey('tab-home')));
      await tester.pumpAndSettle();
      expect(find.text('Detail screen'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('tab-home')));
      await tester.pumpAndSettle();
      expect(find.text('Detail screen'), findsOneWidget);
      router.pop();
      await tester.pumpAndSettle();
      expect(find.text('Detail screen'), findsNothing);
    },
  );
  testWidgets('Android Back returns a non-Home root to Home', (tester) async {
    await tester.pumpWidget(const ZamzamApp());
    await tester.tap(find.byKey(const ValueKey('tab-settings')));
    await tester.pumpAndSettle();
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(
      tester.widget<GlassTabBar>(find.byType(GlassTabBar)).selectedIndex,
      0,
    );
  });

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
