import '../../../../core/network/api_client.dart';
import '../models/monitoring_view_models.dart';

/// Operaciones de lecturas de sensores
class MonitoringReadingsOps {
  final ApiClient _apiClient;

  MonitoringReadingsOps(this._apiClient);

  // Cache en memoria para lecturas históricas: clave = sensorId|from|to
  final Map<String, List<SensorReadingViewModel>> _readingsCache = {};

  String _cacheKey(String sensorId, DateTime? from, DateTime? to) {
    final fromStr = from?.toUtc().toIso8601String() ?? 'null';
    final toStr = to?.toUtc().toIso8601String() ?? 'null';
    return '$sensorId|$fromStr|$toStr';
  }

  Future<List<LatestSensorReadingViewModel>> fetchLatestSensorReadings() async {
    final data = await _apiClient.getList('/monitoring/readings/latest');
    return data
        .map((e) => LatestSensorReadingViewModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<SensorReadingViewModel>> fetchSensorReadings(
    String sensorId, {
    int limit = 50,
    DateTime? from,
    DateTime? to,
  }) async {
    final key = _cacheKey(sensorId, from, to);
    final cached = _readingsCache[key];
    if (cached != null) {
      return cached;
    }

    var url = '/monitoring/sensors/$sensorId/readings?limit=$limit';
    if (from != null) {
      url += '&date_from=${from.toUtc().toIso8601String()}';
    }
    if (to != null) {
      url += '&date_to=${to.toUtc().toIso8601String()}';
    }

    final data = await _apiClient.getList(url);
    final results = data
        .map((e) => SensorReadingViewModel.fromJson(e as Map<String, dynamic>))
        .toList();

    _readingsCache[key] = results;
    return results;
  }

  /// Obtener datos CRUDOS del sensor sin agregación
  Future<RawSensorReadingsViewModel> fetchRawSensorReadings(
    String sensorId, {
    int limit = 500,
    DateTime? since,
  }) async {
    String url = '/monitoring/sensors/$sensorId/raw-readings?limit=$limit';
    if (since != null) {
      url += '&since=${since.toUtc().toIso8601String()}';
    }
    
    final json = await _apiClient.getJson(url);
    return RawSensorReadingsViewModel.fromJson(json);
  }

  /// Obtener datos agregados por ventana temporal
  Future<AggregatedSensorReadingsViewModel> fetchAggregatedSensorReadings(
    String sensorId, {
    String range = '6h',
  }) async {
    final json = await _apiClient.getJson(
      '/monitoring/sensors/$sensorId/aggregated?range=$range',
    );
    return AggregatedSensorReadingsViewModel.fromJson(json);
  }

  /// Obtener lecturas históricas por rango de fechas ABSOLUTAS
  Future<HistoricalReadingsViewModel> fetchHistoricalReadings(
    String sensorId, {
    required DateTime from,
    required DateTime to,
    int limit = 500,
  }) async {
    final fromStr = from.toUtc().toIso8601String();
    final toStr = to.toUtc().toIso8601String();
    
    final json = await _apiClient.getJson(
      '/monitoring/sensors/$sensorId/historical-readings?from=$fromStr&to=$toStr&limit=$limit',
    );
    return HistoricalReadingsViewModel.fromJson(json);
  }
}
