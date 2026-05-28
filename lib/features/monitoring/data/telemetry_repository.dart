import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../../core/config/api_config.dart';
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

class _DefaultApiClient implements IApiClient {
  final http.Client _client = http.Client();
  String get _baseUrl => ApiConfig.telemetryUrl;

  @override Future<List<SensorReading>> fetchLatestReadings(String deviceId) async => [];

  @override Future<RealtimePayloadViewModel> fetchRealtimeData(String sensorId, {int limit = 120}) async {
    final uri = Uri.parse('$_baseUrl/telemetry/sensors/$sensorId/realtime?limit=$limit');
    final res = await _client.get(uri).timeout(const Duration(seconds: 5));
    return RealtimePayloadViewModel.fromJson(jsonDecode(res.body));
  }

  @override Future<SensorDashboardViewModel> fetchSensorDashboard(String sensorId, {String range = '6h'}) async {
    final uri = Uri.parse('$_baseUrl/telemetry/sensors/$sensorId/dashboard?range=$range');
    final res = await _client.get(uri).timeout(const Duration(seconds: 5));
    return SensorDashboardViewModel.fromTelemetryDashboard(jsonDecode(res.body));
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
      _DefaultApiClient(),
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
