import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String baseUrl = 'http://127.0.0.1:3000/api/v1';
  static const String tokenKey = 'auth_token';

  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'user': {
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': passwordConfirmation,
        },
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('No se pudo registrar el usuario');
    }

    final data = jsonDecode(response.body);
    await saveSession(data['token'], data['user']['id']);
  }

  Future<void> login({required String email, required String password}) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode != 200) {
      throw Exception('Correo o contraseña incorrectos');
    }

    final data = jsonDecode(response.body);
    await saveSession(data['token'], data['user']['id']);
  }

  Future<void> saveToken(String token) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(tokenKey, token);
  }

  static Future<String?> getToken() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getString(tokenKey);
  }

  static Future<bool> isAuthenticated() async {
    return await getToken() != null;
  }

  static Future<void> logout() async {
    final preferences = await SharedPreferences.getInstance();

    await preferences.remove(tokenKey);
    await preferences.remove('user_id');
  }

  Future<void> saveSession(String token, int userId) async {
    final preferences = await SharedPreferences.getInstance();

    await preferences.setString(tokenKey, token);
    await preferences.setInt('user_id', userId);
  }

  static Future<Map<String, String>> authHeaders({bool json = false}) async {
    final token = await getToken();

    return {
      if (json) 'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static Future<int?> getUserId() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getInt('user_id');
  }
}
