import 'package:flutter/cupertino.dart';

abstract final class AppTheme {
  static const background = Color(0xFFF4F2EF);
  static const surface = CupertinoColors.white;
  static const surfaceVariant = Color(0xFFEEF8F0);
  static const green = Color(0xFF00A443);
  static const greenLight = Color(0xFF08B63C);
  static const greenDark = Color(0xFF067A2D);
  static const text = Color(0xFF1F2937);
  static const secondary = Color(0xFF5F6D63);
  static const divider = Color(0xFFD7E6D8);
  static const error = Color(0xFFB3261E);
  static const success = Color(0xFF2E8B57);
  static const shadow = Color(0x14000000);
  static const theme = CupertinoThemeData(
    brightness: Brightness.light,
    primaryColor: text,
    scaffoldBackgroundColor: background,
  );
  static TextStyle dhivehi(
    double size, {
    FontWeight weight = FontWeight.w400,
    Color color = text,
  }) => TextStyle(
    fontFamily: 'MV Waheed',
    // Override Cupertino's SF-specific negative tracking for the bundled face.
    letterSpacing: 0,
    fontSize: size,
    // This bundled face has one regular weight; Swift does not synthesize bold.
    fontWeight: FontWeight.w400,
    color: color,
    // hhea ascent + descent = 1465 / 1000, matching the native line box.
    height: 1.465,
  );
  static String image(String name) => 'assets/images/$name.png';
}
