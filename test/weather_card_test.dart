import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zamzam_flutter/core/strings.dart';
import 'package:zamzam_flutter/core/ui/dhivehi_text.dart';
import 'package:zamzam_flutter/features/weather/weather_card.dart';
import 'package:zamzam_flutter/features/weather/weather_models.dart';

void main() {
  final reading = WeatherReading(
    temperature: 37.4,
    code: 95,
    wind: 18.2,
    precipitation: 2.6,
    rainChance: 10,
    fetchedAt: DateTime.utc(2026, 9, 27),
  );
  test(
    'weather conditions, Arabic-Indic rain percentage, and stale error priority match Swift',
    () {
      expect(WeatherCondition.fromCode(0), WeatherCondition.clear);
      for (final code in [1, 2, 3, 45, 48]) {
        expect(WeatherCondition.fromCode(code), WeatherCondition.cloudy);
      }
      for (final code in [51, 67, 71, 77, 80, 82]) {
        expect(WeatherCondition.fromCode(code), WeatherCondition.rain);
      }
      expect(WeatherCondition.fromCode(95).style, WeatherStyle.rain);
      expect(WeatherCondition.fromCode(99).style, WeatherStyle.rain);
      expect(WeatherCondition.fromCode(50), WeatherCondition.unknown);
      final display = WeatherDisplay(
        reading: reading,
        cached: true,
        failed: true,
      );
      expect(display.temperature, '37°');
      expect(display.wind, '18 km/h');
      expect(display.precipitation, '١٠%');
      expect(display.badge, Dv.weatherOffline);
      expect(display.animates, isFalse);
      expect(const WeatherDisplay(failed: true).condition, Dv.weatherOffline);
      expect(const WeatherDisplay(loading: true).badge, Dv.weatherLoading);
    },
  );
  testWidgets(
    'weather card retains readable readings on compact and enlarged text layouts',
    (tester) async {
      for (final scale in [1.0, 2.0]) {
        await tester.binding.setSurfaceSize(const Size(320, 720));
        await tester.pumpWidget(
          CupertinoApp(
            home: MediaQuery(
              data: MediaQueryData(textScaler: TextScaler.linear(scale)),
              child: FontScaleScope(
                scale: 1.12,
                child: Center(
                  child: SizedBox(
                    width: 272,
                    child: WeatherCard(
                      city: WeatherCity.makkah,
                      display: WeatherDisplay(reading: reading, failed: true),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.text('37°'), findsOneWidget);
        expect(find.text('18 km/h'), findsOneWidget);
        expect(tester.takeException(), isNull, reason: 'system scale $scale');
      }
      await tester.binding.setSurfaceSize(null);
    },
  );
}
