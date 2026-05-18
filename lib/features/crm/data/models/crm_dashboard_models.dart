class CrmDashboardResponse {
  CrmDashboardResponse({
    required this.from,
    required this.to,
    required this.kpis,
    required this.topDevicesByActiveAlerts,
    required this.alertQueue,
    required this.recentEvents,
  });

  final String from;
  final String to;
  final CrmDashboardKpis kpis;
  final List<CrmTopDeviceByActiveAlerts> topDevicesByActiveAlerts;
  final List<CrmAlertQueueItem> alertQueue;
  final List<CrmRecentEvent> recentEvents;

  factory CrmDashboardResponse.fromJson(Map<String, dynamic> json) {
    return CrmDashboardResponse(
      from: (json['from'] ?? '').toString(),
      to: (json['to'] ?? '').toString(),
      kpis: CrmDashboardKpis.fromJson((json['kpis'] as Map?)?.cast<String, dynamic>() ?? const {}),
      topDevicesByActiveAlerts: ((json['topDevicesByActiveAlerts'] as List?) ?? const [])
          .whereType<Map>()
          .map((e) => CrmTopDeviceByActiveAlerts.fromJson(e.cast<String, dynamic>()))
          .toList(),
      alertQueue: ((json['alertQueue'] as List?) ?? const [])
          .whereType<Map>()
          .map((e) => CrmAlertQueueItem.fromJson(e.cast<String, dynamic>()))
          .toList(),
      recentEvents: ((json['recentEvents'] as List?) ?? const [])
          .whereType<Map>()
          .map((e) => CrmRecentEvent.fromJson(e.cast<String, dynamic>()))
          .toList(),
    );
  }
}

class CrmDashboardKpis {
  CrmDashboardKpis({
    required this.devicesByStatus,
    required this.activeAlertsBySeverity,
  });

  final Map<String, int> devicesByStatus;
  final Map<String, int> activeAlertsBySeverity;

  factory CrmDashboardKpis.fromJson(Map<String, dynamic> json) {
    Map<String, int> toIntMap(dynamic raw) {
      if (raw is! Map) return {};
      final out = <String, int>{};
      raw.forEach((k, v) {
        out[k.toString()] = int.tryParse(v.toString()) ?? 0;
      });
      return out;
    }

    return CrmDashboardKpis(
      devicesByStatus: toIntMap(json['devicesByStatus']),
      activeAlertsBySeverity: toIntMap(json['activeAlertsBySeverity']),
    );
  }
}

class CrmTopDeviceByActiveAlerts {
  CrmTopDeviceByActiveAlerts({
    required this.deviceId,
    required this.deviceUuid,
    required this.deviceName,
    required this.activeAlerts,
  });

  final String deviceId;
  final String deviceUuid;
  final String deviceName;
  final int activeAlerts;

  factory CrmTopDeviceByActiveAlerts.fromJson(Map<String, dynamic> json) {
    return CrmTopDeviceByActiveAlerts(
      deviceId: (json['deviceId'] ?? '').toString(),
      deviceUuid: (json['deviceUuid'] ?? '').toString(),
      deviceName: (json['deviceName'] ?? '').toString(),
      activeAlerts: int.tryParse((json['activeAlerts'] ?? '0').toString()) ?? 0,
    );
  }
}

class CrmAlertQueueItem {
  CrmAlertQueueItem({
    required this.alertId,
    required this.deviceId,
    required this.deviceName,
    required this.sensorId,
    required this.sensorName,
    required this.severity,
    required this.status,
    required this.thresholdName,
    required this.triggeredAt,
    required this.triggeredValue,
  });

  final String alertId;
  final String deviceId;
  final String deviceName;
  final String? sensorId;
  final String? sensorName;
  final String severity;
  final String status;
  final String thresholdName;
  final String triggeredAt;
  final String triggeredValue;

  factory CrmAlertQueueItem.fromJson(Map<String, dynamic> json) {
    return CrmAlertQueueItem(
      alertId: (json['alert_id'] ?? json['alertId'] ?? '').toString(),
      deviceId: (json['device_id'] ?? json['deviceId'] ?? '').toString(),
      deviceName: (json['device_name'] ?? json['deviceName'] ?? '').toString(),
      sensorId: (json['sensor_id'] ?? json['sensorId'])?.toString(),
      sensorName: (json['sensor_name'] ?? json['sensorName'])?.toString(),
      severity: (json['severity'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      thresholdName: (json['threshold_name'] ?? json['thresholdName'] ?? '').toString(),
      triggeredAt: (json['triggered_at'] ?? json['triggeredAt'] ?? '').toString(),
      triggeredValue: (json['triggered_value'] ?? json['triggeredValue'] ?? '').toString(),
    );
  }
}

class CrmRecentEvent {
  CrmRecentEvent({
    required this.eventType,
    required this.deviceId,
    required this.deviceUuid,
    required this.deviceName,
    required this.sensorId,
    required this.occurredAt,
    required this.severity,
    required this.title,
    required this.payload,
  });

  final String eventType;
  final String deviceId;
  final String deviceUuid;
  final String deviceName;
  final String? sensorId;
  final String occurredAt;
  final String severity;
  final String title;
  final String? payload;

  factory CrmRecentEvent.fromJson(Map<String, dynamic> json) {
    return CrmRecentEvent(
      eventType: (json['eventType'] ?? json['event_type'] ?? '').toString(),
      deviceId: (json['deviceId'] ?? json['device_id'] ?? '').toString(),
      deviceUuid: (json['deviceUuid'] ?? json['device_uuid'] ?? '').toString(),
      deviceName: (json['deviceName'] ?? json['device_name'] ?? '').toString(),
      sensorId: (json['sensorId'] ?? json['sensor_id'])?.toString(),
      occurredAt: (json['occurredAt'] ?? json['occurred_at'] ?? '').toString(),
      severity: (json['severity'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      payload: json['payload']?.toString(),
    );
  }
}
