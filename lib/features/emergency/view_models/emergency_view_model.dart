import 'package:flutter/foundation.dart';
import '../models/emergency_model.dart';
import '../repositories/emergency_repository.dart';

export '../models/emergency_model.dart'; // re-export so views don't need a separate import

class EmergencyViewModel extends ChangeNotifier {
  final _repo = const EmergencyRepository();

  EmergencyAlert _cancellation = const EmergencyAlert(
    type: AlertType.flightCancellation,
  );
  EmergencyAlert _fallback = const EmergencyAlert(
    type: AlertType.offlineFallback,
  );

  EmergencyAlert get cancellation => _cancellation;
  EmergencyAlert get fallback => _fallback;

  // ── Send flight cancellation alert ──────────────────────────────────────────
  // Backend: POST /api/emergency/flight-cancellation
  // Body:    { whatsappNumber: "+91XXXXXXXXXX" }
  // Response (flat): { success, sid, status, message }
  Future<void> sendFlightCancellation(String whatsappNumber) async {
    _cancellation = _cancellation.copyWith(
        state: EmergencyState.loading, message: '');
    notifyListeners();

    final res = await _repo.flightCancellation(whatsappNumber: whatsappNumber);

    // Backend returns sid at root level (flat response); our decoder maps full
    // JSON as data so data['sid'] gives the Twilio message SID.
    _cancellation = _cancellation.copyWith(
      state: res.success ? EmergencyState.success : EmergencyState.error,
      message: res.message,
      sid: res.data?['sid'] as String?,
    );
    notifyListeners();
  }

  // ── Send offline fallback message ────────────────────────────────────────────
  // Backend: POST /api/emergency/offline-fallback
  // Body:    { whatsappNumber: "+91XXXXXXXXXX" }
  // Response (flat): { success, sid, status, message }
  Future<void> sendOfflineFallback(String whatsappNumber) async {
    _fallback = _fallback.copyWith(
        state: EmergencyState.loading, message: '');
    notifyListeners();

    final res = await _repo.offlineFallback(whatsappNumber: whatsappNumber);

    _fallback = _fallback.copyWith(
      state: res.success ? EmergencyState.success : EmergencyState.error,
      message: res.message,
      sid: res.data?['sid'] as String?,
    );
    notifyListeners();
  }

  void resetCancellation() {
    _cancellation = const EmergencyAlert(type: AlertType.flightCancellation);
    notifyListeners();
  }

  void resetFallback() {
    _fallback = const EmergencyAlert(type: AlertType.offlineFallback);
    notifyListeners();
  }
}

