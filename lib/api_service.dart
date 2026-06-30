import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';

// ── Custom Exception ─────────────────────────────────
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

// ── Generic API Service ──────────────────────────────
// كلاس عام مسؤول عن كل عمليات GET/POST/PUT/DELETE
// بيتعامل مع الأخطاء والـ timeout بشكل موحّد لكل الـ app
class ApiService {
  ApiService._();

  static Uri _buildUri(String path, [Map<String, dynamic>? queryParams]) {
    final uri = Uri.parse('${ApiConfig.baseUrl}$path');
    if (queryParams == null || queryParams.isEmpty) return uri;

    // بيشيل أي قيمة null أو فاضية من الـ query قبل ما يبنيها
    final cleanParams = <String, String>{};
    queryParams.forEach((key, value) {
      if (value != null && value.toString().isNotEmpty) {
        cleanParams[key] = value.toString();
      }
    });

    return uri.replace(queryParameters: {
      ...uri.queryParameters,
      ...cleanParams,
    });
  }

  static Future<dynamic> get(String path, {Map<String, dynamic>? query}) async {
    try {
      final uri = _buildUri(path, query);
      final headers = await ApiConfig.headers();

      final response = await http.get(uri, headers: headers).timeout(
        ApiConfig.timeout,
        onTimeout: () => throw ApiException('انتهت مهلة الاتصال بالسيرفر'),
      );

      return _handleResponse(response);
    } on http.ClientException {
      throw ApiException('تعذّر الاتصال بالسيرفر، تحقق من الإنترنت');
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('حدث خطأ غير متوقع: $e');
    }
  }

  static Future<dynamic> post(String path, {Map<String, dynamic>? body}) async {
    try {
      final uri = _buildUri(path);
      final headers = await ApiConfig.headers();

      final response = await http
          .post(uri, headers: headers, body: jsonEncode(body ?? {}))
          .timeout(
        ApiConfig.timeout,
        onTimeout: () => throw ApiException('انتهت مهلة الاتصال بالسيرفر'),
      );

      return _handleResponse(response);
    } on http.ClientException {
      throw ApiException('تعذّر الاتصال بالسيرفر، تحقق من الإنترنت');
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('حدث خطأ غير متوقع: $e');
    }
  }

  static dynamic _handleResponse(http.Response response) {
    final statusCode = response.statusCode;

    dynamic decoded;
    try {
      decoded = response.body.isNotEmpty ? jsonDecode(response.body) : null;
    } catch (_) {
      decoded = null;
    }

    if (statusCode >= 200 && statusCode < 300) {
      return decoded;
    }

    if (statusCode == 401) {
      throw ApiException('انتهت صلاحية الجلسة، الرجاء تسجيل الدخول من جديد',
          statusCode: statusCode);
    }

    final serverMessage = (decoded is Map && decoded['message'] != null)
        ? decoded['message'].toString()
        : 'حدث خطأ بالسيرفر ($statusCode)';

    throw ApiException(serverMessage, statusCode: statusCode);
  }
}