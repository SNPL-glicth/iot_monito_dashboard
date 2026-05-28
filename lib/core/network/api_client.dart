import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import 'api_exceptions.dart';

export 'api_exceptions.dart';

// FIX FREEZE: Timeout más agresivo para evitar que la app se cuelgue
const _kHttpTimeout = Duration(seconds: 5);

/// Cliente HTTP centralizado para hablar con el backend NestJS.
///
/// Desde aquí se añaden cabeceras comunes (como Authorization) y se decodifican respuestas.
/// SINGLETON: Evita crear múltiples instancias de http.Client que causan memory leaks y lentitud.
class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  static http.Client? _sharedClient;

  factory ApiClient({http.Client? client}) => _instance;
  ApiClient._internal();

  http.Client get _client {
    _sharedClient ??= http.Client();
    return _sharedClient!;
  }

  static String? authToken;
  String get _baseUrl => ApiConfig.baseUrl;

  Map<String, String> _defaultHeaders() {
    final headers = <String, String>{'Content-Type': 'application/json'};
    final token = ApiClient.authToken;
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Future<List<dynamic>> getList(String path) async {
    final uri = Uri.parse('$_baseUrl$path');
    try {
      final response = await _client
          .get(uri, headers: _defaultHeaders())
          .timeout(_kHttpTimeout);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final body = jsonDecode(response.body);
        if (body is List) return body;
        throw Exception('La respuesta no es una lista JSON.');
      } else {
        throwIntercepted(ApiException(
          statusCode: response.statusCode,
          method: 'GET',
          path: path,
          body: response.body,
        ));
      }
    } on TimeoutException {
      throwIntercepted(ApiTimeoutException(path));
    } catch (e) {
      throwIntercepted(Exception('Error de red en GET $path: $e'));
    }
  }

  Future<Map<String, dynamic>> getJson(String path) async {
    final uri = Uri.parse('$_baseUrl$path');
    try {
      final response = await _client
          .get(uri, headers: _defaultHeaders())
          .timeout(_kHttpTimeout);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final decoded = jsonDecode(response.body);
        if (decoded is! Map<String, dynamic>) {
          throw Exception('La respuesta de $path no es un objeto JSON');
        }
        return decoded;
      } else {
        throwIntercepted(ApiException(
          statusCode: response.statusCode,
          method: 'GET',
          path: path,
          body: response.body,
        ));
      }
    } on TimeoutException {
      throwIntercepted(ApiTimeoutException(path));
    } catch (e) {
      throwIntercepted(Exception('Error de red en GET $path: $e'));
    }
  }

  Future<dynamic> getJsonAndDecode(String path) async {
    final uri = Uri.parse('$_baseUrl$path');
    try {
      final response = await _client
          .get(uri, headers: _defaultHeaders())
          .timeout(_kHttpTimeout);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return jsonDecode(response.body);
      } else {
        throwIntercepted(ApiException(
          statusCode: response.statusCode,
          method: 'GET',
          path: path,
          body: response.body,
        ));
      }
    } on TimeoutException {
      throwIntercepted(ApiTimeoutException(path));
    } catch (e) {
      throwIntercepted(Exception('Error de red en GET $path: $e'));
    }
  }

  Future<void> postJson(String path, Map<String, dynamic> body) async {
    final uri = Uri.parse('$_baseUrl$path');
    final response = await _client
        .post(uri, headers: _defaultHeaders(), body: jsonEncode(body))
        .timeout(_kHttpTimeout);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throwIntercepted(ApiException(
        statusCode: response.statusCode,
        method: 'POST',
        path: path,
        body: response.body,
      ));
    }
  }

  Future<Map<String, dynamic>> postJsonAndDecode(
    String path,
    Map<String, dynamic> body,
  ) async {
    final uri = Uri.parse('$_baseUrl$path');
    try {
      final response = await _client
          .post(uri, headers: _defaultHeaders(), body: jsonEncode(body))
          .timeout(_kHttpTimeout);

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throwIntercepted(ApiException(
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
      throwIntercepted(ApiTimeoutException(path));
    }
  }

  Future<Map<String, dynamic>> putJsonAndDecode(
    String path,
    Map<String, dynamic> body,
  ) async {
    final uri = Uri.parse('$_baseUrl$path');
    final response = await _client
        .put(uri, headers: _defaultHeaders(), body: jsonEncode(body))
        .timeout(_kHttpTimeout);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throwIntercepted(ApiException(
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
    final response = await _client
        .delete(uri, headers: _defaultHeaders())
        .timeout(_kHttpTimeout);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throwIntercepted(ApiException(
        statusCode: response.statusCode,
        method: 'DELETE',
        path: path,
        body: response.body,
      ));
    }
  }

  Future<Map<String, dynamic>> deleteAndDecode(String path) async {
    final uri = Uri.parse('$_baseUrl$path');
    final response = await _client
        .delete(uri, headers: _defaultHeaders())
        .timeout(_kHttpTimeout);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throwIntercepted(ApiException(
        statusCode: response.statusCode,
        method: 'DELETE',
        path: path,
        body: response.body,
      ));
    }

    if (response.body.isEmpty) return {'message': 'OK'};

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) return {'message': 'OK'};
    return decoded;
  }

  Future<Map<String, dynamic>> patchJsonAndDecode(
    String path,
    Map<String, dynamic> body,
  ) async {
    final uri = Uri.parse('$_baseUrl$path');
    final response = await _client
        .patch(uri, headers: _defaultHeaders(), body: jsonEncode(body))
        .timeout(_kHttpTimeout);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throwIntercepted(ApiException(
        statusCode: response.statusCode,
        method: 'PATCH',
        path: path,
        body: response.body,
      ));
    }

    if (response.body.isEmpty) return {'message': 'OK'};

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) return {'message': 'OK'};
    return decoded;
  }
}
