import '../entities/emergency_entity.dart';
import '../repositories/i_emergency_repository.dart';

/// SendFlightCancellationAlertUseCase
class SendFlightCancellationAlertUseCase {
  final IEmergencyRepository _repository;
  const SendFlightCancellationAlertUseCase(this._repository);

  Future<EmergencyEntity> call({required String whatsappNumber}) =>
      _repository.sendFlightCancellationAlert(whatsappNumber: whatsappNumber);
}

/// SendOfflineFallbackAlertUseCase
class SendOfflineFallbackAlertUseCase {
  final IEmergencyRepository _repository;
  const SendOfflineFallbackAlertUseCase(this._repository);

  Future<EmergencyEntity> call({required String whatsappNumber}) =>
      _repository.sendOfflineFallbackAlert(whatsappNumber: whatsappNumber);
}
