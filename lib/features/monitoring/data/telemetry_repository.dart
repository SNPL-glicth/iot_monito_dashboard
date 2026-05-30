import 'dart:async';

import 'dart:developer' as dev;

import '../../../core/config/api_config.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_exceptions.dart';
import '../../../core/resilience/circuit_breaker.dart';
import '../../../core/resilience/circuit_breaker_config.dart';
import 'local/sensor_reading_cache.dart';
import 'models/monitoring_view_models.dart';

enum TelemetrySourceEvent { live, cached }

abstract class IApiClient {
  Future<List<SensorReading>> fetchLatestReadings(String deviceId);
  Future<RealtimePayloadViewModel> fetchRealtimeData(String sensorId, {int limit});
  Future<SensorDashboardViewModel> fetchSensorDashboard(String sensorId, {String range});
}

class _TelemetryApiClient implements IApiClient {
  final ApiClient _api = ApiClient();

  @override Future<List<SensorReading>> fetchLatestReadings(String deviceId) async => [];

  @override Future<RealtimePayloadViewModel> fetchRealtimeData(String sensorId, {int limit = 120}) async {
    final path = '/telemetry/sensors/$sensorId/realtime?limit=$limit';
    try {
      final data = await _api.getJson(path, baseUrl: ApiConfig.telemetryUrl);
      return RealtimePayloadViewModel.fromJson(data);
    } on ApiException catch (e) {
      _handleTelemetryError('GET', path, e);
      rethrow;
    }
  }

  @override Future<SensorDashboardViewModel> fetchSensorDashboard(String sensorId, {String range = '6h'}) async {
    final path = '/telemetry/sensors/$sensorId/dashboard?range=$range';
    try {
      final data = await _api.getJson(path, baseUrl: ApiConfig.telemetryUrl);
      return SensorDashboardViewModel.fromTelemetryDashboard(data);
    } on ApiException catch (e) {
      _handleTelemetryError('GET', path, e);
      rethrow;
    }
  }

  void _handleTelemetryError(String method, String path, ApiException e) {
    final bodyPreview = e.body.length > 200 ? '${e.body.substring(0, 200)}...' : e.body;
    dev.log('[Telemetry] $method $path → ${e.statusCode}: $bodyPreview');
    if (e.statusCode == 401) {
      throw UnauthorizedException(path);
    }
    if (e.statusCode >= 500) {
      throw ServerException(path, e.statusCode, e.body);
    }
  }
}

class _NoOpCache implements ISensorReadingCache {
  @override Future<void> saveReadings(List<SensorReading> r) async {}
  @override Future<List<SensorReading>> getLatestReadings(String d) async => [];
  @override Future<SensorReading?> getLastKnownReading(String s) async => null;
  @override Future<void> clearOlderThan(Duration a) async {}
}

class TelemetryRepository {
  TelemetryRepository.withDependencies(this._apiClient, this._cache, this._circuitBreaker);

  static TelemetryRepository? _instance;
  factory TelemetryRepository() {
    _instance ??= TelemetryRepository.withDependencies(
      _TelemetryApiClient(),
      _NoOpCache(),
      CircuitBreaker<List<SensorReading>>(const CircuitBreakerConfig.telemetry()),
    );
    return _instance!;
  }

  final IApiClient _apiClient;
  final ISensorReadingCache _cache;
  final CircuitBreaker<List<SensorReading>> _circuitBreaker;

  final _sourceController = StreamController<TelemetrySourceEvent>.broadcast();
  Stream<TelemetrySourceEvent> get dataSource => _sourceController.stream;

  Future<List<SensorReading>> getLatestReadings(String deviceId) async {
    try {
      final readings = await _circuitBreaker.execute(
        () => _apiClient.fetchLatestReadings(deviceId),
      );
      await _cache.saveReadings(readings);
      _sourceController.add(TelemetrySourceEvent.live);
      return readings;
    } on CircuitOpenException {
      return _fallbackToCache(deviceId);
    } catch (e) {
      return _fallbackToCache(deviceId);
    }
  }

  Future<RealtimePayloadViewModel> fetchRealtimeData(String sensorId, {int limit = 120}) =>
    _apiClient.fetchRealtimeData(sensorId, limit: limit);

  Future<SensorDashboardViewModel> fetchSensorDashboard(String sensorId, {String range = '6h'}) =>
    _apiClient.fetchSensorDashboard(sensorId, range: range);

  Future<List<SensorReading>> _fallbackToCache(String deviceId) async {
    final cached = await _cache.getLatestReadings(deviceId);
    _sourceController.add(TelemetrySourceEvent.cached);
    return cached;
  }

  void dispose() {
    _sourceController.close();
    _circuitBreaker.dispose();
  }
}
