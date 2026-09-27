import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import '../../core/platform/app_symbol.dart';
import '../../core/platform/rounded_number.dart';
import '../../core/strings.dart';
import '../../core/theme.dart';
import '../../core/ui/dhivehi_text.dart';
import 'weather_models.dart';
import 'weather_scene.dart';

class WeatherCard extends StatelessWidget {
  const WeatherCard({super.key, required this.city, required this.display});
  final WeatherCity city;
  final WeatherDisplay display;
  @override
  Widget build(BuildContext context) {
    // Retain 224 points normally; permit readable content at enlarged text sizes.
    final scale = math.max(
      MediaQuery.textScalerOf(context).scale(48) / 48,
      MediaQuery.textScalerOf(context).scale(17 * FontScaleScope.of(context)) /
          17,
    );
    // The fixed Swift frame clips a measured 231-point content stack to 224.
    final height = 224.0 + math.max(0.0, scale - 1.12) * 130;
    return Semantics(
      container: true,
      label:
          '${city.title}, ${display.condition}, ${display.temperature}, ${display.badge}, ${Dv.weatherRainChance}: ${display.precipitation}, ${Dv.weatherWind}: ${display.wind}',
      excludeSemantics: true,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF087A43).withValues(alpha: .20),
              blurRadius: 44,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        foregroundDecoration: ShapeDecoration(
          shape: RoundedSuperellipseBorder(
            borderRadius: BorderRadius.circular(30),
            side: BorderSide(
              color: CupertinoColors.white.withValues(alpha: .38),
            ),
          ),
        ),
        child: ClipRSuperellipse(
          borderRadius: BorderRadius.circular(30),
          child: OverflowBox(
            minHeight: height + 7,
            maxHeight: height + 7,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CustomPaint(painter: WeatherScenePainter(style: display.style)),
                Padding(
                  padding: const EdgeInsets.all(18),
                  child: Directionality(
                    textDirection: TextDirection.ltr,
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  FittedBox(
                                    fit: BoxFit.scaleDown,
                                    alignment: Alignment.centerLeft,
                                    child: RoundedNumber(
                                      display.temperature,
                                      size: 48,
                                      color: CupertinoColors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  DvText(
                                    display.condition,
                                    size: 17,
                                    color: CupertinoColors.white.withValues(
                                      alpha: .9,
                                    ),
                                    maxLines: 2,
                                    minScale: .74,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  SizedBox(
                                    height:
                                        MediaQuery.textScalerOf(
                                          context,
                                        ).scale(28 + 2 / 3) *
                                        FontScaleScope.of(context),
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      alignment: Alignment.centerRight,
                                      child: DvText(
                                        city.title,
                                        size: 25,
                                        color: CupertinoColors.white,
                                        maxLines: 1,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: CupertinoColors.white.withValues(
                                        alpha: display.loading ? .16 : .24,
                                      ),
                                      borderRadius: BorderRadius.circular(100),
                                    ),
                                    child: DvText(
                                      display.badge,
                                      size: 13,
                                      color: CupertinoColors.white,
                                      maxLines: 1,
                                      minScale: .74,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Row(
                          children: [
                            Expanded(
                              child: _WeatherMetric(
                                title: Dv.weatherRainChance,
                                value: display.precipitation,
                                symbol: 'cloud.rain.fill',
                                fallback: CupertinoIcons.cloud_rain_fill,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _WeatherMetric(
                                title: Dv.weatherWind,
                                value: display.wind,
                                symbol: 'wind',
                                fallback: CupertinoIcons.wind,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _WeatherMetric extends StatelessWidget {
  const _WeatherMetric({
    required this.title,
    required this.value,
    required this.symbol,
    required this.fallback,
  });
  final String title, value, symbol;
  final IconData fallback;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    decoration: BoxDecoration(
      color: CupertinoColors.white.withValues(alpha: .9),
      borderRadius: BorderRadius.circular(18),
      boxShadow: [
        BoxShadow(
          color: CupertinoColors.black.withValues(alpha: .08),
          blurRadius: 20,
          offset: const Offset(0, 5),
        ),
      ],
    ),
    child: Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: AppTheme.green.withValues(alpha: .14),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: AppSymbol(
              symbol,
              fallback: fallback,
              size: 15,
              color: const Color(0xFF008A3A),
              bold: true,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              DvText(
                title,
                size: 11,
                color: AppTheme.secondary,
                maxLines: 1,
                minScale: .78,
              ),
              const SizedBox(height: 1),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: RoundedNumber(value, size: 15, color: AppTheme.text),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
