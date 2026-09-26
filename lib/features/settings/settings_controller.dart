import 'package:flutter/foundation.dart';
import '../../core/storage/key_value_store.dart';
import '../../core/strings.dart';

enum FontScale {
  small(.92, Dv.settingsSmall),
  medium(1, Dv.settingsMedium),
  large(1.12, Dv.settingsLarge);

  const FontScale(this.multiplier, this.title);
  final double multiplier;
  final String title;
}

class SettingsController extends ChangeNotifier {
  SettingsController(this.store) {
    final raw = store.read(key);
    _scale =
        FontScale.values.where((value) => value.name == raw).firstOrNull ??
        FontScale.medium;
    _saved = _scale;
  }
  static const key = 'fontScale';
  final KeyValueStore store;
  late FontScale _scale;
  late FontScale _saved;
  FontScale get scale => _scale;
  String? error;
  Future<void> _pending = Future.value();
  int _revision = 0;
  bool _disposed = false;

  Future<void> setScale(FontScale next) {
    if (next == _scale && error == null) {
      return Future.value();
    }
    final revision = ++_revision;
    _scale = next;
    error = null;
    notifyListeners();
    // Serialize writes so fast taps cannot persist an older selection last.
    return _pending = _pending.then((_) async {
      try {
        await store.write(key, next.name);
        _saved = next;
      } catch (_) {
        if (revision == _revision && !_disposed) {
          _scale = _saved;
          error = Dv.genericError;
          notifyListeners();
        }
      }
    });
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
