import 'dart:convert';
import 'package:http/http.dart' as http;
import 'VendorBookingsPage.dart'; // for BookingModel

// ── Vendor Bookings API ──────────────────────────────────────────────────────
// Same pattern as vendor_services_api.dart — real http calls to your backend.
// 10.0.2.2 = Android emulator alias for "localhost" on your computer.
// ─────────────────────────────────────────────────────────────────────────────
class VendorBookingsApi {
  static const String baseUrl = 'http://10.0.2.2:3000/api';

  /// Set this after vendor login (e.g. from SharedPreferences / secure storage)
  static String? authToken;

  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (authToken != null) 'Authorization': 'Bearer $authToken',
  };

  // ── GET /vendor/bookings ─────────────────────────
  static Future<List<BookingModel>> getBookings() async {
    final response = await http.get(
      Uri.parse('$baseUrl/vendor/bookings'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List;
      return data.map((e) => BookingModel.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load bookings (${response.statusCode})');
    }
  }

  // ── PATCH /vendor/bookings/:id/approve ───────────
  static Future<void> approveBooking(String id) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/vendor/bookings/$id/approve'),
      headers: _headers,
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to approve booking (${response.statusCode})');
    }
  }

  // ── PATCH /vendor/bookings/:id/reject ────────────
  static Future<void> rejectBooking(String id) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/vendor/bookings/$id/reject'),
      headers: _headers,
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to reject booking (${response.statusCode})');
    }
  }
}