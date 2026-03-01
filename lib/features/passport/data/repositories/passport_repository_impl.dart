import '../datasources/passport_remote_datasource.dart';
import '../../models/passport_result.dart';
import '../../domain/entities/passport_entity.dart';
import '../../domain/repositories/i_passport_repository.dart';

/// PassportRepositoryImpl — maps PassportResult (data) → PassportEntity (domain).
class PassportRepositoryImpl implements IPassportRepository {
  final PassportRemoteDatasource _datasource;

  PassportRepositoryImpl({PassportRemoteDatasource? datasource})
      : _datasource = datasource ?? PassportRemoteDatasource();

  @override
  Future<List<String>> getCountries() => _datasource.getCountries();

  @override
  Future<PassportEntity> lookupVisaFree({required String country}) async {
    final m = await _datasource.lookupVisaFree(country: country);
    return _toEntity(m);
  }

  @override
  Future<PassportEntity> scanPassport({
    required List<int> imageBytes,
    required String    filename,
  }) async {
    final m = await _datasource.scanPassport(
        imageBytes: imageBytes, filename: filename);
    return _toEntity(m);
  }

  PassportEntity _toEntity(PassportResult m) => PassportEntity(
        country:            m.country,
        confidence:         m.confidence,
        visaFreeCountries:  m.visaFreeCountries,
        regionBreakdown:    m.regionBreakdown,
        flags:              m.flags,
        availablePassports: m.availablePassports,
      );
}
