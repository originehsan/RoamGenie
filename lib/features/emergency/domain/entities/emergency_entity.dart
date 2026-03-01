/// EmergencyEntity — domain entity for an emergency alert result.
class EmergencyEntity {
  final String  sid;
  final String  message;
  final bool    success;

  const EmergencyEntity({
    required this.sid,
    required this.message,
    required this.success,
  });
}
