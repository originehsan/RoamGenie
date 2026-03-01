import '../../../core/api/api_service.dart';
import '../services/contact_api_service.dart';

/// ContactRepository — abstraction layer between ViewModel and Service.
///
/// Clean Architecture Rule: ViewModel → Repository → Service (never VM → Service directly).
class ContactRepository {
  const ContactRepository();

  /// Submit a contact form.
  /// Returns ApiResponse wrapping success/failure info.
  Future<ApiResponse<Map<String, dynamic>>> submit({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
  }) =>
      ContactApiService.submit(
        firstName: firstName,
        lastName: lastName,
        email: email,
        phone: phone,
      );
}
