import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/config/api_config.dart';

/// Métricas del sistema (CPU, RAM, etc.)
class SystemMetrics {
  final String timestamp;
  final double cpuUsagePercent;
  final int cpuCores;
  final String cpuModel;
  final int memoryTotalMB;
  final int memoryUsedMB;
  final int memoryFreeMB;
  final double memoryUsagePercent;
  final int uptimeSystem;
  final int uptimeProcess;
  final String platformType;
  final String hostname;

  const SystemMetrics({
    required this.timestamp,
    required this.cpuUsagePercent,
    required this.cpuCores,
    required this.cpuModel,
    required this.memoryTotalMB,
    required this.memoryUsedMB,
    required this.memoryFreeMB,
    required this.memoryUsagePercent,
    required this.uptimeSystem,
    required this.uptimeProcess,
    required this.platformType,
    required this.hostname,
  });

  factory SystemMetrics.fromJson(Map<String, dynamic> json) {
    final cpu = json['cpu'] as Map<String, dynamic>? ?? {};
    final memory = json['memory'] as Map<String, dynamic>? ?? {};
    final uptime = json['uptime'] as Map<String, dynamic>? ?? {};
    final platform = json['platform'] as Map<String, dynamic>? ?? {};

    return SystemMetrics(
      timestamp: json['timestamp']?.toString() ?? '',
      cpuUsagePercent: (cpu['usagePercent'] as num?)?.toDouble() ?? 0,
      cpuCores: (cpu['cores'] as num?)?.toInt() ?? 0,
      cpuModel: cpu['model']?.toString() ?? 'Unknown',
      memoryTotalMB: (memory['totalMB'] as num?)?.toInt() ?? 0,
      memoryUsedMB: (memory['usedMB'] as num?)?.toInt() ?? 0,
      memoryFreeMB: (memory['freeMB'] as num?)?.toInt() ?? 0,
      memoryUsagePercent: (memory['usagePercent'] as num?)?.toDouble() ?? 0,
      uptimeSystem: (uptime['system'] as num?)?.toInt() ?? 0,
      uptimeProcess: (uptime['process'] as num?)?.toInt() ?? 0,
      platformType: platform['type']?.toString() ?? '',
      hostname: platform['hostname']?.toString() ?? '',
    );
  }
}

/// Métricas de base de datos
class DatabaseMetrics {
  final String timestamp;
  final int sensorsTotal;
  final int sensorsActive;
  final int readingsLast24h;
  final int readingsLastHour;
  final int alertsActive;
  final int alertsLast24h;
  final int mlEventsActive;
  final int mlEventsLast24h;
  final int predictionsTotal;
  final int predictionsLast24h;

  const DatabaseMetrics({
    required this.timestamp,
    required this.sensorsTotal,
    required this.sensorsActive,
    required this.readingsLast24h,
    required this.readingsLastHour,
    required this.alertsActive,
    required this.alertsLast24h,
    required this.mlEventsActive,
    required this.mlEventsLast24h,
    required this.predictionsTotal,
    required this.predictionsLast24h,
  });

  factory DatabaseMetrics.fromJson(Map<String, dynamic> json) {
    final sensors = json['sensors'] as Map<String, dynamic>? ?? {};
    final readings = json['readings'] as Map<String, dynamic>? ?? {};
    final alerts = json['alerts'] as Map<String, dynamic>? ?? {};
    final mlEvents = json['mlEvents'] as Map<String, dynamic>? ?? {};
    final predictions = json['predictions'] as Map<String, dynamic>? ?? {};

    return DatabaseMetrics(
      timestamp: json['timestamp']?.toString() ?? '',
      sensorsTotal: (sensors['total'] as num?)?.toInt() ?? 0,
      sensorsActive: (sensors['active'] as num?)?.toInt() ?? 0,
      readingsLast24h: (readings['last24h'] as num?)?.toInt() ?? 0,
      readingsLastHour: (readings['lastHour'] as num?)?.toInt() ?? 0,
      alertsActive: (alerts['active'] as num?)?.toInt() ?? 0,
      alertsLast24h: (alerts['last24h'] as num?)?.toInt() ?? 0,
      mlEventsActive: (mlEvents['active'] as num?)?.toInt() ?? 0,
      mlEventsLast24h: (mlEvents['last24h'] as num?)?.toInt() ?? 0,
      predictionsTotal: (predictions['total'] as num?)?.toInt() ?? 0,
      predictionsLast24h: (predictions['last24h'] as num?)?.toInt() ?? 0,
    );
  }
}

/// Métricas de ingesta
class IngestMetrics {
  final String timestamp;
  final double eventsPerSecond;
  final int readingsLast5min;
  final int alertsLast5min;
  final int mlEventsLast5min;

  const IngestMetrics({
    required this.timestamp,
    required this.eventsPerSecond,
    required this.readingsLast5min,
    required this.alertsLast5min,
    required this.mlEventsLast5min,
  });

  factory IngestMetrics.fromJson(Map<String, dynamic> json) {
    return IngestMetrics(
      timestamp: json['timestamp']?.toString() ?? '',
      eventsPerSecond: (json['eventsPerSecond'] as num?)?.toDouble() ?? 0,
      readingsLast5min: (json['readingsLast5min'] as num?)?.toInt() ?? 0,
      alertsLast5min: (json['alertsLast5min'] as num?)?.toInt() ?? 0,
      mlEventsLast5min: (json['mlEventsLast5min'] as num?)?.toInt() ?? 0,
    );
  }
}

/// Todas las métricas consolidadas
class AllMetrics {
  final SystemMetrics system;
  final DatabaseMetrics database;
  final IngestMetrics ingest;

  const AllMetrics({
    required this.system,
    required this.database,
    required this.ingest,
  });

  factory AllMetrics.fromJson(Map<String, dynamic> json) {
    return AllMetrics(
      system: SystemMetrics.fromJson(json['system'] as Map<String, dynamic>? ?? {}),
      database: DatabaseMetrics.fromJson(json['database'] as Map<String, dynamic>? ?? {}),
      ingest: IngestMetrics.fromJson(json['ingest'] as Map<String, dynamic>? ?? {}),
    );
  }
}

/// Repositorio para métricas del servidor de telemetría
class MetricsRepository {
  static final MetricsRepository _instance = MetricsRepository._internal();
  static http.Client? _sharedClient;
  
  factory MetricsRepository() => _instance;
  
  MetricsRepository._internal();

  http.Client get _client {
    _sharedClient ??= http.Client();
    return _sharedClient!;
  }

  String get _baseUrl => ApiConfig.telemetryUrl;

  /// Headers para métricas - NO requiere auth (endpoints públicos)
  Map<String, String> _defaultHeaders() {
    return <String, String>{
      'Content-Type': 'application/json',
    };
  }

  Future<Map<String, dynamic>> _getJson(String path) async {
    final uri = Uri.parse('$_baseUrl$path');
    try {
      final response = await _client.get(
        uri,
        headers: _defaultHeaders(),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          return decoded;
        }
        throw Exception('La respuesta no es un objeto JSON');
      } else {
        throw Exception('Error ${response.statusCode}: ${response.body}');
      }
    } on TimeoutException {
      throw Exception('Timeout al conectar con telemetría');
    }
  }

  Future<AllMetrics> fetchAllMetrics() async {
    final json = await _getJson('/telemetry/system/all');
    return AllMetrics.fromJson(json);
  }

  Future<SystemMetrics> fetchSystemMetrics() async {
    final json = await _getJson('/telemetry/system');
    // El endpoint /telemetry/system tiene formato diferente, adaptar
    return SystemMetrics(
      timestamp: DateTime.now().toIso8601String(),
      cpuUsagePercent: (json['cpu'] as num?)?.toDouble() ?? 0,
      cpuCores: 0,
      cpuModel: 'Unknown',
      memoryTotalMB: 0,
      memoryUsedMB: (json['ram'] as num?)?.toInt() ?? 0,
      memoryFreeMB: 0,
      memoryUsagePercent: 0,
      uptimeSystem: 0,
      uptimeProcess: 0,
      platformType: '',
      hostname: '',
    );
  }

  Future<DatabaseMetrics> fetchDatabaseMetrics() async {
    final json = await _getJson('/telemetry/system/database');
    return DatabaseMetrics.fromJson(json);
  }

  Future<IngestMetrics> fetchIngestMetrics() async {
    final json = await _getJson('/telemetry/system/ingest');
    return IngestMetrics.fromJson(json);
  }
}
