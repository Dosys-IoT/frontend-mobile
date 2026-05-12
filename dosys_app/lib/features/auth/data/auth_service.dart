import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/network/api_client.dart';

class AuthService {
  static Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await ApiClient.post(
      '/api/v1/access/login',
      {'email': email, 'password': password},
    );

    // ignore: avoid_print
    print('[AuthService] status=${response.statusCode} body=${response.body}');

    final data = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode == 200) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('access_token', data['accessToken'] as String);
      return {'success': true, 'data': data};
    }

    return {'success': false, 'message': data['message'] ?? 'Login failed'};
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('access_token');
  }
}
