import 'package:shared_preferences/shared_preferences.dart';

abstract interface class KeyValueStore {
  String? read(String key);
  Future<void> write(String key, String value);
  Future<void> remove(String key);
}

class PreferencesStore implements KeyValueStore {
  PreferencesStore(this.preferences);
  final SharedPreferences preferences;
  @override
  String? read(String key) {
    final value = preferences.get(key);
    return value is String ? value : null;
  }

  @override
  Future<void> write(String key, String value) async {
    if (!await preferences.setString(key, value)) {
      throw StateError('Preference write failed');
    }
  }

  @override
  Future<void> remove(String key) async {
    if (!await preferences.remove(key)) {
      throw StateError('Preference removal failed');
    }
  }
}

/// Explicit in-memory implementation for widget previews and deterministic tests.
class MemoryStore implements KeyValueStore {
  MemoryStore([Map<String, String>? initial]) : values = {...?initial};
  final Map<String, String> values;
  @override
  String? read(String key) => values[key];
  @override
  Future<void> write(String key, String value) async {
    values[key] = value;
  }

  @override
  Future<void> remove(String key) async {
    values.remove(key);
  }
}
