import '../../../core/api/api_service.dart';
import '../services/emergency_api_service.dart';

/// EmergencyRepository — abstraction layer between ViewModel and Service.
///
/// Clean Architecture Rule: ViewModel → Repository → Service.
class EmergencyRepository {
  const EmergencyRepository();

  /// POST /api/emergency/flight-cancellation
  Future<ApiResponse<Map<String, dynamic>>> flightCancellation({
    required String whatsappNumber,
  }) =>
      EmergencyApiService.flightCancellation(whatsappNumber: whatsappNumber);

  /// POST /api/emergency/offline-fallback
  Future<ApiResponse<Map<String, dynamic>>> offlineFallback({
    required String whatsappNumber,
  }) =>
      EmergencyApiService.offlineFallback(whatsappNumber: whatsappNumber);
}
