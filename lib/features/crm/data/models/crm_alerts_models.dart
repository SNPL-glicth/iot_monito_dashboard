/// FIX ARQUITECTÓNICO: Punto de datos en el snapshot inmutable
class SnapshotDataPoint {
  SnapshotDataPoint({
    required this.timestamp,
    required this.value,
    required this.state,
  });

  final String timestamp;
  final double value;
  final String state; // NORMAL, WARNING, ALERT

  factory SnapshotDataPoint.fromJson(Map<String, dynamic> json) {
    return SnapshotDataPoint(
      timestamp: json['timestamp']?.toString() ?? '',
      value: (json['value'] as num?)?.toDouble() ?? 0.0,
      state: json['state']?.toString() ?? 'NORMAL',
    );
  }
}

/// FIX ARQUITECTÓNICO: Umbrales congelados en el snapshot
class SnapshotThresholds {
  SnapshotThresholds({
    this.warningMin,
    this.warningMax,
    this.alertMin,
    this.alertMax,
  });

  final double? warningMin;
  final double? warningMax;
  final double? alertMin;
  final double? alertMax;

  factory SnapshotThresholds.fromJson(Map<String, dynamic>? json) {
    if (json == null) return SnapshotThresholds();
    return SnapshotThresholds(
      warningMin: (json['warningMin'] as num?)?.toDouble(),
      warningMax: (json['warningMax'] as num?)?.toDouble(),
      alertMin: (json['alertMin'] as num?)?.toDouble(),
      alertMax: (json['alertMax'] as num?)?.toDouble(),
    );
  }
}

/// FIX ARQUITECTÓNICO: Snapshot INMUTABLE de una alerta.
/// 
/// Este snapshot contiene todos los datos congelados al momento del trigger:
/// - Serie temporal
/// - Umbrales vigentes
/// - Metadatos del sensor/dispositivo
/// 
/// NUNCA cambia, independientemente del tiempo transcurrido.
class AlertSnapshotResponse {
  AlertSnapshotResponse({
    required this.alertId,
    required this.sensorId,
    required this.deviceId,
    required this.sensorName,
    required this.deviceName,
    required this.unit,
    required this.sensorType,
    required this.triggeredAt,
    required this.triggeredValue,
    required this.severity,
    required this.thresholds,
    required this.series,
    required this.contextFrom,
    required this.contextTo,
    required this.pointCount,
    required this.createdAt,
  });

  final int alertId;
  final String sensorId;
  final String deviceId;
  final String sensorName;
  final String deviceName;
  final String? unit;
  final String? sensorType;
  final String triggeredAt;
  final double triggeredValue;
  final String severity;
  final SnapshotThresholds thresholds;
  final List<SnapshotDataPoint> series;
  final String contextFrom;
  final String contextTo;
  final int pointCount;
  final String createdAt;

  factory AlertSnapshotResponse.fromJson(Map<String, dynamic> json) {
    final seriesList = (json['series'] as List<dynamic>?)
        ?.map((e) => SnapshotDataPoint.fromJson(e as Map<String, dynamic>))
        .toList() ?? [];

    return AlertSnapshotResponse(
      alertId: (json['alertId'] as num?)?.toInt() ?? 0,
      sensorId: json['sensorId']?.toString() ?? '',
      deviceId: json['deviceId']?.toString() ?? '',
      sensorName: json['sensorName']?.toString() ?? '',
      deviceName: json['deviceName']?.toString() ?? '',
      unit: json['unit']?.toString(),
      sensorType: json['sensorType']?.toString(),
      triggeredAt: json['triggeredAt']?.toString() ?? '',
      triggeredValue: (json['triggeredValue'] as num?)?.toDouble() ?? 0.0,
      severity: json['severity']?.toString() ?? '',
      thresholds: SnapshotThresholds.fromJson(
        json['thresholds'] as Map<String, dynamic>?,
      ),
      series: seriesList,
      contextFrom: json['contextFrom']?.toString() ?? '',
      contextTo: json['contextTo']?.toString() ?? '',
      pointCount: (json['pointCount'] as num?)?.toInt() ?? 0,
      createdAt: json['createdAt']?.toString() ?? '',
    );
  }
}

class CrmAlertHistoryItem {
  CrmAlertHistoryItem({
    required this.alertId,
    required this.deviceId,
    required this.deviceUuid,
    required this.deviceName,
    required this.sensorId,
    required this.sensorName,
    required this.sensorType,
    required this.unit,
    required this.thresholdId,
    required this.thresholdName,
    required this.conditionType,
    required this.thresholdValueMin,
    required this.thresholdValueMax,
    required this.severity,
    required this.status,
    required this.triggeredValue,
    required this.triggeredAt,
    required this.acknowledgedAt,
    required this.acknowledgedByUsername,
    required this.resolvedAt,
    required this.resolvedByUsername,
  });

  final String alertId;
  final String deviceId;
  final String deviceUuid;
  final String deviceName;
  final String? sensorId;
  final String? sensorName;
  final String? sensorType;
  final String? unit;

  final String? thresholdId;
  final String? thresholdName;
  final String? conditionType;
  final String? thresholdValueMin;
  final String? thresholdValueMax;

  final String severity;
  final String status;
  final String triggeredValue;
  final String triggeredAt;

  final String? acknowledgedAt;
  final String? acknowledgedByUsername;
  final String? resolvedAt;
  final String? resolvedByUsername;

  factory CrmAlertHistoryItem.fromJson(Map<String, dynamic> json) {
    // soporta snake_case (views) y camelCase (DTOs)
    T? pick<T>(List<String> keys) {
      for (final k in keys) {
        if (json.containsKey(k)) return json[k] as T?;
      }
      return null;
    }

    String s(dynamic v) => (v ?? '').toString();

    return CrmAlertHistoryItem(
      alertId: s(pick(['alertId', 'alert_id'])),
      deviceId: s(pick(['deviceId', 'device_id'])),
      deviceUuid: s(pick(['deviceUuid', 'device_uuid'])),
      deviceName: s(pick(['deviceName', 'device_name'])),
      sensorId: pick(['sensorId', 'sensor_id'])?.toString(),
      sensorName: pick(['sensorName', 'sensor_name'])?.toString(),
      sensorType: pick(['sensorType', 'sensor_type'])?.toString(),
      unit: pick(['unit'])?.toString(),
      thresholdId: pick(['thresholdId', 'threshold_id'])?.toString(),
      thresholdName: pick(['thresholdName', 'threshold_name'])?.toString(),
      conditionType: pick(['conditionType', 'condition_type'])?.toString(),
      thresholdValueMin: pick(['thresholdValueMin', 'threshold_value_min'])?.toString(),
      thresholdValueMax: pick(['thresholdValueMax', 'threshold_value_max'])?.toString(),
      severity: s(pick(['severity'])),
      status: s(pick(['status'])),
      triggeredValue: s(pick(['triggeredValue', 'triggered_value'])),
      triggeredAt: s(pick(['triggeredAt', 'triggered_at'])),
      acknowledgedAt: pick(['acknowledgedAt', 'acknowledged_at'])?.toString(),
      acknowledgedByUsername: pick(['acknowledgedByUsername', 'acknowledged_by_username'])?.toString(),
      resolvedAt: pick(['resolvedAt', 'resolved_at'])?.toString(),
      resolvedByUsername: pick(['resolvedByUsername', 'resolved_by_username'])?.toString(),
    );
  }
}
