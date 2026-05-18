import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/config/api_config.dart';
import 'models/monitoring_view_models.dart';

/// Cache entry para almacenar respuestas
class _CacheEntry {
  final Map<String, dynamic> data;
  final DateTime timestamp;
  _CacheEntry(this.data, this.timestamp);
}

/// FASE 1 CORRECCIÓN ARQUITECTÓNICA:
/// 
/// Este repositorio consume EXCLUSIVAMENTE el servidor de Telemetría (:8099)
/// para datos de visualización de sensores (gráficas, métricas en tiempo real).
/// 
/// OPTIMIZACIONES DE RENDIMIENTO:
/// - Cache en memoria con TTL de 3 segundos
/// - Timeout reducido a 5 segundos para fallar rápido
/// - Flag de "Telemetría caída" para evitar requests innecesarios
/// 
/// NO REQUIERE AUTENTICACIÓN (endpoints públicos de telemetría)
class TelemetryRepository {
  static final TelemetryRepository _instance = TelemetryRepository._internal();
  static http.Client? _sharedClient;
  
  factory TelemetryRepository() => _instance;
  
  TelemetryRepository._internal();

  http.Client get _client {
    _sharedClient ??= http.Client();
    return _sharedClient!;
  }

  String get _baseUrl => ApiConfig.telemetryUrl;
  
  // Cache en memoria para evitar requests repetidos
  static final Map<String, _CacheEntry> _cache = {};
  static const _cacheTtl = Duration(seconds: 3);
  
  // Flag para evitar requests cuando Telemetría está caída
  static bool _telemetryDown = false;
  static DateTime? _lastDownCheck;
  static const _downCheckInterval = Duration(seconds: 30);

  Map<String, String> _defaultHeaders() {
    return <String, String>{
      'Content-Type': 'application/json',
    };
  }

  Future<Map<String, dynamic>> _getJson(String path) async {
    // Si Telemetría está caída, no intentar por 30 segundos
    if (_telemetryDown) {
      final now = DateTime.now();
      if (_lastDownCheck != null && 
          now.difference(_lastDownCheck!) < _downCheckInterval) {
        throw Exception('Telemetría no disponible (retry en ${_downCheckInterval.inSeconds - now.difference(_lastDownCheck!).inSeconds}s)');
      }
      _telemetryDown = false; // Reintentar
    }
    
    // Verificar cache
    final cacheKey = path;
    final cached = _cache[cacheKey];
    if (cached != null && DateTime.now().difference(cached.timestamp) < _cacheTtl) {
      return cached.data;
    }
    
    final uri = Uri.parse('$_baseUrl$path');
    try {
      final response = await _client.get(
        uri,
        headers: _defaultHeaders(),
      ).timeout(const Duration(seconds: 5)); // Reducido de 10s a 5s

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          // Guardar en cache
          _cache[cacheKey] = _CacheEntry(decoded, DateTime.now());
          _telemetryDown = false;
          return decoded;
        }
        throw Exception('La respuesta no es un objeto JSON');
      } else {
        throw Exception('Telemetría error ${response.statusCode}: ${response.body}');
      }
    } on TimeoutException {
      _telemetryDown = true;
      _lastDownCheck = DateTime.now();
      throw Exception('Timeout al conectar con Telemetría');
    } catch (e) {
      if (e.toString().contains('Connection refused') || 
          e.toString().contains('SocketException')) {
        _telemetryDown = true;
        _lastDownCheck = DateTime.now();
      }
      rethrow;
    }
  }
  
  /// Limpia el cache manualmente
  void clearCache() {
    _cache.clear();
  }
  
  /// Resetea el flag de Telemetría caída
  static void resetDownFlag() {
    _telemetryDown = false;
    _lastDownCheck = null;
  }

  /// Obtiene datos de trading (series para gráficas) desde Telemetría.
  Future<TradingPayloadViewModel> fetchTradingData(
    String sensorId, {
    String range = '6h',
  }) async {
    final json = await _getJson('/telemetry/sensors/$sensorId/trading?range=$range');
    return TradingPayloadViewModel.fromJson(json);
  }

  /// Obtiene métricas actuales del sensor desde Telemetría.
  Future<TelemetryMetricsViewModel> fetchSensorMetrics(String sensorId) async {
    final json = await _getJson('/telemetry/sensors/$sensorId/metrics');
    return TelemetryMetricsViewModel.fromJson(json);
  }

  /// Obtiene dashboard consolidado del sensor desde Telemetría.
  Future<SensorDashboardViewModel> fetchSensorDashboard(
    String sensorId, {
    String range = '6h',
  }) async {
    final json = await _getJson('/telemetry/sensors/$sensorId/dashboard?range=$range');
    return SensorDashboardViewModel.fromTelemetryDashboard(json);
  }

  /// Verifica si el servidor de Telemetría está disponible.
  Future<bool> isAvailable() async {
    try {
      final uri = Uri.parse('$_baseUrl/health');
      final response = await _client.get(uri).timeout(const Duration(seconds: 3));
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (_) {
      return false;
    }
  }

  /// CANAL DE TIEMPO REAL: Obtiene últimos N puntos crudos sin bucketización.
  /// 
  /// DIFERENCIA CON fetchTradingData:
  /// - Trading: bucketizado, ventanas históricas (1h, 6h, 24h)
  /// - Realtime: puntos crudos, últimos N, sin agregación
  /// 
  /// Usar para gráficas de detalle de sensor (observación en tiempo real).
  Future<RealtimePayloadViewModel> fetchRealtimeData(
    String sensorId, {
    int limit = 120,
  }) async {
    final json = await _getJson('/telemetry/sensors/$sensorId/realtime?limit=$limit');
    return RealtimePayloadViewModel.fromJson(json);
  }
}
