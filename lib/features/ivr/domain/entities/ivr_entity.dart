/// IvrEntity — domain entity for a call request result.
class IvrEntity {
  final String? callSid;
  final String  message;
  final bool    success;

  const IvrEntity({
    this.callSid,
    required this.message,
    required this.success,
  });
}
