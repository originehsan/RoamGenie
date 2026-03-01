// auth_repository_impl.dart
import '../datasources/auth_remote_datasource.dart';
import '../models/user_model.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/i_auth_repository.dart';

/// AuthRepositoryImpl — concrete implementation of IAuthRepository.
///
/// Clean Architecture Rule:
///   Lives in data/repositories.
///   Translates UserModel (data) → UserEntity (domain).
///   Catches Exceptions from datasource, converts to Failures.
class AuthRepositoryImpl implements IAuthRepository {
  final AuthRemoteDatasource _datasource;

  AuthRepositoryImpl({AuthRemoteDatasource? datasource})
      : _datasource = datasource ?? AuthRemoteDatasource();

  // ── Sign In ──────────────────────────────────────────────────────────────────
  @override
  Future<UserEntity> signIn({
    required String email,
    required String password,
  }) async {
    final model = await _datasource.signIn(email: email, password: password);
    return _toEntity(model);
  }

  // ── Sign Up ──────────────────────────────────────────────────────────────────
  @override
  Future<UserEntity> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async {
    final model = await _datasource.signUp(
      email:       email,
      password:    password,
      displayName: displayName,
    );
    return _toEntity(model);
  }

  // ── Sign Out ─────────────────────────────────────────────────────────────────
  @override
  Future<void> signOut() => _datasource.signOut();

  // ── Password Reset ───────────────────────────────────────────────────────────
  @override
  Future<void> sendPasswordReset({required String email}) =>
      _datasource.sendPasswordReset(email: email);

  // ── Current User ─────────────────────────────────────────────────────────────
  @override
  UserEntity? get currentUser {
    final model = _datasource.currentUser;
    return model == null ? null : _toEntity(model);
  }

  // ── Auth State ───────────────────────────────────────────────────────────────
  @override
  Stream<UserEntity?> get authStateChanges =>
      _datasource.authStateChanges.map((m) => m == null ? null : _toEntity(m));

  // ── Mapper ───────────────────────────────────────────────────────────────────
  UserEntity _toEntity(UserModel model) => UserEntity(
        uid:         model.uid,
        email:       model.email,
        displayName: model.displayName,
        photoUrl:    model.photoUrl,
      );
}
