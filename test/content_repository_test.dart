import 'dart:async';
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:zamzam_flutter/core/network/api_client.dart';
import 'package:zamzam_flutter/core/storage/key_value_store.dart';
import 'package:zamzam_flutter/core/time/clock.dart';
import 'package:zamzam_flutter/features/content/content_models.dart';
import 'package:zamzam_flutter/features/content/content_repository.dart';

class FakeClock implements Clock {
  FakeClock(this.value);
  DateTime value;
  @override
  DateTime now() => value;
}

const payload = {
  'packages': [
    {'id': '2', 'title': '  trip  ', 'price': 29500, 'image': '/image.jpg'},
    {'id': 3},
  ],
  'services': [
    {'title': 12.5, 'desc': ' service ', 'image': null},
    {'title': true},
  ],
};
http.Response response([int code = 200]) =>
    http.Response(jsonEncode(payload), code);

void main() {
  test(
    'flexible scalars, URL resolution, empty filtering and cache round trip',
    () {
      final base = Uri.parse('https://zamzam.mv');
      final content = WebsiteContent.fromJson(payload, base);
      expect(content.packages, hasLength(1));
      expect(content.packages.single.id, 2);
      expect(content.packages.single.title, 'trip');
      expect(content.packages.single.price, '29500');
      expect(
        content.packages.single.imageUrl.toString(),
        'https://zamzam.mv/image.jpg',
      );
      expect(content.services.single.title, '12.5');
      final encoded = jsonEncode(content.toJson());
      expect(
        jsonEncode(WebsiteContent.fromJson(jsonDecode(encoded), base).toJson()),
        encoded,
      );
      expect(contentUrl('javascript:alert(1)', base), isNull);
      expect(contentUrl('http://[bad', base), isNull);
      expect(() => content.packages.clear(), throwsUnsupportedError);
    },
  );
  test(
    'both screens share a single request and fresh cache; exact expiry reloads',
    () async {
      final pending = Completer<http.Response>();
      var calls = 0;
      final client = MockClient((request) {
        calls++;
        expect(request.method, 'GET');
        expect(request.url.path, '/api/website-content');
        expect(request.headers['Accept'], 'application/json');
        return calls == 1 ? pending.future : Future.value(response());
      });
      final clock = FakeClock(DateTime.utc(2026, 9, 27));
      final store = MemoryStore();
      final repo = ContentRepository(
        api: ApiClient(client),
        storage: store,
        clock: clock,
      );
      final a = repo.load();
      final b = repo.load();
      expect(identical(a, b), isTrue);
      await Future<void>.delayed(Duration.zero);
      expect(calls, 1);
      pending.complete(response());
      await Future.wait([a, b]);
      clock.value = clock.value.add(const Duration(minutes: 29, seconds: 59));
      await repo.load();
      expect(repo.state.isCached, isTrue);
      expect(calls, 1);
      clock.value = clock.value.add(const Duration(seconds: 1));
      await repo.load();
      expect(calls, 2);
      final restored = ContentRepository(
        api: ApiClient(client),
        storage: store,
        clock: clock,
      );
      await restored.load();
      expect(restored.state.content!.services.single.description, 'service');
      expect(calls, 2);
    },
  );
  test(
    'refresh retains visible data and failed refresh falls back to cache',
    () async {
      var calls = 0;
      final pending = Completer<http.Response>();
      final repo = ContentRepository(
        api: ApiClient(
          MockClient(
            (_) => ++calls == 1 ? Future.value(response()) : pending.future,
          ),
        ),
        storage: MemoryStore(),
      );
      await repo.load();
      final initial = repo.state.content;
      final refresh = repo.load(forceRefresh: true);
      expect(repo.state.phase, ContentPhase.loading);
      expect(repo.state.content, same(initial));
      pending.complete(response(500));
      await refresh;
      expect(repo.state.phase, ContentPhase.loaded);
      expect(repo.state.isCached, isTrue);
      expect(repo.state.content, same(initial));
    },
  );
  test(
    'missing or corrupt cache and malformed payload fail, then retry recovers',
    () async {
      for (final cache in [
        null,
        'bad json',
        '{"content":{},"fetchedAt":"no"}',
      ]) {
        var calls = 0;
        final store = MemoryStore({ContentRepository.cacheKey: ?cache});
        final repo = ContentRepository(
          api: ApiClient(
            MockClient(
              (_) async => ++calls == 1
                  ? http.Response('{"packages":{}}', 200)
                  : response(),
            ),
          ),
          storage: store,
        );
        await repo.load();
        expect(repo.state.phase, ContentPhase.failed);
        await repo.load();
        expect(repo.state.phase, ContentPhase.loaded);
      }
    },
  );
  test(
    'network failure without cache is recoverable and dispose ignores completion',
    () async {
      final pending = Completer<http.Response>();
      final repo = ContentRepository(
        api: ApiClient(MockClient((_) => pending.future)),
        storage: MemoryStore(),
      );
      final future = repo.load();
      await Future<void>.delayed(Duration.zero);
      repo.dispose();
      pending.completeError(http.ClientException('offline'));
      await future;
      expect(repo.state.phase, ContentPhase.loading);
    },
  );
  test(
    'offline without cache shows failure and cache write failure keeps live data',
    () async {
      final offline = ContentRepository(
        api: ApiClient(
          MockClient((_) async => throw http.ClientException('offline')),
        ),
        storage: MemoryStore(),
      );
      await offline.load();
      expect(offline.state.phase, ContentPhase.failed);
      final live = ContentRepository(
        api: ApiClient(MockClient((_) async => response())),
        storage: UnwritableStore(),
      );
      await live.load();
      expect(live.state.phase, ContentPhase.loaded);
      expect(live.state.isCached, isFalse);
    },
  );
  for (final entry in {
    401: ApiFailure.unauthorized,
    403: ApiFailure.forbidden,
    404: ApiFailure.notFound,
    422: ApiFailure.invalidCredentials,
    429: ApiFailure.rateLimited,
    500: ApiFailure.server,
  }.entries) {
    test('status ${entry.key} maps to a typed failure without retry', () async {
      var calls = 0;
      final api = ApiClient(
        MockClient((_) async {
          calls++;
          return response(entry.key);
        }),
      );
      await expectLater(
        api.json('GET', '/api/website-content'),
        throwsA(entry.value),
      );
      expect(calls, 1);
    });
  }
  test('timeout covers response body and never retries', () async {
    var calls = 0;
    final api = ApiClient(
      MockClient((_) {
        calls++;
        return Completer<http.Response>().future;
      }),
    );
    await expectLater(
      api.json('GET', '/x', timeout: const Duration(milliseconds: 1)),
      throwsA(ApiFailure.network),
    );
    expect(calls, 1);
  });
}

class UnwritableStore extends MemoryStore {
  @override
  Future<void> write(String key, String value) async =>
      throw StateError('unavailable');
}
