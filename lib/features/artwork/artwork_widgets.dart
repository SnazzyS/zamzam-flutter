import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import '../../core/theme.dart';
import '../../core/ui/components.dart';

/// Full content-area artwork extends behind the status bar; the persistent
/// bottom navigation still owns its own safe-area region, as in Swift.
class ArtworkFrame extends StatelessWidget {
  const ArtworkFrame({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => Stack(
    fit: StackFit.expand,
    children: [
      child,
      const PositionedDirectional(
        top: 12,
        start: 24,
        child: SafeArea(bottom: false, child: FloatingBackButton()),
      ),
    ],
  );
}

class ArtworkImage extends StatelessWidget {
  const ArtworkImage(this.name, {super.key, required this.aspectRatio});
  final String name;
  final double aspectRatio;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final decodeWidth =
          (math.max(constraints.maxWidth, constraints.maxHeight * aspectRatio) *
                  MediaQuery.devicePixelRatioOf(context))
              .ceil();
      return ClipRect(
        child: Image.asset(
          AppTheme.image(name),
          width: constraints.maxWidth,
          height: constraints.maxHeight,
          fit: BoxFit.cover,
          cacheWidth: decodeWidth,
          excludeFromSemantics: true,
        ),
      );
    },
  );
}
