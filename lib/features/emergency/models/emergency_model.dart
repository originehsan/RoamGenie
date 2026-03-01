// Emergency feature data models.
// Extracted from emergency_view_model.dart to follow Clean Architecture
// where models/ contains pure data classes only.

enum AlertType { flightCancellation, offlineFallback }

enum EmergencyState { idle, loading, success, error }

class EmergencyAlert {
  final AlertType type;
  final EmergencyState state;
  final String message;
  final String? sid;

  const EmergencyAlert({
    required this.type,
    this.state = EmergencyState.idle,
    this.message = '',
    this.sid,
  });

  EmergencyAlert copyWith({
    EmergencyState? state,
    String? message,
    String? sid,
  }) =>
      EmergencyAlert(
        type: type,
        state: state ?? this.state,
        message: message ?? this.message,
        sid: sid ?? this.sid,
      );
}
