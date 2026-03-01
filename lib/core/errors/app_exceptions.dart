// app_exceptions.dart — Custom exception types for the network layer.
//
// Clean Architecture Rule:
//   Exceptions are thrown by the DATA layer (datasources/repositories).
//   The ViewModel catches them and converts to user-friendly messages.

class ServerException implements Exception {
  final String message;
  final int? statusCode;
  const ServerException({required this.message, this.statusCode});

  @override
  String toString() => 'ServerException($statusCode): $message';
}

class NetworkException implements Exception {
  final String message;
  const NetworkException({this.message = 'No internet connection. Please check your network.'});

  @override
  String toString() => 'NetworkException: $message';
}

class CacheException implements Exception {
  final String message;
  const CacheException({required this.message});

  @override
  String toString() => 'CacheException: $message';
}

class AuthException implements Exception {
  final String message;
  final String? code;
  const AuthException({required this.message, this.code});

  @override
  String toString() => 'AuthException($code): $message';
}

class ValidationException implements Exception {
  final String message;
  const ValidationException({required this.message});

  @override
  String toString() => 'ValidationException: $message';
}
