// EmergencyAlert model — pure data class for the Emergency feature.
//
// MVVM Rule: Model = data only.
// Tracks the state and result of one emergency alert (flight cancellation
// or offline fallback).

/// Which type of alert this model represent.
enum AlertType { flightCancellation, offlineFallback }

/// Loading / result state for each alert card.
enum EmergencyState { idle, loading, success, error }

class EmergencyAlert {
  final AlertType type;
  final EmergencyState state;
  final String message; // user-facing result / error text
  final String? sid;   // Twilio message SID returned on success

  const EmergencyAlert({
    required this.type,
    this.state   = EmergencyState.idle,
    this.message = '',
    this.sid,
  });

  /// Returns a copy with updated fields.
  EmergencyAlert copyWith({
    EmergencyState? state,
    String?         message,
    String?         sid,
  }) =>
      EmergencyAlert(
        type:    type,
        state:   state   ?? this.state,
        message: message ?? this.message,
        sid:     sid     ?? this.sid,
      );
}
