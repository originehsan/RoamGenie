import '../entities/user_entity.dart';
import '../repositories/i_auth_repository.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/errors/app_exceptions.dart';

/// SignupUseCase — single responsibility: register a new user.
class SignupUseCase {
  final IAuthRepository _repository;
  const SignupUseCase(this._repository);

  Future<UserEntity> call({
    required String email,
    required String password,
    required String confirmPassword,
    String? displayName,
  }) async {
    if (email.trim().isEmpty || password.isEmpty) {
      throw const ValidationFailure(message: 'Please fill in all fields.');
    }
    final emailRegex = RegExp(r'^[\w\.\-]+@[\w\-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(email.trim())) {
      throw const ValidationFailure(message: 'Enter a valid email address.');
    }
    if (password.length < 6) {
      throw const ValidationFailure(message: 'Password must be at least 6 characters.');
    }
    if (password != confirmPassword) {
      throw const ValidationFailure(message: 'Passwords do not match.');
    }

    try {
      return await _repository.signUp(
        email:       email,
        password:    password,
        displayName: displayName,
      );
    } on AuthException catch (e) {
      throw AuthFailure(message: e.message);
    } catch (_) {
      throw const UnknownFailure();
    }
  }
}
