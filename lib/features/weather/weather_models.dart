import 'package:flutter/foundation.dart';
import '../../core/strings.dart';

enum WeatherStyle { clear, cloudy, rain, staticFallback }

enum WeatherCondition {
  clear(Dv.weatherConditionClear, WeatherStyle.clear),
  cloudy(Dv.weatherConditionCloudy, WeatherStyle.cloudy),
  rain(Dv.weatherConditionRain, WeatherStyle.rain),
  thunderstorm(Dv.weatherConditionThunderstorm, WeatherStyle.rain),
  unknown(Dv.weatherConditionUnknown, WeatherStyle.staticFallback);

  const WeatherCondition(this.title, this.style);
  final String title;
  final WeatherStyle style;
  static WeatherCondition fromCode(int code) => switch (code) {
    0 => clear,
    >= 1 && <= 3 || 45 || 48 => cloudy,
    >= 51 && <= 67 || >= 71 && <= 77 || >= 80 && <= 82 => rain,
    >= 95 && <= 99 => thunderstorm,
    _ => unknown,
  };
}

enum WeatherCity {
  makkah(Dv.weatherMakkahTitle, 21.4225, 39.8262);

  const WeatherCity(this.title, this.latitude, this.longitude);
  final String title;
  final double latitude;
  final double longitude;
}

@immutable
class WeatherReading {
  const WeatherReading({
    required this.temperature,
    required this.code,
    required this.wind,
    required this.precipitation,
    this.rainChance,
    this.observedAt,
    required this.fetchedAt,
  });
  final double temperature, wind, precipitation;
  final int code;
  final int? rainChance;
  final DateTime? observedAt;
  final DateTime fetchedAt;
  WeatherCondition get condition => WeatherCondition.fromCode(code);
}

@immutable
class WeatherDisplay {
  const WeatherDisplay({
    this.reading,
    this.loading = false,
    this.cached = false,
    this.failed = false,
  });
  final WeatherReading? reading;
  final bool loading, cached, failed;
  String get temperature =>
      reading == null ? '--°' : '${reading!.temperature.toStringAsFixed(0)}°';
  String get condition => failed && reading == null
      ? Dv.weatherOffline
      : reading?.condition.title ?? Dv.weatherConditionUnknown;
  String get wind =>
      reading == null ? '--' : '${reading!.wind.toStringAsFixed(0)} km/h';
  String get precipitation {
    if (reading == null) return '--%';
    final value = reading!.rainChance ?? reading!.precipitation.round();
    final digits = '$value'.split('').map((c) {
      final digit = int.tryParse(c);
      return digit == null ? c : String.fromCharCode(0x660 + digit);
    }).join();
    return '$digits%';
  }

  String get badge => loading
      ? Dv.weatherLoading
      : failed
      ? Dv.weatherOffline
      : cached
      ? Dv.weatherCached
      : Dv.weatherLive;
  WeatherStyle get style =>
      reading?.condition.style ?? WeatherStyle.staticFallback;
  bool get animates => reading != null && !failed;
}
