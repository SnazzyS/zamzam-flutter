import 'dart:ui' as ui;
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zamzam_flutter/features/content/content_models.dart';
import 'package:zamzam_flutter/features/content/service_pager.dart';

void main() {
  const services = [
    ServiceItem(title: 'One', description: 'First'),
    ServiceItem(title: 'Two', description: 'Second'),
    ServiceItem(title: 'Three', description: 'Third'),
  ];
  Widget app(List<ServiceItem> items, {bool reducedMotion = false}) =>
      CupertinoApp(
        home: MediaQuery(
          data: MediaQueryData(disableAnimations: reducedMotion),
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Center(
              child: SizedBox(width: 354, child: ServicePager(services: items)),
            ),
          ),
        ),
      );
  bool selected(WidgetTester tester, int index) => tester
      .widget<Semantics>(find.byKey(ValueKey('service-dot-state-$index')))
      .properties
      .selected!;
  testWidgets(
    'LTR swipes stop at boundaries; RTL dots select; accessibility actions wrap',
    (tester) async {
      final handle = tester.ensureSemantics();
      try {
        await tester.pumpWidget(app(services));
        await tester.pumpAndSettle();
        expect(selected(tester, 0), isTrue);
        expect(
          tester.getCenter(find.byKey(const ValueKey('service-dot-0'))).dx,
          greaterThan(
            tester.getCenter(find.byKey(const ValueKey('service-dot-2'))).dx,
          ),
        );
        await tester.drag(find.byType(PageView), const Offset(450, 0));
        await tester.pumpAndSettle();
        expect(selected(tester, 0), isTrue);
        await tester.drag(find.byType(PageView), const Offset(-450, 0));
        await tester.pumpAndSettle();
        expect(selected(tester, 1), isTrue);
        await tester.tap(find.byKey(const ValueKey('service-dot-2')));
        await tester.pumpAndSettle();
        await tester.drag(find.byType(PageView), const Offset(-450, 0));
        await tester.pumpAndSettle();
        expect(selected(tester, 2), isTrue);
        var node = tester.getSemantics(
          find.byKey(const ValueKey('services-pager-semantics')),
        );
        node.owner!.performAction(node.id, ui.SemanticsAction.increase);
        await tester.pumpAndSettle();
        expect(selected(tester, 0), isTrue);
        node = tester.getSemantics(
          find.byKey(const ValueKey('services-pager-semantics')),
        );
        node.owner!.performAction(node.id, ui.SemanticsAction.decrease);
        await tester.pumpAndSettle();
        expect(selected(tester, 2), isTrue);
      } finally {
        handle.dispose();
      }
    },
  );
  testWidgets(
    'count changes reset safely and reduced motion selects immediately',
    (tester) async {
      await tester.pumpWidget(app(services, reducedMotion: true));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('service-dot-2')));
      await tester.pump();
      expect(selected(tester, 2), isTrue);
      await tester.pumpWidget(
        app(services.take(2).toList(), reducedMotion: true),
      );
      await tester.pumpAndSettle();
      expect(selected(tester, 0), isTrue);
      expect(find.byKey(const ValueKey('service-dot-2')), findsNothing);
      await tester.pumpWidget(app(const []));
      await tester.pumpAndSettle();
      expect(find.byType(PageView), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );
}
