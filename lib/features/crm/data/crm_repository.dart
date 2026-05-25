import '../../../core/network/api_client.dart';
import 'models/crm_alerts_models.dart';
import 'models/crm_dashboard_models.dart';
import 'models/crm_devices_models.dart';

// SINGLETON: Evita crear múltiples instancias que causan memory leaks
class CrmRepository {
  // Singleton instance
  static final CrmRepository _instance = CrmRepository._internal();
  
  // Factory constructor retorna siempre la misma instancia
  factory CrmRepository([ApiClient? apiClient]) => _instance;
  
  // Constructor privado interno
  CrmRepository._internal() : _apiClient = ApiClient();

  final ApiClient _apiClient;

  Future<CrmDashboardResponse> fetchDashboard({
    String? from,
    String? to,
    int? alertsLimit,
    int? eventsLimit,
    int? topDevicesLimit,
  }) async {
    final qp = <String, String>{};
    if (from != null && from.isNotEmpty) qp['from'] = from;
    if (to != null && to.isNotEmpty) qp['to'] = to;
    if (alertsLimit != null) qp['alertsLimit'] = alertsLimit.toString();
    if (eventsLimit != null) qp['eventsLimit'] = eventsLimit.toString();
    if (topDevicesLimit != null) qp['topDevicesLimit'] = topDevicesLimit.toString();

    final path = qp.isEmpty
        ? '/crm/dashboard'
        : '/crm/dashboard?${Uri(queryParameters: qp).query}';

    final json = await _apiClient.getJson(path);
    return CrmDashboardResponse.fromJson(json);
  }

  Future<CrmPagedResponse<CrmDeviceSummary>> listDevices({
    String? q,
    String? status,
    String? type,
    int page = 1,
    int pageSize = 20,
  }) async {
    final qp = <String, String>{
      'page': page.toString(),
      'pageSize': pageSize.toString(),
    };
    if (q != null && q.isNotEmpty) qp['q'] = q;
    if (status != null && status.isNotEmpty) qp['status'] = status;
    if (type != null && type.isNotEmpty) qp['type'] = type;

    final path = '/crm/devices?${Uri(queryParameters: qp).query}';
    final json = await _apiClient.getJson(path);

    return CrmPagedResponse.fromJson(
      json,
      itemFromJson: (x) => CrmDeviceSummary.fromJson(x),
    );
  }

  Future<CrmDeviceProfileFullResponse> getDeviceProfileFull({
    required int deviceId,
    String? from,
    String? to,
    String? bucket,
    int maxPoints = 400,
    String? sensorIds,
    int maxSensors = 6,
    int alertsLimit = 50,
  }) async {
    final qp = <String, String>{
      'maxPoints': maxPoints.toString(),
      'maxSensors': maxSensors.toString(),
      'alertsLimit': alertsLimit.toString(),
    };
    if (from != null && from.isNotEmpty) qp['from'] = from;
    if (to != null && to.isNotEmpty) qp['to'] = to;
    if (bucket != null && bucket.isNotEmpty) qp['bucket'] = bucket;
    if (sensorIds != null && sensorIds.isNotEmpty) qp['sensorIds'] = sensorIds;

    final path = '/crm/devices/$deviceId/profile-full?${Uri(queryParameters: qp).query}';
    final json = await _apiClient.getJson(path);
    return CrmDeviceProfileFullResponse.fromJson(json);
  }

  Future<CrmPagedResponse<CrmAlertHistoryItem>> listAlerts({
    String? status,
    String? severity,
    String? deviceId,
    String? sensorId,
    String? from,
    String? to,
    int page = 1,
    int pageSize = 50,
  }) async {
    final qp = <String, String>{
      'page': page.toString(),
      'pageSize': pageSize.toString(),
    };

    if (status != null && status.isNotEmpty) qp['status'] = status;
    if (severity != null && severity.isNotEmpty) qp['severity'] = severity;
    if (deviceId != null && deviceId.isNotEmpty) qp['deviceId'] = deviceId;
    if (sensorId != null && sensorId.isNotEmpty) qp['sensorId'] = sensorId;
    if (from != null && from.isNotEmpty) qp['from'] = from;
    if (to != null && to.isNotEmpty) qp['to'] = to;

    final path = '/crm/alerts?${Uri(queryParameters: qp).query}';
    final json = await _apiClient.getJson(path);

    return CrmPagedResponse.fromJson(
      json,
      itemFromJson: (x) => CrmAlertHistoryItem.fromJson(x),
    );
  }

  /// Obtiene una alerta específica por ID.
  /// Intenta endpoint directo; si falla, fallback a listAlerts paginado.
  Future<CrmAlertHistoryItem?> getAlertById(String alertId) async {
    try {
      final json = await _apiClient.getJson('/crm/alerts/$alertId');
      return CrmAlertHistoryItem.fromJson(json);
    } catch (_) {
      // Fallback: buscar en primera página paginada
    }
    final response = await listAlerts(page: 1, pageSize: 20);
    return response.items.where((a) => a.alertId == alertId).firstOrNull;
  }

  /// Marca una alerta como atendida (acknowledged)
  /// Requiere rol admin u operator
  Future<void> acknowledgeAlert(int alertId) async {
    await _apiClient.postJson('/crm/alerts/$alertId/ack', {});
  }

  /// Marca una alerta como resuelta
  /// Requiere rol admin u operator
  Future<void> resolveAlert(int alertId) async {
    await _apiClient.postJson('/crm/alerts/$alertId/resolve', {});
  }

  /// FIX ARQUITECTÓNICO: Obtener snapshot INMUTABLE de la alerta.
  /// 
  /// El snapshot contiene datos congelados al momento del trigger:
  /// - Serie temporal
  /// - Umbrales vigentes
  /// - Metadatos
  /// 
  /// Este snapshot NUNCA cambia, independientemente del tiempo transcurrido.
  Future<AlertSnapshotResponse> getAlertSnapshot(int alertId) async {
    final json = await _apiClient.getJson('/crm/alerts/$alertId/snapshot');
    return AlertSnapshotResponse.fromJson(json);
  }
}
