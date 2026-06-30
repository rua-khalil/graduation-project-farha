// ── Venue Model ───────────────────────────────────────
class Venue {
  final String id;
  final String name;
  final String location;
  final String capacity;
  final String price;
  final String image;
  final List<String> images;
  final double rating;
  final int reviews;
  final String category;
  final bool isFeatured;

  Venue({
    required this.id,
    required this.name,
    required this.location,
    required this.capacity,
    required this.price,
    required this.image,
    this.images = const [],
    required this.rating,
    required this.reviews,
    required this.category,
    this.isFeatured = false,
  });

  // ── دالة مساعدة لتصحيح روابط الصور على Android Emulator ──
  // بتبدّل localhost لـ 10.0.2.2 (المطلوب فقط لما تجربي على الإيميوليتر)
  static String _fixUrl(String rawUrl) {
    if (rawUrl.isEmpty) return rawUrl;
    return rawUrl.replaceFirst('localhost', '10.0.2.2');
  }

  factory Venue.fromJson(Map<String, dynamic> json) {
    return Venue(
      id: json['s_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      location: json['location']?.toString() ?? '',
      capacity: json['capacity']?.toString() ?? 'Flexible capacity',
      price: json['price']?.toString() ?? '',
      image: _fixUrl(json['image']?.toString() ?? ''),
      images: json['images'] is List
          ? List<String>.from(
          json['images'].map((e) => _fixUrl(e.toString())))
          : <String>[],
      rating: double.tryParse(json['rating']?.toString() ?? '0') ?? 0.0,
      reviews: int.tryParse(json['reviews_count']?.toString() ?? '0') ?? 0,
      category: json['category_name']?.toString() ?? '',
      isFeatured: true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'location': location,
      'capacity': capacity,
      'price': price,
      'image': image,
      'images': images,
      'rating': rating,
      'reviews': reviews,
      'category': category,
      'is_featured': isFeatured,
    };
  }
}

// ── Stats Model ───────────────────────────────────────
class HomeStats {
  final String venuesCount;
  final String eventsCount;
  final String satisfaction;
  final String supportAvailability;

  HomeStats({
    required this.venuesCount,
    required this.eventsCount,
    required this.satisfaction,
    required this.supportAvailability,
  });

  factory HomeStats.fromJson(Map<String, dynamic> json) {
    return HomeStats(
      venuesCount: json['venues_count']?.toString() ?? '0',
      eventsCount: json['events_count']?.toString() ?? '0',
      satisfaction: json['satisfaction']?.toString() ?? '0',
      supportAvailability: json['support_availability']?.toString() ?? '24/7',
    );
  }

  // قيم افتراضية تستخدم وقت الخطأ أو أثناء أول تحميل
  factory HomeStats.fallback() {
    return HomeStats(
      venuesCount: '150+',
      eventsCount: '5,000+',
      satisfaction: '4.8/5',
      supportAvailability: '24/7',
    );
  }
}