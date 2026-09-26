import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class _NativeSymbol {
  const _NativeSymbol(this.bytes, this.width, this.height);
  final Uint8List bytes;
  final double width;
  final double height;
}

/// Preserve SF Symbol intrinsic proportions: a 24pt font is not a 24pt square.
class AppSymbol extends StatelessWidget {
  const AppSymbol(
    this.name, {
    super.key,
    required this.fallback,
    this.size = 22,
    this.color = const Color(0xFF1F2937),
    this.bold = false,
  });
  final String name;
  final IconData fallback;
  final double size;
  final Color color;
  final bool bold;
  static const _channel = MethodChannel('mv.zamzam.flutter/platform');
  static final _images = <String, Future<_NativeSymbol?>>{};
  Future<_NativeSymbol?> _image() =>
      _images.putIfAbsent('$name:$bold', () async {
        try {
          final data = await _channel.invokeMapMethod<String, dynamic>(
            'symbol',
            {'name': name, 'bold': bold},
          );
          if (data == null) return null;
          return _NativeSymbol(
            data['bytes'] as Uint8List,
            (data['width'] as num).toDouble(),
            (data['height'] as num).toDouble(),
          );
        } on PlatformException {
          return null;
        } on MissingPluginException {
          return null;
        }
      });
  @override
  Widget build(BuildContext context) {
    final icon = Icon(fallback, size: size, color: color);
    if (defaultTargetPlatform != TargetPlatform.iOS) return icon;
    return FutureBuilder<_NativeSymbol?>(
      future: _image(),
      builder: (context, snapshot) {
        final symbol = snapshot.data;
        return symbol == null
            ? icon
            : Image.memory(
                symbol.bytes,
                width: symbol.width * size / 24,
                height: symbol.height * size / 24,
                color: color,
                colorBlendMode: BlendMode.srcIn,
                gaplessPlayback: true,
                excludeFromSemantics: true,
              );
      },
    );
  }
}
