import '../entities/emergency_entity.dart';

/// IEmergencyRepository — domain-layer contract for emergency alerts.
abstract class IEmergencyRepository {
  Future<EmergencyEntity> sendFlightCancellationAlert({required String whatsappNumber});
  Future<EmergencyEntity> sendOfflineFallbackAlert({required String whatsappNumber});
}
