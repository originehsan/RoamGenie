import '../entities/user_entity.dart';
import '../repositories/i_auth_repository.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/errors/app_exceptions.dart';

/// LoginUseCase — single responsibility: sign the user in.
///
/// Clean Architecture Rule: One use case per user action.
/// Returns [UserEntity] on success, throws [Failure] on error.
class LoginUseCase {
  final IAuthRepository _repository;
  const LoginUseCase(this._repository);

  Future<UserEntity> call({
    required String email,
    required String password,
  }) async {
    // Input validation lives here — not in the ViewModel, not in the View.
    if (email.trim().isEmpty || password.isEmpty) {
      throw const ValidationFailure(message: 'Please fill in all fields.');
    }
    final emailRegex = RegExp(r'^[\w\.\-]+@[\w\-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(email.trim())) {
      throw const ValidationFailure(message: 'Enter a valid email address.');
    }

    try {
      return await _repository.signIn(email: email, password: password);
    } on AuthException catch (e) {
      throw AuthFailure(message: e.message);
    } catch (_) {
      throw const UnknownFailure();
    }
  }
}
