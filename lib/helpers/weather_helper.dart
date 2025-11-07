import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:skyfy_app/helpers/location_helper.dart';

class WeatherHelper {
  static const String _baseUrl = 'https://api.open-meteo.com/v1/forecast';

  static int CachedWeatherCode = -1;
  static DateTime? _lastFetch;

  static const Map<int, String> weatherCodeNames = {
    0: "Clear sky",
    1: "Mainly clear",
    2: "Partly cloudy",
    3: "Overcast / Cloud developing",
    45: "Fog",
    48: "Depositing rime fog",
    51: "Light drizzle",
    53: "Moderate drizzle",
    55: "Dense drizzle",
    56: "Light freezing drizzle",
    57: "Dense freezing drizzle",
    61: "Slight rain",
    63: "Moderate rain",
    65: "Heavy rain",
    66: "Light freezing rain",
    67: "Heavy freezing rain",
    71: "Slight snow",
    73: "Moderate snow",
    75: "Heavy snow",
    77: "Snow grains",
    80: "Light rain showers",
    81: "Moderate rain showers",
    82: "Violent rain showers",
    85: "Light snow showers",
    86: "Heavy snow showers",
    95: "Thunderstorm",
    96: "Thunderstorm with light hail",
    99: "Thunderstorm with heavy hail"
  };


  static Future<int> getCurrentWeatherCode() async {

    if (_lastFetch != null &&
        DateTime.now().difference(_lastFetch!).inMinutes < 10 &&
        CachedWeatherCode != -1) {

      return CachedWeatherCode;
    }

    try {
      Position? pos = await LocationsHelper.getUserLocation();
      if (pos == null) {
          return CachedWeatherCode;
      }

      final url = Uri.parse(
        '$_baseUrl?latitude=${pos.latitude}&longitude=${pos.longitude}&hourly=weather_code&timezone=Europe%2FBerlin&forecast_days=1',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> weatherCodes = data['hourly']['weather_code'];

        final now = DateTime.now();
        final currentHour = now.hour;

        final code = weatherCodes[currentHour];
        

        CachedWeatherCode = code;
        _lastFetch = DateTime.now();

        return code;
      } else {
        throw Exception('Failed to load weather data');
      }
    } catch (e) {

      if (CachedWeatherCode != -1) return CachedWeatherCode;
      throw Exception('Error fetching weather data: $e');
    }
  }

  static Future<String> getWeatherDescription() async {
    return weatherCodeNames[await getCurrentWeatherCode()] ?? "Unknown weather condition";
  }
}
