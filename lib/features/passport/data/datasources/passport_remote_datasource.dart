import '../../../../core/api/api_service.dart';
import '../../models/passport_result.dart';

/// PassportRemoteDatasource — wraps PassportApiService calls.
class PassportRemoteDatasource {
  Future<List<String>> getCountries() async {
    final response = await ApiService.get('/passport/countries');
    if (response.success && response.data != null) {
      final raw = response.data!['countries'];
      return raw is List ? raw.map((e) => e.toString()).toList() : [];
    }
    // Graceful fallback
    return [
      'India', 'United States', 'United Kingdom', 'Canada',
      'Australia', 'Germany', 'France', 'Japan', 'Singapore',
      'UAE', 'China', 'Brazil', 'South Korea', 'Netherlands',
    ];
  }

  Future<PassportResult> lookupVisaFree({required String country}) async {
    final response = await ApiService.post(
        '/passport/visa-free', {'country': country});
    if (response.success && response.data != null) {
      return PassportResult.fromJson(response.data!);
    }
    throw Exception(response.message.isNotEmpty
        ? response.message
        : 'Could not fetch visa information.');
  }

  Future<PassportResult> scanPassport({
    required List<int> imageBytes,
    required String    filename,
  }) async {
    final response = await ApiService.postMultipart(
      '/passport/scan', 'image', imageBytes, filename,
      timeout: const Duration(seconds: 60),
    );
    if (response.success && response.data != null) {
      return PassportResult.fromJson(response.data!);
    }
    throw Exception(response.message.isNotEmpty
        ? response.message
        : 'Could not scan passport. Try a clearer image.');
  }
}
