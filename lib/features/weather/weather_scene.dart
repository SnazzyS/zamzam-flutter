import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'weather_models.dart';

/// Geometry and colors transcribed from Swift's AnimatedWeatherCanvas.
class WeatherScenePainter extends CustomPainter {
  const WeatherScenePainter({required this.style, this.time = 0});
  final WeatherStyle style;
  final double time;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    Color color(int hex, [double opacity = 1]) =>
        Color(0xFF000000 | hex).withValues(alpha: opacity);
    void oval(Rect rect, Color c) => canvas.drawOval(rect, Paint()..color = c);
    void rect(Rect rect, Color c, [double radius = 0]) => canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(radius)),
      Paint()..color = c,
    );
    void line(Offset a, Offset b, Color c, double width) => canvas.drawLine(
      a,
      b,
      Paint()
        ..color = c
        ..strokeWidth = width,
    );
    final colors = style == WeatherStyle.rain
        ? [color(0x067B74), color(0x32B6A0), color(0x9BE7FF)]
        : [color(0x06B35D), color(0x37D88A), color(0xFFE08A)];
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ).createShader(Offset.zero & size),
    );
    final route = Path()
      ..moveTo(w * .12, h * .74)
      ..cubicTo(w * .28, h * .55, w * .48, h * .84, w * .68, h * .62);
    final dash = Paint()
      ..color = color(0xFFFFFF, .32)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    for (final metric in route.computeMetrics()) {
      for (double start = 0; start < metric.length; start += 14) {
        canvas.drawPath(
          metric.extractPath(start, math.min(start + 2, metric.length)),
          dash,
        );
      }
    }
    final progress = (time % 3.2) / 3.2;
    final marker = Offset(
      w * (.12 + .56 * progress),
      h * (.74 - .18 * math.sin(progress * math.pi)),
    );
    oval(Rect.fromCircle(center: marker, radius: 12), color(0xFFFFFF, .20));
    oval(Rect.fromCircle(center: marker, radius: 6), color(0xFFFFFF));

    void sun(Offset center, double radius) {
      final r = radius * (1 + math.sin(time * 1.35) * .035);
      oval(
        Rect.fromCircle(center: center, radius: r * 1.9),
        color(0xFFE66D, .22),
      );
      oval(Rect.fromCircle(center: center, radius: r), color(0xFFD94D, .96));
      for (var i = 0; i < 8; i++) {
        final angle = i / 8 * math.pi * 2 + time * .28;
        final direction = Offset(math.cos(angle), math.sin(angle));
        line(
          center + direction * r * 1.22,
          center + direction * r * 1.54,
          color(0xFFE66D, .48),
          3,
        );
      }
    }

    void cloud(Offset origin, double scale, double opacity) {
      final body = color(0xFFFFFF, opacity),
          shade = color(0xDFF7EC, opacity * .56);
      Rect box(double x, double y, double width, double height) =>
          Rect.fromLTWH(
            origin.dx + x * scale,
            origin.dy + y * scale,
            width * scale,
            height * scale,
          );
      rect(box(0, 30, 148, 42), shade, 22 * scale);
      oval(box(12, 16, 54, 54), body);
      oval(box(52, 0, 74, 74), body);
      oval(box(110, 20, 44, 44), body);
      rect(box(0, 38, 148, 26), body, 18 * scale);
    }

    switch (style) {
      case WeatherStyle.clear:
        sun(Offset(w * .18, h * .34), 32);
        cloud(Offset(w * .43 + math.sin(time * .8) * 7, h * .22), .74, .88);
      case WeatherStyle.cloudy:
        sun(Offset(w * .21, h * .29), 25);
        cloud(Offset(w * .12 + math.sin(time * .7) * 10, h * .36), 1.02, .94);
        cloud(Offset(w * .50 + math.cos(time * .62) * 8, h * .18), .72, .78);
      case WeatherStyle.rain:
        cloud(Offset(w * .12 + math.sin(time * .74) * 9, h * .29), 1.04, .94);
        cloud(Offset(w * .51 + math.cos(time * .6) * 9, h * .17), .78, .84);
      case WeatherStyle.staticFallback:
        cloud(Offset(w * .17, h * .30), .98, .82);
        cloud(Offset(w * .55, h * .18), .72, .70);
    }
    if (style == WeatherStyle.rain) {
      for (var i = 0; i < 28; i++) {
        final x = w * .12 + (i % 14) * w * .055 + math.sin(time + i) * 3;
        final y =
            (time * 86 + i * 19) % (h * .48) + h * (.26 + (i ~/ 14) * .04);
        line(Offset(x, y), Offset(x - 7, y + 20), color(0xFFFFFF, .58), 2.4);
      }
    }
    final ground = Path()
      ..moveTo(0, h * .76)
      ..cubicTo(w * .24, h * .67, w * .62, h * .82, w, h * .68)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(ground, Paint()..color = color(0x007C43, .28));
    final x = w * .68,
        y = h * .55 + math.sin(time * 1.25) * 2,
        bw = w * .17,
        bh = h * .18;
    rect(Rect.fromLTWH(x, y, bw, bh), color(0x112015, .96), 8);
    rect(
      Rect.fromLTWH(x + bw * .12, y - bh * .16, bw * .76, bh * .18),
      color(0x1E3D27, .92),
      5,
    );
    rect(Rect.fromLTWH(x, y + bh * .28, bw, bh * .16), color(0xF6C453, .95));
    rect(
      Rect.fromLTWH(x + bw * .61, y + bh * .46, bw * .18, bh * .42),
      color(0xE8B84B, .92),
    );
  }

  @override
  bool shouldRepaint(WeatherScenePainter oldDelegate) =>
      style != oldDelegate.style || time != oldDelegate.time;
}
