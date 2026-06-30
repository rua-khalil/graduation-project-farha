import 'api_config.dart';
import 'api_service.dart';
import 'models.dart';

// ── Venue Service ─────────────────────────────────────
// طبقة وسيطة بين الـ UI والـ API، كل صفحة بتنادي هاد الكلاس
// بدل ما تتعامل مباشرة مع ApiService
class VenueService {
  VenueService._();

  // ── جلب الـ Featured Venues ──────────────────────────
  static Future<List<Venue>> getFeaturedVenues() async {
    final data = await ApiService.get(ApiConfig.featuredVenues);

    final List<dynamic> list = data is Map && data['data'] is Map && data['data']['data'] is List
        ? data['data']['data']
        : (data is List ? data : []);

    return list
        .map((item) => Venue.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  // ── البحث عن فنادق/قاعات حسب الموقع/التاريخ/عدد الضيوف ──
  static Future<List<Venue>> searchVenues({
    String? location,
    DateTime? date,
    String? guests,
  }) async {
    final data = await ApiService.get(
      ApiConfig.searchVenues,
      query: {
        'location': location,
        'date': date?.toIso8601String(),
        'guests': guests,
      },
    );

    final List<dynamic> list = data is Map && data['data'] is Map && data['data']['data'] is List
        ? data['data']['data']
        : (data is List ? data : []);

    return list
        .map((item) => Venue.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  // ── جلب تفاصيل قاعة محددة ────────────────────────────
  static Future<Venue> getVenueById(String id) async {
    final data = await ApiService.get('${ApiConfig.venueDetails}/$id');
    final json = data is Map && data['data'] is Map ? data['data'] : data;
    return Venue.fromJson(Map<String, dynamic>.from(json));
  }

  // ── جلب كل الفينيوزات الخام (مستخدمة بحساب الإحصائيات) ──
  static Future<List<dynamic>> _getAllVenuesRaw() async {
    final data = await ApiService.get(ApiConfig.featuredVenues);
    final List<dynamic> list = data is Map && data['data'] is Map && data['data']['data'] is List
        ? data['data']['data']
        : (data is List ? data : []);
    return list;
  }

  // ── حساب متوسط التقييم من قائمة الفينيوزات ────────────
  static double _averageRating(List<Venue> venues) {
    if (venues.isEmpty) return 0.0;
    final sum = venues.fold<double>(0.0, (acc, v) => acc + v.rating);
    return sum / venues.length;
  }

  // ── جلب إحصائيات الصفحة الرئيسية ─────────────────────
  // عدد الفينيوزات والتقييم: محسوبين من بيانات حقيقية (الباك).
  // عدد الحجوزات الناجحة: ثابت دائماً (5,000+)، لأن endpoint
  // الحجوزات بالباك محمي بتوكن ومش متاح لصفحة عامة بدون تسجيل دخول.
  static Future<HomeStats> getStats() async {
    try {
      final rawVenues = await _getAllVenuesRaw();

      final venues = rawVenues
          .map((item) => Venue.fromJson(Map<String, dynamic>.from(item)))
          .toList();

      final venuesCount = venues.length;
      final avgRating = _averageRating(venues);

      return HomeStats(
        venuesCount: venuesCount > 0 ? '$venuesCount+' : '0',
        eventsCount: '2+', // ثابت دائماً
        satisfaction: avgRating > 0 ? '${avgRating.toStringAsFixed(1)}/5' : '0.0/5',
        supportAvailability: '24/7', // ثابت دائماً
      );
    } catch (e) {
      print('=== getStats ERROR === $e');
      return HomeStats.fallback();
    }
  }
}