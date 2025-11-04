import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherHelper {
  static const String _baseUrl = 'https://api.open-meteo.com/v1/forecast';


  static Future<int> getCurrentWeatherCode(double latitude, double longitude) async {
    try {
      final url = Uri.parse(
          '$_baseUrl?latitude=$latitude&longitude=$longitude&hourly=weather_code&timezone=Europe%2FBerlin&forecast_days=1');
      
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> times = data['hourly']['time'];
        final List<dynamic> weatherCodes = data['hourly']['weather_code'];
        

        final now = DateTime.now();
        final currentHour = now.hour;
        
        return weatherCodes[currentHour];
      } else {
        throw Exception('Failed to load weather data');
      }
    } catch (e) {
      throw Exception('Error fetching weather data: $e');
    }
  }
}