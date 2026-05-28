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

/// Lanza el error a través del interceptor global.
Never throwIntercepted(dynamic error) {
  ApiErrorInterceptor().handle(error);
  throw error;
}
