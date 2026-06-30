import 'dart:convert';
import 'UserFavoritespage.dart'; // for FavoriteModel

// ── Favorites API Service ───────────────────────────────────────────────────
//
// This service is written to look EXACTLY like a real http-based service.
// Right now `_useMock` is true, so every call returns fake JSON after a
// short delay (so your UI shimmer/loading states behave like production).
//
// To go live later:
//   1. Set `_useMock = false`
//   2. Set `baseUrl` to your real API
//   3. Set `authToken` (Bearer JWT) after login
// Nothing else changes — same method signatures, same return types.
// ─────────────────────────────────────────────────────────────────────────────
class FavoritesService {
  // ── Config ─────────────────────────────────────
  static const String baseUrl = 'http://10.0.2.2:3000/api';
  static const bool _useMock = true; // flip to false when backend is ready

  /// Set this after login (e.g. from SharedPreferences / secure storage)
  static String? authToken;

  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (authToken != null) 'Authorization': 'Bearer $authToken',
  };

  // ── In-memory mock "database" ─────────────────
  static final List<Map<String, dynamic>> _mockDb = [
    {
      'id': '1',
      'venue_name': 'Royal Pearl Hall',
      'location': 'Nablus, Palestine',
      'price': '\$1,200',
      'category': 'Wedding Hall',
      'image': 'https://images.unsplash.com/photo-1519225421980-715cb0202f97',
      'rating': '4.8',
    },
    {
      'id': '2',
      'venue_name': 'Golden Lens Studio',
      'location': 'Ramallah, Palestine',
      'price': '\$450',
      'category': 'Photography',
      'image': 'https://images.unsplash.com/photo-1554048612-b6a482bc67e5',
      'rating': '4.6',
    },
    {
      'id': '3',
      'venue_name': 'Olive Garden Catering',
      'location': 'Nablus, Palestine',
      'price': '\$25 / person',
      'category': 'Catering',
      'image': 'https://images.unsplash.com/photo-1555244162-803834f70033',
      'rating': '4.9',
    },
  ];

  // ── GET /favorites ─────────────────────────────
  static Future<List<FavoriteModel>> getFavorites() async {
    if (_useMock) {
      await Future.delayed(const Duration(milliseconds: 800));
      return _mockDb.map((e) => FavoriteModel.fromJson(e)).toList();
    }

    // Real implementation (uncomment when backend is ready):
    //
    // final response = await http.get(
    //   Uri.parse('$baseUrl/favorites'),
    //   headers: _headers,
    // );
    //
    // if (response.statusCode == 200) {
    //   final data = jsonDecode(response.body) as List;
    //   return data.map((e) => FavoriteModel.fromJson(e)).toList();
    // } else {
    //   throw Exception('Failed to load favorites (${response.statusCode})');
    // }

    throw UnimplementedError('Set _useMock = false and wire up the real API');
  }

  // ── DELETE /favorites/:id ───────────────────────
  static Future<void> removeFavorite(String id) async {
    if (_useMock) {
      await Future.delayed(const Duration(milliseconds: 400));
      _mockDb.removeWhere((e) => e['id'] == id);
      return;
    }

    // Real implementation:
    //
    // final response = await http.delete(
    //   Uri.parse('$baseUrl/favorites/$id'),
    //   headers: _headers,
    // );
    //
    // if (response.statusCode != 200 && response.statusCode != 204) {
    //   throw Exception('Failed to remove favorite (${response.statusCode})');
    // }

    throw UnimplementedError('Set _useMock = false and wire up the real API');
  }

  // ── POST /favorites ─────────────────────────────
  static Future<void> addFavorite(String venueId) async {
    if (_useMock) {
      await Future.delayed(const Duration(milliseconds: 400));
      // pretend it was added successfully
      return;
    }

    // Real implementation:
    //
    // final response = await http.post(
    //   Uri.parse('$baseUrl/favorites'),
    //   headers: _headers,
    //   body: jsonEncode({'venue_id': venueId}),
    // );
    //
    // if (response.statusCode != 200 && response.statusCode != 201) {
    //   throw Exception('Failed to add favorite (${response.statusCode})');
    // }

    throw UnimplementedError('Set _useMock = false and wire up the real API');
  }
}