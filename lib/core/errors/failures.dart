// failures.dart — Domain-layer failure types.
//
// Clean Architecture Rule:
//   Failures are the DOMAIN layer's representation of errors.
//   Repositories catch Exceptions (data) and return Failures (domain).
//   ViewModels only deal with Failures, never raw exceptions.

abstract class Failure {
  final String message;
  const Failure({required this.message});

  @override
  String toString() => '$runtimeType: $message';
}

/// Returned when the server responds with a non-2xx status.
class ServerFailure extends Failure {
  final int? statusCode;
  const ServerFailure({required super.message, this.statusCode});
}

/// Returned when there is no internet / DNS resolution fails.
class NetworkFailure extends Failure {
  const NetworkFailure({
    super.message = 'No internet connection. Please check your network.',
  });
}

/// Returned for Firebase Authentication errors.
class AuthFailure extends Failure {
  const AuthFailure({required super.message});
}

/// Returned when input validation fails before hitting the network.
class ValidationFailure extends Failure {
  const ValidationFailure({required super.message});
}

/// Returned for unexpected / unknown errors.
class UnknownFailure extends Failure {
  const UnknownFailure({
    super.message = 'An unexpected error occurred. Please try again.',
  });
}
