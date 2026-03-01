import '../entities/ivr_entity.dart';
import '../repositories/i_ivr_repository.dart';

/// RequestCallUseCase — initiates an AI voice call.
class RequestCallUseCase {
  final IIvrRepository _repository;
  const RequestCallUseCase(this._repository);

  Future<IvrEntity> call({required String toNumber}) =>
      _repository.requestCall(toNumber: toNumber);
}
