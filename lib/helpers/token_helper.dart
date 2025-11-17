import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
class TokenHelper {
  static Future<String?> getUserId() async {
    final storage = const FlutterSecureStorage();
    final token = await storage.read(key: "auth_token");

    if (token == null) return null;

    // Decode JWT
    final parts = token.split('.');
    if (parts.length != 3) return null;

    final payload = base64Url.normalize(parts[1]);
    final decoded = json.decode(utf8.decode(base64Url.decode(payload)));
    // print(decoded);
    // **Claim name depends on what your API puts in the token**
    return decoded["http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier"] ?? decoded["sub"];
  }
}
