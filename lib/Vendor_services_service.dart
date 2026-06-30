import 'dart:convert';
import 'package:http/http.dart' as http;
import 'Vendormyservicespage.dart'; // for ServiceModel

// ── Vendor Services API ──────────────────────────────────────────────────────
//
// 10.0.2.2 is the special alias the Android emulator uses to reach
// "localhost" on YOUR computer. If your backend runs on http://localhost:3000
// on your machine, the emulator reaches it at http://10.0.2.2:3000.
//
// NOTE: this only works from the Android EMULATOR. If you test on:
//   - a real Android phone  -> use your computer's LAN IP (e.g. http://192.168.1.50:3000)
//   - iOS simulator         -> use http://localhost:3000
// ─────────────────────────────────────────────────────────────────────────────
class VendorServicesApi {
  static const String baseUrl = 'http://10.0.2.2:3000/api';

  /// Set this after vendor login (e.g. from SharedPreferences / secure storage)
  static String? authToken;

  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (authToken != null) 'Authorization': 'Bearer $authToken',
  };

  // ── GET /vendor/services ────────────────────────
  static Future<List<ServiceModel>> getServices() async {
    final response = await http.get(
      Uri.parse('$baseUrl/vendor/services'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List;
      return data.map((e) => ServiceModel.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load services (${response.statusCode})');
    }
  }

  // ── POST /vendor/services ───────────────────────
  static Future<ServiceModel> addService(ServiceModel service) async {
    final response = await http.post(
      Uri.parse('$baseUrl/vendor/services'),
      headers: _headers,
      body: jsonEncode(service.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return ServiceModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to add service (${response.statusCode})');
    }
  }

  // ── PUT /vendor/services/:id ─────────────────────
  static Future<ServiceModel> updateService(ServiceModel service) async {
    final response = await http.put(
      Uri.parse('$baseUrl/vendor/services/${service.id}'),
      headers: _headers,
      body: jsonEncode(service.toJson()),
    );

    if (response.statusCode == 200) {
      return ServiceModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to update service (${response.statusCode})');
    }
  }

  // ── PATCH /vendor/services/:id/toggle ────────────
  static Future<void> toggleService(String id, bool isActive) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/vendor/services/$id/toggle'),
      headers: _headers,
      body: jsonEncode({'is_active': isActive}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to toggle service (${response.statusCode})');
    }
  }

  // ── DELETE /vendor/services/:id ──────────────────
  static Future<void> deleteService(String id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/vendor/services/$id'),
      headers: _headers,
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete service (${response.statusCode})');
    }
  }
}