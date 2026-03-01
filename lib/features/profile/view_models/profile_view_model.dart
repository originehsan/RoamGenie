import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// ProfileViewModel — manages profile display state and user preferences.
///
/// Local-only state for now (budget, comfort, notifications).
/// Can be persisted via SharedPreferences in a future iteration.
class ProfileViewModel extends ChangeNotifier {
  // ── Firebase user ──────────────────────────────────────────────────────────
  User? get currentUser => FirebaseAuth.instance.currentUser;

  String get email => currentUser?.email ?? 'traveler@roamgenie.com';

  String get displayName {
    final name = currentUser?.displayName;
    if (name != null && name.isNotEmpty) return name;
    return email.split('@').first;
  }

  String get initial => displayName[0].toUpperCase();

  // ── User preferences (local state) ────────────────────────────────────────
  double _budget = 50000;
  double _comfortLevel = 2; // 0=Budget … 4=First
  bool _notifications = true;

  double get budget => _budget;
  double get comfortLevel => _comfortLevel;
  bool get notifications => _notifications;

  void setBudget(double v) {
    _budget = v;
    notifyListeners();
  }

  void setComfortLevel(double v) {
    _comfortLevel = v;
    notifyListeners();
  }

  void setNotifications(bool v) {
    _notifications = v;
    notifyListeners();
  }

  // ── Logout ─────────────────────────────────────────────────────────────────
  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
  }
}
