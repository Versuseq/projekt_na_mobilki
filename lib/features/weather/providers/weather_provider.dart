import 'dart:async';
import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/config/env.dart';
import '../../../core/network/api_client.dart';

part 'weather_provider.g.dart';

class WeatherData {
  final double temperature;
  final double apparentTemperature;
  final int humidity;
  final double precipitation;
  final double windSpeed;
  final int windDirection;
  final double pressure;
  final int cloudCover;
  final int weatherCode;
  final bool isDay;
  final double tempMax;
  final double tempMin;
  final String sunrise;
  final String sunset;
  final double uvIndexMax;

  WeatherData({
    required this.temperature,
    required this.apparentTemperature,
    required this.humidity,
    required this.precipitation,
    required this.windSpeed,
    required this.windDirection,
    required this.pressure,
    required this.cloudCover,
    required this.weatherCode,
    required this.isDay,
    required this.tempMax,
    required this.tempMin,
    required this.sunrise,
    required this.sunset,
    required this.uvIndexMax,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    final current = json['current'];
    final daily = json['daily'];

    String formatTime(String? rawTime) {
      if (rawTime == null || !rawTime.contains('T')) return '--:--';
      return rawTime.split('T')[1];
    }

    return WeatherData(
      temperature: (current['temperature_2m'] as num).toDouble(),
      apparentTemperature: (current['apparent_temperature'] as num).toDouble(),
      humidity: (current['relative_humidity_2m'] as num).toInt(),
      precipitation: (current['precipitation'] as num).toDouble(),
      windSpeed: (current['wind_speed_10m'] as num).toDouble(),
      windDirection: (current['wind_direction_10m'] as num).toInt(),
      pressure: (current['surface_pressure'] as num).toDouble(),
      cloudCover: (current['cloud_cover'] as num).toInt(),
      weatherCode: (current['weather_code'] as num).toInt(),
      isDay: (current['is_day'] as num) == 1,
      tempMax: ((daily['temperature_2m_max'] as List).first as num).toDouble(),
      tempMin: ((daily['temperature_2m_min'] as List).first as num).toDouble(),
      sunrise: formatTime((daily['sunrise'] as List).first as String?),
      sunset: formatTime((daily['sunset'] as List).first as String?),
      uvIndexMax: ((daily['uv_index_max'] as List).first as num).toDouble(),
    );
  }

  String get windDirectionText {
    if (windDirection >= 338 || windDirection < 23) return 'Północny (N)';
    if (windDirection >= 23 && windDirection < 68) return 'Północno-Wschodni (NE)';
    if (windDirection >= 68 && windDirection < 113) return 'Wschodni (E)';
    if (windDirection >= 113 && windDirection < 158) return 'Południowo-Wschodni (SE)';
    if (windDirection >= 158 && windDirection < 203) return 'Południowy (S)';
    if (windDirection >= 203 && windDirection < 248) return 'Południowo-Zachodni (SW)';
    if (windDirection >= 248 && windDirection < 293) return 'Zachodni (W)';
    return 'Północno-Zachodni (NW)';
  }

  String get weatherDescription {
    switch (weatherCode) {
      case 0:
        return isDay ? 'Słonecznie / Czyste niebo ☀️' : 'Jasna noc 🌙';
      case 1:
      case 2:
      case 3:
        return 'Częściowe zachmurzenie ⛅';
      case 45:
      case 48:
        return 'Mgła 🌫️';
      case 51:
      case 53:
      case 55:
        return 'Mżawka 🌧️';
      case 61:
      case 63:
      case 65:
        return 'Deszcz 🌧️';
      case 71:
      case 73:
      case 75:
        return 'Opady śniegu ❄️';
      case 95:
      case 96:
      case 99:
        return 'Burza z piorunami ⚡';
      default:
        return 'Zmienne warunki 🌤️';
    }
  }
}

@riverpod
Future<WeatherData> fetchWeather(
    Ref ref, {
      required double lat,
      required double lng,
    }) async {
  final client = ref.watch(dioProvider);

  try {
    final response = await client.get(
      Env.openMeteoBaseUrl,
      queryParameters: {
        'latitude': lat,
        'longitude': lng,
        'current':
        'temperature_2m,relative_humidity_2m,apparent_temperature,is_day,precipitation,weather_code,cloud_cover,surface_pressure,wind_speed_10m,wind_direction_10m',
        'daily':
        'temperature_2m_max,temperature_2m_min,sunrise,sunset,uv_index_max',
        'timezone': 'auto',
      },
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      return WeatherData.fromJson(response.data as Map<String, dynamic>);
    } else {
      throw Exception('Nie udało się pobrać szczegółów pogody');
    }
  } on TimeoutException {
    throw Exception('Przekroczono limit czasu. Słabe połączenie z siecią.');
  } on DioException catch (e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      throw Exception('Przekroczono limit czasu połączenia.');
    }
    rethrow;
  }
}