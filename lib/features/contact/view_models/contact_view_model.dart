import 'package:flutter/foundation.dart';
import '../repositories/contact_repository.dart';

enum ContactState { idle, loading, success, error }

class ContactViewModel extends ChangeNotifier {
  final _repo = const ContactRepository();

  ContactState _state = ContactState.idle;
  String _message = '';

  ContactState get state => _state;
  String get message => _message;
  bool get loading => _state == ContactState.loading;

  Future<void> submit({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
  }) async {
    _state = ContactState.loading;
    _message = '';
    notifyListeners();

    final response = await _repo.submit(
      firstName: firstName,
      lastName: lastName,
      email: email,
      phone: phone,
    );

    _state = response.success ? ContactState.success : ContactState.error;
    _message = response.message;
    notifyListeners();
  }

  void reset() {
    _state = ContactState.idle;
    _message = '';
    notifyListeners();
  }
}
