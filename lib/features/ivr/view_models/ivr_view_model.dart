import 'package:flutter/foundation.dart';
import '../repositories/ivr_repository.dart';

enum IvrState { idle, loading, success, error }

class IvrViewModel extends ChangeNotifier {
  final _repo = const IvrRepository();

  IvrState _state = IvrState.idle;
  String _message = '';
  String? _callSid;

  IvrState get state => _state;
  String get message => _message;
  String? get callSid => _callSid;
  bool get loading => _state == IvrState.loading;

  /// Sends POST /api/ivr/call with { toNumber }.
  /// Backend forwards to n8n webhook; n8n initiates Twilio call.
  /// Response (flat, not wrapped in data): { success, sid, message }
  Future<void> requestCall(String toNumber) async {
    _state = IvrState.loading;
    _message = '';
    _callSid = null;
    notifyListeners();

    final response = await _repo.requestCall(toNumber: toNumber);

    if (response.success) {
      _state = IvrState.success;
      _message = response.message.isNotEmpty
          ? response.message
          : 'Your AI call has been initiated. Expect a call shortly!';
      // Backend returns sid at root level (flat); our decoder puts full map in data
      _callSid = response.data?['sid'] as String?;
    } else {
      _state = IvrState.error;
      _message = response.message.isNotEmpty
          ? response.message
          : 'Failed to initiate call. Please try again.';
    }
    notifyListeners();
  }

  void reset() {
    _state = IvrState.idle;
    _message = '';
    _callSid = null;
    notifyListeners();
  }
}

