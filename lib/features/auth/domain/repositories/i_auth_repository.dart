import '../entities/user_entity.dart';

/// IAuthRepository — abstract contract for the Auth feature.
///
/// Clean Architecture Rule:
///   This interface lives in the DOMAIN layer.
///   The data layer provides the concrete implementation.
///   Use cases depend ONLY on this interface (Dependency Inversion).
abstract class IAuthRepository {
  Future<UserEntity> signIn({required String email, required String password});
  Future<UserEntity> signUp({required String email, required String password, String? displayName});
  Future<void> signOut();
  Future<void> sendPasswordReset({required String email});
  UserEntity? get currentUser;
  Stream<UserEntity?> get authStateChanges;
}
