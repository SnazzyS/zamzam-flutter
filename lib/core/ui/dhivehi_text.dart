import 'package:flutter/cupertino.dart';
import '../theme.dart';

class FontScaleScope extends InheritedWidget {
  const FontScaleScope({super.key, required this.scale, required super.child});
  final double scale;
  static double of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<FontScaleScope>()?.scale ?? 1;
  @override
  bool updateShouldNotify(FontScaleScope oldWidget) => oldWidget.scale != scale;
}

class DvText extends StatelessWidget {
  const DvText(
    this.text, {
    super.key,
    this.size = 16,
    this.weight = FontWeight.w400,
    this.color = AppTheme.text,
    this.align = TextAlign.right,
    this.maxLines,
    this.minScale = 1,
    this.fixedSize = false,
  });
  final String text;
  final double size;
  final FontWeight weight;
  final Color color;
  final TextAlign align;
  final int? maxLines;
  final double minScale;
  final bool fixedSize;
  @override
  Widget build(BuildContext context) {
    final fontSize = size * (fixedSize ? 1 : FontScaleScope.of(context));
    Widget render(double value) => Text(
      text,
      textDirection: TextDirection.rtl,
      textAlign: align,
      maxLines: maxLines,
      overflow: maxLines == null ? TextOverflow.clip : TextOverflow.ellipsis,
      style: AppTheme.dhivehi(value, weight: weight, color: color),
    );
    if (minScale >= 1 || maxLines == null) return render(fontSize);
    return LayoutBuilder(
      builder: (context, constraints) {
        if (!constraints.hasBoundedWidth) return render(fontSize);
        var fitted = fontSize;
        final painter = TextPainter(
          textDirection: TextDirection.rtl,
          maxLines: maxLines,
          textScaler: MediaQuery.textScalerOf(context),
        );
        while (true) {
          painter.text = TextSpan(
            text: text,
            style: AppTheme.dhivehi(fitted, weight: weight, color: color),
          );
          painter.layout(maxWidth: constraints.maxWidth);
          if (!painter.didExceedMaxLines || fitted <= fontSize * minScale) {
            break;
          }
          fitted = (fitted - .5).clamp(fontSize * minScale, fontSize);
        }
        painter.dispose();
        return render(fitted);
      },
    );
  }
}
