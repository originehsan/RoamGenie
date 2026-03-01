import '../entities/passport_entity.dart';

/// IPassportRepository — domain-layer contract for passport/visa operations.
abstract class IPassportRepository {
  Future<List<String>> getCountries();
  Future<PassportEntity> lookupVisaFree({required String country});
  Future<PassportEntity> scanPassport({
    required List<int> imageBytes,
    required String    filename,
  });
}
