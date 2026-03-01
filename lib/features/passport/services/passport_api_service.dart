import '../../../core/api/api_service.dart';

/// POST /api/passport/visa-free  — body lookup by country name
/// POST /api/passport/scan       — multipart image OCR scan
/// GET  /api/passport/countries  — list of supported passports
class PassportApiService {
  /// Lookup visa-free countries by manually selecting a country name.
  static Future<ApiResponse<Map<String, dynamic>>> lookupVisaFree({
    required String country,
  }) {
    return ApiService.post('/passport/visa-free', {'country': country});
  }

  /// Scan a passport image (JPG/PNG/WEB
  /// P bytes) via OCR.
  /// Field name expected by the backend: "image"
  static Future<ApiResponse<Map<String, dynamic>>> scanPassport({
    required List<int> imageBytes,
    required String filename,
  }) {
    return ApiService.postMultipart(
      '/passport/scan',
      'image',
      imageBytes,
      filename,
      timeout: const Duration(seconds: 60),
    );
  }

  /// Full list of supported passport countries for the dropdown.
  static Future<ApiResponse<Map<String, dynamic>>> getCountries() {
    return ApiService.get('/passport/countries');
  }
}
