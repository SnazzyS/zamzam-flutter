import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:zamzam_flutter/main.dart';
import 'package:zamzam_flutter/core/network/api_client.dart';
import 'package:zamzam_flutter/core/storage/key_value_store.dart';
import 'package:zamzam_flutter/core/strings.dart';
import 'package:zamzam_flutter/features/content/content_repository.dart';

void main() {
  testWidgets(
    'Trips and Services reuse one payload and refreshed service counts reset the pager',
    (tester) async {
      var calls = 0;
      var services = [
        {'title': 'First service', 'desc': 'First'},
        {'title': 'Second service', 'desc': 'Second'},
      ];
      final repo = ContentRepository(
        api: ApiClient(
          MockClient((_) async {
            calls++;
            return http.Response(
              jsonEncode({
                'packages': [
                  {'title': 'Trip', 'price': '29,500'},
                ],
                'services': services,
              }),
              200,
            );
          }),
        ),
        storage: MemoryStore(),
      );
      await tester.pumpWidget(ZamzamApp(content: repo));
      await tester.tap(find.byKey(const ValueKey('home-trips')));
      await tester.pumpAndSettle();
      expect(calls, 1);
      expect(find.text('Trip'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('back')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('home-services')));
      await tester.pumpAndSettle();
      expect(calls, 1);
      expect(find.text('First service'), findsOneWidget);
      await tester.ensureVisible(find.byKey(const ValueKey('service-dot-1')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('service-dot-1')));
      await tester.pumpAndSettle();
      expect(find.text('Second service'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('back')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('home-services')));
      await tester.pumpAndSettle();
      expect(find.text('First service'), findsOneWidget);

      services = [
        {'title': 'Replacement service', 'desc': 'Changed'},
      ];
      await repo.load(forceRefresh: true);
      await tester.pumpAndSettle();
      expect(find.text('Replacement service'), findsOneWidget);
      expect(find.byKey(const ValueKey('service-dot-1')), findsNothing);
      services = [];
      await repo.load(forceRefresh: true);
      await tester.pumpAndSettle();
      expect(find.text(Dv.servicesEmptyTitle), findsOneWidget);
      expect(find.text(Dv.tripsEmptyTitle), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );
}
