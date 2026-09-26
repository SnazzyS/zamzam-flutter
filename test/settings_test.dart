import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:zamzam_flutter/core/storage/key_value_store.dart';
import 'package:zamzam_flutter/features/settings/settings_controller.dart';

class ControlledStore extends MemoryStore {
  final writes = <Completer<void>>[];
  bool fail = false;
  @override
  Future<void> write(String key, String value) async {
    if (fail) {
      throw StateError('disk unavailable');
    }
    final gate = Completer<void>();
    writes.add(gate);
    await gate.future;
    await super.write(key, value);
  }
}

void main() {
  test('missing and invalid scales fall back to medium', () {
    expect(SettingsController(MemoryStore()).scale, FontScale.medium);
    expect(
      SettingsController(MemoryStore({'fontScale': 'invalid'})).scale,
      FontScale.medium,
    );
  });
  test(
    'every scale persists and restores with the native multiplier',
    () async {
      final store = MemoryStore();
      final settings = SettingsController(store);
      for (final entry in {
        FontScale.small: .92,
        FontScale.medium: 1.0,
        FontScale.large: 1.12,
      }.entries) {
        await settings.setScale(entry.key);
        expect(SettingsController(store).scale.multiplier, entry.value);
      }
    },
  );
  test(
    'rapid changes persist in order while latest selection is immediately visible',
    () async {
      final store = ControlledStore();
      final settings = SettingsController(store);
      final first = settings.setScale(FontScale.small);
      final last = settings.setScale(FontScale.large);
      expect(settings.scale, FontScale.large);
      await Future<void>.delayed(Duration.zero);
      expect(store.writes.length, 1);
      store.writes.first.complete();
      await first;
      await Future<void>.delayed(Duration.zero);
      expect(store.writes.length, 2);
      store.writes.last.complete();
      await last;
      expect(SettingsController(store).scale, FontScale.large);
    },
  );
  test('failed writes restore the saved choice and expose an error', () async {
    final store = ControlledStore()..fail = true;
    final settings = SettingsController(store);
    await settings.setScale(FontScale.large);
    expect(settings.scale, FontScale.medium);
    expect(settings.error, isNotNull);
  });
}
