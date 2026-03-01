import 'package:flutter/foundation.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/signup_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../data/repositories/auth_repository_impl.dart';

/// AuthState — all possible states of the auth presentation layer.
enum AuthStatus { idle, loading, success, error }

/// AuthViewModel — presentation layer state and logic for auth.
///
/// Clean Architecture Rule:
///   ViewModel calls UseCases — NEVER directly calls repositories or datasources.
///   Exposes only getters and methods to the View.
///   View reads state and calls methods — ZERO business logic in View.
class AuthViewModel extends ChangeNotifier {
  // ── Injected use cases ───────────────────────────────────────────────────────
  final LoginUseCase  _loginUseCase;
  final SignupUseCase _signupUseCase;
  final LogoutUseCase _logoutUseCase;

  // ── State ────────────────────────────────────────────────────────────────────
  AuthStatus  _status  = AuthStatus.idle;
  String?     _errorMessage;
  UserEntity? _user;
  bool        _obscurePassword        = true;
  bool        _obscureConfirmPassword = true;

  AuthViewModel({
    LoginUseCase?  loginUseCase,
    SignupUseCase? signupUseCase,
    LogoutUseCase? logoutUseCase,
  })  : _loginUseCase  = loginUseCase  ?? LoginUseCase(AuthRepositoryImpl()),
        _signupUseCase = signupUseCase ?? SignupUseCase(AuthRepositoryImpl()),
        _logoutUseCase = logoutUseCase ?? LogoutUseCase(AuthRepositoryImpl());

  // ── Getters ──────────────────────────────────────────────────────────────────
  AuthStatus  get status               => _status;
  bool        get isLoading            => _status == AuthStatus.loading;
  bool        get isSuccess            => _status == AuthStatus.success;
  String?     get errorMessage         => _errorMessage;
  UserEntity? get user                 => _user;
  bool        get obscurePassword      => _obscurePassword;
  bool        get obscureConfirmPassword => _obscureConfirmPassword;

  // ── Methods ──────────────────────────────────────────────────────────────────

  void togglePasswordVisibility() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }

  void toggleConfirmPasswordVisibility() {
    _obscureConfirmPassword = !_obscureConfirmPassword;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Sign in — calls LoginUseCase, updates state.
  Future<void> login({
    required String email,
    required String password,
  }) async {
    _setLoading();
    try {
      _user   = await _loginUseCase(email: email, password: password);
      _status = AuthStatus.success;
    } on Failure catch (f) {
      _setError(f.message);
    } catch (_) {
      _setError('Something went wrong. Please try again.');
    }
    notifyListeners();
  }

  /// Sign up — calls SignupUseCase, updates state.
  Future<void> signup({
    required String email,
    required String password,
    required String confirmPassword,
    String? displayName,
  }) async {
    _setLoading();
    try {
      _user = await _signupUseCase(
        email:           email,
        password:        password,
        confirmPassword: confirmPassword,
        displayName:     displayName,
      );
      _status = AuthStatus.success;
    } on Failure catch (f) {
      _setError(f.message);
    } catch (_) {
      _setError('Something went wrong. Please try again.');
    }
    notifyListeners();
  }

  /// Sign out — calls LogoutUseCase.
  Future<void> logout() async {
    await _logoutUseCase();
    _user   = null;
    _status = AuthStatus.idle;
    notifyListeners();
  }

  // ── Helpers ──────────────────────────────────────────────────────────────────
  void _setLoading() {
    _status       = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();
  }

  void _setError(String msg) {
    _status       = AuthStatus.error;
    _errorMessage = msg;
  }
}
