import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../../core/network/api_client.dart';
import '../../core/storage/key_value_store.dart';
import '../../core/time/clock.dart';
import 'content_models.dart';

enum ContentPhase { idle, loading, loaded, failed }

@immutable
class ContentState {
  const ContentState({
    this.phase = ContentPhase.idle,
    this.content,
    this.isCached = false,
  });
  final ContentPhase phase;
  final WebsiteContent? content;
  final bool isCached;
}

class ContentRepository extends ChangeNotifier {
  ContentRepository({
    required this.api,
    required this.storage,
    this.clock = const SystemClock(),
  });
  static const cacheKey = 'mv.zamzam.website-content-cache';
  static const freshness = Duration(minutes: 30);
  final ApiClient api;
  final KeyValueStore storage;
  final Clock clock;
  ContentState _state = const ContentState();
  ContentState get state => _state;
  Future<void>? _inFlight;
  bool _disposed = false;
  ({WebsiteContent content, DateTime date})? _readCache() {
    try {
      final raw = storage.read(cacheKey);
      if (raw == null) return null;
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return (
        content: WebsiteContent.fromJson(
          json['content'] as Map<String, dynamic>,
          api.baseUrl,
        ),
        date: DateTime.parse(json['fetchedAt'] as String),
      );
    } catch (_) {
      return null;
    }
  }

  void _emit(ContentState value) {
    if (_disposed) return;
    _state = value;
    notifyListeners();
  }

  Future<void> load({bool forceRefresh = false}) {
    if (_disposed) return Future.value();
    return _inFlight ??= _load(
      forceRefresh,
    ).whenComplete(() => _inFlight = null);
  }

  Future<void> _load(bool force) async {
    final cache = _readCache();
    final age = cache == null ? null : clock.now().difference(cache.date);
    if (!force && cache != null && !age!.isNegative && age < freshness) {
      _emit(
        ContentState(
          phase: ContentPhase.loaded,
          content: cache.content,
          isCached: true,
        ),
      );
      return;
    }
    final previous = _state.content ?? cache?.content;
    _emit(
      ContentState(
        phase: ContentPhase.loading,
        content: previous,
        isCached: previous != null,
      ),
    );
    try {
      final json = await api.json('GET', '/api/website-content');
      final content = WebsiteContent.fromJson(json, api.baseUrl);
      try {
        await storage.write(
          cacheKey,
          jsonEncode({
            'content': content.toJson(),
            'fetchedAt': clock.now().toUtc().toIso8601String(),
          }),
        );
      } catch (_) {
        /* A failed public cache write does not hide live content. */
      }
      _emit(ContentState(phase: ContentPhase.loaded, content: content));
    } catch (_) {
      _emit(
        ContentState(
          phase: previous == null ? ContentPhase.failed : ContentPhase.loaded,
          content: previous,
          isCached: previous != null,
        ),
      );
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
