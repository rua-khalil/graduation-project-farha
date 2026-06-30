import 'package:shared_preferences/shared_preferences.dart';

class ApiConfig {
  ApiConfig._();
  static const String baseUrl = 'http://10.0.2.2:3000/api';
  static const String featuredVenues = '/services';
  static const String searchVenues = '/services';
  static const String venueDetails = '/services';
  static const String bookings = '/bookings';

  static const Duration timeout = Duration(seconds: 15);

  // ── Auth Token ───────────────────────────────────────
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  // ── الوصول المباشر لـ SharedPreferences ───────────────
  static Future<SharedPreferences> prefsInstance() async {
    return await SharedPreferences.getInstance();
  }

  // ── Headers (مع التوكن لو موجود) ──────────────────────
  static Future<Map<String, String>> headers() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }
}