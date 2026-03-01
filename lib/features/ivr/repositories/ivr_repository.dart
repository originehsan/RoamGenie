import '../../../core/api/api_service.dart';
import '../services/ivr_api_service.dart';

/// IvrRepository — abstraction layer between ViewModel and Service.
///
/// Clean Architecture Rule: ViewModel → Repository → Service.
class IvrRepository {
  const IvrRepository();

  /// POST /api/ivr/call
  Future<ApiResponse<Map<String, dynamic>>> requestCall({
    required String toNumber,
  }) =>
      IvrApiService.requestCall(toNumber: toNumber);
}
