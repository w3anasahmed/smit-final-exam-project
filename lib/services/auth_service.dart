import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  AuthService._();

  static const _tokenKey = 'auth_token';
  static const _loginUrl = 'https://dummyjson.com/auth/login';

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  /// [emailOrUsername] is sent as `username` to DummyJSON (spec uses an email field).
  static Future<void> login({
    required String emailOrUsername,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse(_loginUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': emailOrUsername.trim(),
        'password': password,
      }),
    );

    if (response.statusCode != 200) {
      throw AuthException('Login failed. Please check your credentials.');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final token = data['accessToken'] as String?;
    if (token == null || token.isEmpty) {
      throw AuthException('Login failed. No token received.');
    }

    await saveToken(token);
  }
}

class AuthException implements Exception {
  AuthException(this.message);
  final String message;

  @override
  String toString() => message;
}
