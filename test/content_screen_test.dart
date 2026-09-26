import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:zamzam_flutter/main.dart';
import 'package:zamzam_flutter/app/router.dart';
import 'package:zamzam_flutter/core/network/api_client.dart';
import 'package:zamzam_flutter/core/storage/key_value_store.dart';
import 'package:zamzam_flutter/core/strings.dart';
import 'package:zamzam_flutter/features/content/content_repository.dart';
import 'package:zamzam_flutter/features/content/content_screen.dart';

void main() {
  testWidgets('Trips shows loading, then the native empty state', (
    tester,
  ) async {
    final pending = Completer<http.Response>();
    final repo = ContentRepository(
      api: ApiClient(MockClient((_) => pending.future)),
      storage: MemoryStore(),
    );
    final router = createRouter()..go('/home/trips');
    await tester.pumpWidget(ZamzamApp(router: router, content: repo));
    await tester.pump();
    expect(find.byType(ContentLoadingGrid), findsOneWidget);
    pending.complete(http.Response('{"packages":[],"services":[]}', 200));
    await tester.pumpAndSettle();
    expect(find.text(Dv.tripsEmptyTitle), findsOneWidget);
    expect(find.text(Dv.tripsEmptyBody), findsOneWidget);
    expect(find.byType(ContentLoadingGrid), findsNothing);
  });
  testWidgets(
    'Trips retry recovers and failed refresh keeps the visible card',
    (tester) async {
      var calls = 0;
      final pending = Completer<http.Response>();
      final repo = ContentRepository(
        api: ApiClient(
          MockClient((_) async {
            calls++;
            if (calls == 1) return http.Response('', 500);
            if (calls == 2) {
              return http.Response(
                jsonEncode({
                  'packages': [
                    {'title': 'test trip', 'price': '29,500'},
                  ],
                  'services': [],
                }),
                200,
              );
            }
            return pending.future;
          }),
        ),
        storage: MemoryStore(),
      );
      final router = createRouter()..go('/home/trips');
      await tester.pumpWidget(ZamzamApp(router: router, content: repo));
      await tester.pumpAndSettle();
      expect(find.text(Dv.tripsErrorTitle), findsOneWidget);
      await tester.tap(find.text(Dv.retry));
      await tester.pumpAndSettle();
      expect(find.text('test trip'), findsOneWidget);
      expect(find.text(Dv.imageUnavailable), findsOneWidget);
      final refresh = tester
          .widget<CupertinoSliverRefreshControl>(
            find.byType(CupertinoSliverRefreshControl, skipOffstage: false),
          )
          .onRefresh!();
      await tester.pump();
      expect(find.text('test trip'), findsOneWidget);
      expect(find.byType(ContentLoadingGrid), findsNothing);
      pending.complete(http.Response('', 503));
      await refresh;
      await tester.pumpAndSettle();
      expect(find.text('test trip'), findsOneWidget);
      expect(repo.state.isCached, isTrue);
      expect(tester.takeException(), isNull);
    },
  );
}
