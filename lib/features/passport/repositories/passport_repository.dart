import '../../../core/api/api_service.dart';
import '../services/passport_api_service.dart';

/// PassportRepository — abstraction layer between ViewModel and Service.
///
/// Clean Architecture Rule: ViewModel → Repository → Service.
class PassportRepository {
  const PassportRepository();

  /// GET /api/passport/countries
  Future<ApiResponse<Map<String, dynamic>>> getCountries() =>
      PassportApiService.getCountries();

  /// POST /api/passport/visa-free
  Future<ApiResponse<Map<String, dynamic>>> lookupVisaFree({
    required String country,
  }) =>
      PassportApiService.lookupVisaFree(country: country);

  /// POST /api/passport/scan (multipart)
  Future<ApiResponse<Map<String, dynamic>>> scanPassport({
    required List<int> imageBytes,
    required String filename,
  }) =>
      PassportApiService.scanPassport(
        imageBytes: imageBytes,
        filename: filename,
      );
}
