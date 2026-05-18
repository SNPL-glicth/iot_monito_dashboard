import 'dart:async';
import '../../../core/network/api_client.dart';

/// Modelo de lectura cruda
class RawReading {
  final DateTime timestamp;
  final double value;

  const RawReading({
    required this.timestamp,
    required this.value,
  });

  factory RawReading.fromJson(Map<String, dynamic> json) {
    return RawReading(
      timestamp: DateTime.parse(json['timestamp'] as String),
      value: (json['value'] as num).toDouble(),
    );
  }
}

/// Respuesta del endpoint de lecturas crudas
/// FIX: Formato ajustado al backend real /monitoring/sensors/:id/raw-readings
class RawReadingsResponse {
  final String sensorId;
  final String sensorName;
  final String deviceName;
  final String unit;
  final List<RawReading> readings;
  final int count;

  const RawReadingsResponse({
    required this.sensorId,
    required this.sensorName,
    required this.deviceName,
    required this.unit,
    required this.readings,
    required this.count,
  });

  factory RawReadingsResponse.fromJson(Map<String, dynamic> json) {
    final readingsJson = json['readings'] as List<dynamic>? ?? [];
    
    return RawReadingsResponse(
      sensorId: json['sensorId']?.toString() ?? '',
      sensorName: json['sensorName']?.toString() ?? '',
      deviceName: json['deviceName']?.toString() ?? '',
      unit: json['unit']?.toString() ?? '',
      readings: readingsJson
          .whereType<Map<String, dynamic>>()
          .map((r) => RawReading.fromJson(r))
          .toList(),
      count: json['count'] as int? ?? 0,
    );
  }
  
  /// Tiempo de inicio (primera lectura) o now si no hay datos
  DateTime get startTime => readings.isNotEmpty ? readings.first.timestamp : DateTime.now();
  
  /// Tiempo de fin (última lectura) o now si no hay datos
  DateTime get endTime => readings.isNotEmpty ? readings.last.timestamp : DateTime.now();
}

/// Repositorio para lecturas crudas de sensores
/// 
/// FASE 3.1: Solo datos raw, sin estados, sin alertas, sin ML.
/// Ideal para diagnóstico y verificar que el sensor reporta datos.
class RawReadingsRepository {
  static final RawReadingsRepository _instance = RawReadingsRepository._internal();
  final ApiClient _apiClient = ApiClient();
  
  factory RawReadingsRepository() => _instance;
  
  RawReadingsRepository._internal();

  /// Obtiene lecturas crudas de un sensor
  /// 
  /// [sensorId] - ID del sensor
  /// [limit] - Número máximo de lecturas (default 100, max 500)
  /// [hours] - Horas hacia atrás (default 1, max 24)
  Future<RawReadingsResponse> fetchRawReadings({
    required String sensorId,
    int limit = 100,
    int hours = 1,
  }) async {
    final since = DateTime.now().subtract(Duration(hours: hours)).toUtc().toIso8601String();
    final path = '/monitoring/sensors/$sensorId/raw-readings?limit=$limit&since=$since';
    
    try {
      final decoded = await _apiClient.getJson(path);
      return RawReadingsResponse.fromJson(decoded);
    } on ApiTimeoutException {
      throw Exception('Timeout al conectar con telemetría');
    } on ApiException catch (e) {
      throw Exception('Error ${e.statusCode}: ${e.body}');
    }
  }
}
