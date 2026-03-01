import '../../../core/api/api_service.dart';

/// POST /api/contact/submit
/// Body: { firstName, lastName, email, phone }
class ContactApiService {
  static Future<ApiResponse<Map<String, dynamic>>> submit({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
  }) {
    return ApiService.post('/contact/submit', {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phone': phone,
    });
  }
}
