import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

abstract class ApiHelper {
  final String baseUrl = 'http://10.130.54.39:5298';
  // final String baseUrl = 'https://10.130.54.39:7225';

    Future<dynamic> get(String endpoint) async {
    final response = await http.get(Uri.parse('$baseUrl/$endpoint'));
    return _handleResponse(response);
  }

  Future<dynamic> post(String endpoint, [dynamic body]) async {
    final response = await http.post(
      Uri.parse('$baseUrl/$endpoint'),
      headers: {'Content-Type': 'application/json'},
      body: body != null ? jsonEncode(body) : null,
    );
    return _handleResponse(response);
  }

  Future<dynamic> put(String endpoint, dynamic body) async {
    final response = await http.put(
      Uri.parse('$baseUrl/$endpoint'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    return _handleResponse(response);
  }

  Future<dynamic> patch(String endpoint, dynamic body) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/$endpoint'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    return _handleResponse(response);
  }

  Future<dynamic> delete(String endpoint) async {
    final response = await http.delete(Uri.parse('$baseUrl/$endpoint'));
    return _handleResponse(response);
  }

  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else {
      throw Exception('API Error: ${response.statusCode} - ${response.body}');
    }
  }
}
