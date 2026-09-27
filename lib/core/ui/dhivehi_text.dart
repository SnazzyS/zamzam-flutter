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
    this.widthBasis = TextWidthBasis.parent,
    this.lineSpacing = 0,
  });
  final String text;
  final double size;
  final FontWeight weight;
  final Color color;
  final TextAlign align;
  final int? maxLines;
  final double minScale;
  final bool fixedSize;
  final TextWidthBasis widthBasis;
  final double lineSpacing;
  @override
  Widget build(BuildContext context) {
    final fontSize = size * (fixedSize ? 1 : FontScaleScope.of(context));
    Widget render(double value, {double? height}) => Text(
      text,
      textDirection: TextDirection.rtl,
      textAlign: align,
      maxLines: maxLines,
      textWidthBasis: widthBasis,
      overflow: maxLines == null ? TextOverflow.clip : TextOverflow.ellipsis,
      style: AppTheme.dhivehi(
        value,
        weight: weight,
        color: color,
      ).copyWith(height: height),
    );
    if ((minScale >= 1 || maxLines == null) && lineSpacing == 0) {
      return render(fontSize);
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        if (!constraints.hasBoundedWidth) return render(fontSize);
        var fitted = fontSize;
        final painter = TextPainter(
          textDirection: TextDirection.rtl,
          maxLines: maxLines,
          textWidthBasis: widthBasis,
          ellipsis: maxLines == null ? null : '…',
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
        final lines = painter.computeLineMetrics();
        if (lineSpacing == 0 || lines.length <= 1) {
          painter.dispose();
          return render(fitted);
        }
        // Swift lineSpacing adds between lines, leaving the first baseline and
        // the final descent unchanged. Measure the leading to remove at edges.
        final firstBaseline = lines.first.baseline;
        final width = painter.width;
        final heightFactor =
            1.465 +
            lineSpacing / MediaQuery.textScalerOf(context).scale(fitted);
        painter.text = TextSpan(
          text: text,
          style: AppTheme.dhivehi(
            fitted,
            weight: weight,
            color: color,
          ).copyWith(height: heightFactor),
        );
        painter.layout(maxWidth: constraints.maxWidth);
        final paintHeight = painter.height;
        final firstLeading =
            painter.computeLineMetrics().first.baseline - firstBaseline;
        painter.dispose();
        return SizedBox(
          width: width,
          height: paintHeight - lineSpacing,
          child: OverflowBox(
            alignment: Alignment.topLeft,
            minWidth: width,
            maxWidth: width,
            minHeight: paintHeight,
            maxHeight: paintHeight,
            child: Transform.translate(
              offset: Offset(0, -firstLeading),
              child: render(fitted, height: heightFactor),
            ),
          ),
        );
      },
    );
  }
}
