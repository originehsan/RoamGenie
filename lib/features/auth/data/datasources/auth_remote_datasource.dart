import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/errors/app_exceptions.dart';
import '../models/user_model.dart';

/// AuthRemoteDatasource — wraps Firebase Auth calls.
///
/// Clean Architecture Rule: Datasource only talks to external services.
/// It throws typed Exceptions (never Failures — that is the repository's job).
class AuthRemoteDatasource {
  final FirebaseAuth _auth;

  AuthRemoteDatasource({FirebaseAuth? auth})
      : _auth = auth ?? FirebaseAuth.instance;

  // ── Sign In ─────────────────────────────────────────────────────────────────
  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email:    email.trim(),
        password: password,
      );
      final user = credential.user!;
      return UserModel(
        uid:         user.uid,
        email:       user.email ?? '',
        displayName: user.displayName,
        photoUrl:    user.photoURL,
      );
    } on FirebaseAuthException catch (e) {
      throw AuthException(message: _mapError(e.code), code: e.code);
    } catch (_) {
      throw const AuthException(message: 'Sign-in failed. Please try again.');
    }
  }

  // ── Sign Up ─────────────────────────────────────────────────────────────────
  Future<UserModel> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email:    email.trim(),
        password: password,
      );
      final user = credential.user!;
      if (displayName != null && displayName.isNotEmpty) {
        await user.updateDisplayName(displayName);
      }
      return UserModel(
        uid:         user.uid,
        email:       user.email ?? '',
        displayName: displayName,
        photoUrl:    null,
      );
    } on FirebaseAuthException catch (e) {
      throw AuthException(message: _mapError(e.code), code: e.code);
    } catch (_) {
      throw const AuthException(message: 'Sign-up failed. Please try again.');
    }
  }

  // ── Sign Out ─────────────────────────────────────────────────────────────────
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // ── Password Reset ───────────────────────────────────────────────────────────
  Future<void> sendPasswordReset({required String email}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw AuthException(message: _mapError(e.code), code: e.code);
    }
  }

  // ── Current User ─────────────────────────────────────────────────────────────
  UserModel? get currentUser {
    final user = _auth.currentUser;
    if (user == null) return null;
    return UserModel(
      uid:         user.uid,
      email:       user.email ?? '',
      displayName: user.displayName,
      photoUrl:    user.photoURL,
    );
  }

  // ── Auth State Stream ────────────────────────────────────────────────────────
  Stream<UserModel?> get authStateChanges => _auth.authStateChanges().map(
        (user) => user == null
            ? null
            : UserModel(
                uid:         user.uid,
                email:       user.email ?? '',
                displayName: user.displayName,
                photoUrl:    user.photoURL,
              ),
      );

  // ── Error mapping ────────────────────────────────────────────────────────────
  String _mapError(String code) {
    switch (code) {
      case 'user-not-found':     return 'No account found with this email.';
      case 'wrong-password':     return 'Incorrect password. Please try again.';
      case 'invalid-email':      return 'Invalid email format.';
      case 'invalid-credential': return 'Invalid credentials. Check your email and password.';
      case 'email-already-in-use': return 'An account already exists with this email.';
      case 'weak-password':      return 'Password must be at least 6 characters.';
      case 'user-disabled':      return 'This account has been disabled.';
      case 'too-many-requests':  return 'Too many failed attempts. Try again later.';
      default:                   return 'Authentication failed. Please try again.';
    }
  }
}
