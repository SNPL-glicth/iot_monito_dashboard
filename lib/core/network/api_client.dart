import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import 'api_error_interceptor.dart';

// FIX FREEZE: Timeout más agresivo para evitar que la app se cuelgue
// 5 segundos es suficiente para la mayoría de operaciones
// Si el backend tarda más, es mejor mostrar error que congelar la UI
const _kHttpTimeout = Duration(seconds: 5);

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

// Cliente HTTP centralizado para hablar con el backend NestJS
// Desde aquí se añaden cabeceras comunes (como Authorization) y se decodifican respuestas
// SINGLETON: Evita crear múltiples instancias de http.Client que causan memory leaks y lentitud
class ApiClient {
  // Singleton instance
  static final ApiClient _instance = ApiClient._internal();
  // FIX FREEZE: Lazy initialization para evitar freeze en Windows
  static http.Client? _sharedClient;
  
  // Factory constructor retorna siempre la misma instancia
  factory ApiClient({http.Client? client}) => _instance;
  
  // Constructor privado interno
  ApiClient._internal();

  static Never _throwIntercepted(dynamic error) {
    ApiErrorInterceptor().handle(error);
    throw error;
  }

  http.Client get _client {
    _sharedClient ??= http.Client();
    return _sharedClient!;
  }

  // token JWT opcional; se puede actualizar desde AuthRepository
  static String? authToken;

  String get _baseUrl => ApiConfig.baseUrl;

  // Cabeceras comunes para todas las peticiones 
  Map<String, String> _defaultHeaders() {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };
    final token = ApiClient.authToken;
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Future<List<dynamic>> getList(String path) async {
    final uri = Uri.parse('$_baseUrl$path');
    try {
      final response = await _client.get(
        uri,
        headers: _defaultHeaders(),
      ).timeout(_kHttpTimeout);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final body = jsonDecode(response.body);
        if (body is List) {
          return body;
        }
        throw Exception('La respuesta no es una lista JSON.');
      } else {
        _throwIntercepted(ApiException(
          statusCode: response.statusCode,
          method: 'GET',
          path: path,
          body: response.body,
        ));
      }
    } on TimeoutException {
      _throwIntercepted(ApiTimeoutException(path));
    }
  }

  /// GET que devuelve un objeto JSON (Map).
  /// Útil para endpoints tipo `/crm/dashboard`.
  Future<Map<String, dynamic>> getJson(String path) async {
    final uri = Uri.parse('$_baseUrl$path');
    try {
      final response = await _client.get(
        uri,
        headers: _defaultHeaders(),
      ).timeout(_kHttpTimeout);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final decoded = jsonDecode(response.body);
        if (decoded is! Map<String, dynamic>) {
          throw Exception('La respuesta de $path no es un objeto JSON');
        }
        return decoded;
      } else {
        _throwIntercepted(ApiException(
          statusCode: response.statusCode,
          method: 'GET',
          path: path,
          body: response.body,
        ));
      }
    } on TimeoutException {
      _throwIntercepted(ApiTimeoutException(path));
    }
  }

  /// GET que devuelve JSON decodificado (puede ser Map o List).
  /// Útil para endpoints que devuelven arrays o objetos.
  Future<dynamic> getJsonAndDecode(String path) async {
    final uri = Uri.parse('$_baseUrl$path');
    try {
      final response = await _client.get(
        uri,
        headers: _defaultHeaders(),
      ).timeout(_kHttpTimeout);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return jsonDecode(response.body);
      } else {
        _throwIntercepted(ApiException(
          statusCode: response.statusCode,
          method: 'GET',
          path: path,
          body: response.body,
        ));
      }
    } on TimeoutException {
      _throwIntercepted(ApiTimeoutException(path));
    }
  }

  Future<void> postJson(String path, Map<String, dynamic> body) async {
    final uri = Uri.parse('$_baseUrl$path');
    final response = await _client.post(
      uri,
      headers: _defaultHeaders(),
      body: jsonEncode(body),
    ).timeout(_kHttpTimeout);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      _throwIntercepted(ApiException(
        statusCode: response.statusCode,
        method: 'POST',
        path: path,
        body: response.body,
      ));
    }
  }

  /// Variante que devuelve el cuerpo JSON decodificado.
  Future<Map<String, dynamic>> postJsonAndDecode(
    String path,
    Map<String, dynamic> body,
  ) async {
    final uri = Uri.parse('$_baseUrl$path');
    try {
      final response = await _client.post(
        uri,
        headers: _defaultHeaders(),
        body: jsonEncode(body),
      ).timeout(_kHttpTimeout);

      if (response.statusCode < 200 || response.statusCode >= 300) {
        _throwIntercepted(ApiException(
          statusCode: response.statusCode,
          method: 'POST',
          path: path,
          body: response.body,
        ));
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        throw Exception('La respuesta de $path no es un objeto JSON');
      }
      return decoded;
    } on TimeoutException {
      _throwIntercepted(ApiTimeoutException(path));
    }
  }

  Future<Map<String, dynamic>> putJsonAndDecode(
    String path,
    Map<String, dynamic> body,
  ) async {
    final uri = Uri.parse('$_baseUrl$path');
    final response = await _client.put(
      uri,
      headers: _defaultHeaders(),
      body: jsonEncode(body),
    ).timeout(_kHttpTimeout);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      _throwIntercepted(ApiException(
        statusCode: response.statusCode,
        method: 'PUT',
        path: path,
        body: response.body,
      ));
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw Exception('La respuesta de $path no es un objeto JSON');
    }
    return decoded;
  }

  Future<void> delete(String path) async {
    final uri = Uri.parse('$_baseUrl$path');
    final response = await _client.delete(
      uri,
      headers: _defaultHeaders(),
    ).timeout(_kHttpTimeout);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      _throwIntercepted(ApiException(
        statusCode: response.statusCode,
        method: 'DELETE',
        path: path,
        body: response.body,
      ));
    }
  }

  Future<Map<String, dynamic>> deleteAndDecode(String path) async {
    final uri = Uri.parse('$_baseUrl$path');
    final response = await _client.delete(
      uri,
      headers: _defaultHeaders(),
    ).timeout(_kHttpTimeout);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      _throwIntercepted(ApiException(
        statusCode: response.statusCode,
        method: 'DELETE',
        path: path,
        body: response.body,
      ));
    }

    if (response.body.isEmpty) {
      return {'message': 'OK'};
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      return {'message': 'OK'};
    }
    return decoded;
  }

  Future<Map<String, dynamic>> patchJsonAndDecode(
    String path,
    Map<String, dynamic> body,
  ) async {
    final uri = Uri.parse('$_baseUrl$path');
    final response = await _client.patch(
      uri,
      headers: _defaultHeaders(),
      body: jsonEncode(body),
    ).timeout(_kHttpTimeout);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      _throwIntercepted(ApiException(
        statusCode: response.statusCode,
        method: 'PATCH',
        path: path,
        body: response.body,
      ));
    }

    if (response.body.isEmpty) {
      return {'message': 'OK'};
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      return {'message': 'OK'};
    }
    return decoded;
  }
}
