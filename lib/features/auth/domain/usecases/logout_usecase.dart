import '../repositories/i_auth_repository.dart';

/// LogoutUseCase — single responsibility: sign the user out.
class LogoutUseCase {
  final IAuthRepository _repository;
  const LogoutUseCase(this._repository);

  Future<void> call() => _repository.signOut();
}
