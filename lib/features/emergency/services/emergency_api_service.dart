import '../../../core/api/api_service.dart';

/// Emergency alert endpoints — both use the same input: { whatsappNumber }
class EmergencyApiService {
  /// POST /api/emergency/flight-cancellation
  static Future<ApiResponse<Map<String, dynamic>>> flightCancellation({
    required String whatsappNumber,
  }) {
    return ApiService.post(
      '/emergency/flight-cancellation',
      {'whatsappNumber': whatsappNumber},
    );
  }

  /// POST /api/emergency/offline-fallback
  static Future<ApiResponse<Map<String, dynamic>>> offlineFallback({
    required String whatsappNumber,
  }) {
    return ApiService.post(
      '/emergency/offline-fallback',
      {'whatsappNumber': whatsappNumber},
    );
  }
}
