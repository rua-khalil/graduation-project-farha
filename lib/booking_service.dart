import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';
import 'UserBookinghistorypage.dart';

class BookingService {
  BookingService._();

  static Future<List<BookingModel>> getUserBookings() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId') ?? '';

    if (userId.isEmpty) {
      throw ApiException('لم يتم العثور على المستخدم، الرجاء تسجيل الدخول من جديد');
    }

    final response = await ApiService.get('/bookings/user/$userId');

    final rawList = (response is Map && response['data'] is List)
        ? response['data'] as List
        : <dynamic>[];

    return rawList
        .map((e) => BookingModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }
}