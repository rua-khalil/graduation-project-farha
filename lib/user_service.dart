import 'api_config.dart';
import 'api_service.dart';

class UserProfile {
  final String firstName;
  final String lastName;
  final String email;
  final String roleName;

  const UserProfile({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.roleName,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    final roles = json['roles'];
    return UserProfile(
      firstName: json['f_name']?.toString() ?? 'User',
      lastName: json['l_name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      roleName: (roles is Map ? roles['r_name']?.toString() : null) ?? 'user',
    );
  }
}

class UserService {
  UserService._();

  static Future<UserProfile> getCurrentUser() async {
    final prefs = await ApiConfig.prefsInstance();
    final userId = prefs.getString('userId') ?? '';

    if (userId.isEmpty) {
      throw ApiException('لم يتم العثور على المستخدم');
    }

    final response = await ApiService.get('/users/$userId');

    final data = (response is Map && response['data'] is Map)
        ? Map<String, dynamic>.from(response['data'])
        : <String, dynamic>{};

    return UserProfile.fromJson(data);
  }
}