import '../../../core/network/api_client.dart';
import '../../monitoring/data/models/monitoring_view_models.dart';
import '../../monitoring/data/models/ml_event_view_model.dart' as ml;
import 'models/unified_alert_item.dart';

// SINGLETON: Evita crear múltiples instancias que causan memory leaks
class AlertsRepository {
  // Singleton instance
  static final AlertsRepository _instance = AlertsRepository._internal();
  
  // Factory constructor retorna siempre la misma instancia
  factory AlertsRepository([ApiClient? apiClient]) => _instance;
  
  // Constructor privado interno
  AlertsRepository._internal() : _apiClient = ApiClient();

  final ApiClient _apiClient;

  int _severityRank(String s) {
    switch (s.toLowerCase()) {
      case 'critical':
        return 0;
      case 'warning':
        return 1;
      case 'info':
      case 'notice':
        return 2;
      default:
        return 3;
    }
  }

  DateTime? _tryParseDate(String raw) {
    // Backend puede mandar dd/MM/yyyy HH:mm (monitoring) o ISO (otros endpoints).
    final iso = DateTime.tryParse(raw);
    if (iso != null) return iso;

    final parts = raw.split(' ');
    if (parts.length != 2) return null;

    final d = parts[0].split('/');
    final t = parts[1].split(':');
    if (d.length != 3 || t.length < 2) return null;

    final day = int.tryParse(d[0]);
    final month = int.tryParse(d[1]);
    final year = int.tryParse(d[2]);
    final hour = int.tryParse(t[0]);
    final minute = int.tryParse(t[1]);
    if ([day, month, year, hour, minute].any((x) => x == null)) return null;

    return DateTime(year!, month!, day!, hour!, minute!);
  }

  /// Trae SOLO eventos ML activos/ack (para panel de "Alertas importantes").
  Future<List<UnifiedAlertItem>> fetchImportantMlAlerts({int limit = 50}) async {
    final mlRaw = await _apiClient.getList('/monitoring/ml-events/active?limit=$limit');

    final mlEvents = mlRaw
        .whereType<Map>()
        .map((e) => ml.MlEventViewModel.fromJson(e.cast<String, dynamic>()))
        .toList();

    final out = <UnifiedAlertItem>[
      ...mlEvents.map(
        (e) => UnifiedAlertItem(
          source: 'ml',
          id: e.eventId,
          severity: e.eventType, // notice/warning/critical
          status: e.status,
          title: e.title,
          deviceName: e.deviceName,
          sensorId: e.sensorId,
          sensorName: e.sensorName,
          occurredAt: e.createdAt,
          message: e.message,
          value: e.predictedValue,
          eventCode: e.eventCode,
        ),
      ),
    ];

    out.sort((a, b) {
      final sa = _severityRank(a.severity);
      final sb = _severityRank(b.severity);
      if (sa != sb) return sa.compareTo(sb);

      final da = _tryParseDate(a.occurredAt);
      final db = _tryParseDate(b.occurredAt);
      if (da != null && db != null) return db.compareTo(da);

      return b.occurredAt.compareTo(a.occurredAt);
    });

    return out.take(limit).toList();
  }

  /// Trae alertas activas de umbral + eventos ML activos/ack (pantalla de Alertas).
  Future<List<UnifiedAlertItem>> fetchImportantAlerts({int limit = 50}) async {
    final alertsRaw = await _apiClient.getList('/monitoring/alerts/active');
    final mlRaw = await _apiClient.getList('/monitoring/ml-events/active?limit=$limit');

    final alerts = alertsRaw
        .whereType<Map>()
        .map((e) => ActiveAlertViewModel.fromJson(e.cast<String, dynamic>()))
        .toList();

    final mlEvents = mlRaw
        .whereType<Map>()
        .map((e) => ml.MlEventViewModel.fromJson(e.cast<String, dynamic>()))
        .toList();

    final out = <UnifiedAlertItem>[
      ...alerts.map(
        (a) => UnifiedAlertItem(
          source: 'threshold',
          id: a.alertId,
          severity: a.severity,
          status: a.status,
          title: a.thresholdName,
          deviceName: a.deviceName,
          sensorId: a.sensorId,
          sensorName: a.sensorName,
          occurredAt: a.triggeredAt,
          message: 'Valor: ${a.triggeredValue} ${a.unit}',
          value: a.triggeredValue,
        ),
      ),
      ...mlEvents.map(
        (e) => UnifiedAlertItem(
          source: 'ml',
          id: e.eventId,
          severity: e.eventType, // notice/warning/critical
          status: e.status,
          title: e.title,
          deviceName: e.deviceName,
          sensorId: e.sensorId,
          sensorName: e.sensorName,
          occurredAt: e.createdAt,
          message: e.message,
          value: e.predictedValue,
          eventCode: e.eventCode,
        ),
      ),
    ];

    out.sort((a, b) {
      final sa = _severityRank(a.severity);
      final sb = _severityRank(b.severity);
      if (sa != sb) return sa.compareTo(sb);

      final da = _tryParseDate(a.occurredAt);
      final db = _tryParseDate(b.occurredAt);
      if (da != null && db != null) return db.compareTo(da);

      return b.occurredAt.compareTo(a.occurredAt);
    });

    return out.take(limit).toList();
  }
}
