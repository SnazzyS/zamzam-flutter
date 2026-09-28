import 'package:flutter/cupertino.dart';
import 'package:zamzam_flutter/app/glass_tab_bar.dart';
import 'package:zamzam_flutter/app/router.dart';
import 'package:zamzam_flutter/core/ui/components.dart';
import 'package:zamzam_flutter/features/weather/weather_card.dart';
import 'package:zamzam_flutter/features/weather/weather_models.dart';
import 'package:zamzam_flutter/main.dart';

void main() => runApp(
  ZamzamApp(
    router: createRouter(
      roots: {
        RootTab.weather: (_) => ScreenContainer(
          child: Column(
            children: [
              for (final code in [0, 3, 61, 95]) ...[
                WeatherCard(
                  city: WeatherCity.makkah,
                  display: WeatherDisplay(
                    reading: WeatherReading(
                      temperature: 37,
                      code: code,
                      wind: 18,
                      precipitation: 0,
                      rainChance: 10,
                      fetchedAt: DateTime.utc(2026, 9, 27),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ],
          ),
        ),
      },
    )..go('/weather'),
  ),
);
