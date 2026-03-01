import '../../../core/api/api_service.dart';

/// POST /api/ivr/call
/// Body: { toNumber: "+91XXXXXXXXXX" }
class IvrApiService {
  static Future<ApiResponse<Map<String, dynamic>>> requestCall({
    required String toNumber,
  }) {
    return ApiService.post(
      '/ivr/call',
      {'toNumber': toNumber},
      timeout: const Duration(seconds: 20),
    );
  }
}
