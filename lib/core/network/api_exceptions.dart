/// Excepciones HTTP centralizadas para el cliente API.
library;

import '../network/api_error_interceptor.dart';

class ApiException implements Exception {
  ApiException({
    required this.statusCode,
    required this.method,
    required this.path,
    required this.body,
  });

  final int statusCode;
  final String method;
  final String path;
  final String body;

  @override
  String toString() => 'ApiException($statusCode) $method $path';
}

class ApiTimeoutException implements Exception {
  ApiTimeoutException(this.path);
  final String path;

  @override
  String toString() => 'Timeout al conectar con el servidor';
}

class UnauthorizedException implements Exception {
  UnauthorizedException(this.path);
  final String path;

  @override
  String toString() => 'Sesión expirada o no autorizada: $path';
}

class ServerException implements Exception {
  ServerException(this.path, this.statusCode, this.body);
  final String path;
  final int statusCode;
  final String body;

  @override
  String toString() => 'Error del servidor ($statusCode) en $path';
}

/// Lanza el error a través del interceptor global.
Never throwIntercepted(dynamic error) {
  ApiErrorInterceptor().handle(error);
  throw error;
}
