import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class _NumberImage {
  const _NumberImage(this.bytes, this.width, this.height);
  final Uint8List bytes;
  final double width, height;
}

/// Use the system's rounded font and Arabic numeral fallback on iOS. Apple
/// fonts are never bundled; Android retains its installed system typefaces.
class RoundedNumber extends StatelessWidget {
  const RoundedNumber(
    this.text, {
    super.key,
    required this.size,
    required this.color,
  });
  final String text;
  final double size;
  final Color color;
  static const _channel = MethodChannel('mv.zamzam.flutter/platform');
  static final _cache = <String, Future<_NumberImage?>>{};

  Future<_NumberImage?> _image(double points) {
    final key = '$text:$points';
    final existing = _cache[key];
    if (existing != null) return existing;
    if (_cache.length >= 128) _cache.remove(_cache.keys.first);
    return _cache[key] = (() async {
      try {
        final result = await _channel.invokeMapMethod<String, dynamic>(
          'roundedNumber',
          {'text': text, 'size': points},
        );
        if (result == null) return null;
        return _NumberImage(
          result['bytes'] as Uint8List,
          (result['width'] as num).toDouble(),
          (result['height'] as num).toDouble(),
        );
      } on PlatformException {
        return null;
      } on MissingPluginException {
        return null;
      }
    })();
  }

  @override
  Widget build(BuildContext context) {
    final fallback = Text(
      text,
      maxLines: 1,
      style: TextStyle(
        fontFamily: '.AppleSystemUIFontRounded',
        fontSize: size,
        fontWeight: FontWeight.w700,
        color: color,
        letterSpacing: 0,
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
    );
    if (defaultTargetPlatform != TargetPlatform.iOS) return fallback;
    return Semantics(
      label: text,
      child: ExcludeSemantics(
        child: FutureBuilder<_NumberImage?>(
          future: _image(MediaQuery.textScalerOf(context).scale(size)),
          builder: (context, snapshot) {
            final data = snapshot.data;
            return data == null
                ? fallback
                : Image.memory(
                    data.bytes,
                    width: data.width,
                    height: data.height,
                    color: color,
                    colorBlendMode: BlendMode.srcIn,
                    gaplessPlayback: true,
                    excludeFromSemantics: true,
                  );
          },
        ),
      ),
    );
  }
}
