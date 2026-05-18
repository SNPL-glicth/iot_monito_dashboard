/// Modelos de dispositivos CRM
library;

class CrmDeviceSummary {
  CrmDeviceSummary({
    required this.deviceId,
    required this.deviceUuid,
    required this.deviceName,
    required this.deviceType,
    required this.status,
    required this.lastConnection,
    required this.sensorCount,
    required this.activeAlerts,
    required this.lastAlertAt,
  });

  final String deviceId;
  final String deviceUuid;
  final String deviceName;
  final String deviceType;
  final String status;
  final String? lastConnection;
  final int sensorCount;
  final int activeAlerts;
  final String? lastAlertAt;

  factory CrmDeviceSummary.fromJson(Map<String, dynamic> json) {
    return CrmDeviceSummary(
      deviceId: (json['deviceId'] ?? json['device_id'] ?? '').toString(),
      deviceUuid: (json['deviceUuid'] ?? json['device_uuid'] ?? '').toString(),
      deviceName: (json['deviceName'] ?? json['device_name'] ?? '').toString(),
      deviceType: (json['deviceType'] ?? json['device_type'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      lastConnection: (json['lastConnection'] ?? json['last_connection'])?.toString(),
      sensorCount: int.tryParse((json['sensorCount'] ?? json['sensor_count'] ?? '0').toString()) ?? 0,
      activeAlerts: int.tryParse((json['activeAlerts'] ?? json['active_alerts'] ?? '0').toString()) ?? 0,
      lastAlertAt: (json['lastAlertAt'] ?? json['last_alert_at'])?.toString(),
    );
  }
}

class CrmLatestReading {
  CrmLatestReading({
    required this.sensorId,
    required this.sensorName,
    required this.sensorType,
    required this.unit,
    required this.latestValue,
    required this.latestTimestamp,
  });

  final String sensorId;
  final String sensorName;
  final String sensorType;
  final String unit;
  final num? latestValue;
  final String? latestTimestamp;

  factory CrmLatestReading.fromJson(Map<String, dynamic> json) {
    return CrmLatestReading(
      sensorId: (json['sensorId'] ?? json['sensor_id'] ?? '').toString(),
      sensorName: (json['sensorName'] ?? json['sensor_name'] ?? '').toString(),
      sensorType: (json['sensorType'] ?? json['sensor_type'] ?? '').toString(),
      unit: (json['unit'] ?? '').toString(),
      latestValue: (json['latestValue'] ?? json['latest_value']) is num
          ? (json['latestValue'] ?? json['latest_value']) as num
          : num.tryParse((json['latestValue'] ?? json['latest_value'] ?? '').toString()),
      latestTimestamp: (json['latestTimestamp'] ?? json['latest_timestamp'])?.toString(),
    );
  }
}

class CrmDeviceSensorSeries {
  CrmDeviceSensorSeries({
    required this.id,
    required this.name,
    required this.sensorType,
    required this.unit,
    required this.isActive,
    required this.points,
  });

  final String id;
  final String name;
  final String sensorType;
  final String unit;
  final bool? isActive;
  final List<CrmSeriesPoint> points;

  factory CrmDeviceSensorSeries.fromJson(Map<String, dynamic> json) {
    return CrmDeviceSensorSeries(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      sensorType: (json['sensorType'] ?? json['sensor_type'] ?? '').toString(),
      unit: (json['unit'] ?? '').toString(),
      isActive: (json['isActive'] ?? json['is_active']) is bool
          ? (json['isActive'] ?? json['is_active']) as bool
          : null,
      points: ((json['points'] as List?) ?? const [])
          .whereType<Map>()
          .map((e) => CrmSeriesPoint.fromJson(e.cast<String, dynamic>()))
          .toList(),
    );
  }
}

class CrmSeriesPoint {
  CrmSeriesPoint({
    required this.ts,
    required this.avg,
    required this.min,
    required this.max,
    required this.last,
    required this.samples,
  });

  final String ts;
  final num avg;
  final num min;
  final num max;
  final num? last;
  final int samples;

  factory CrmSeriesPoint.fromJson(Map<String, dynamic> json) {
    num toNum(dynamic v) => v is num ? v : (num.tryParse(v?.toString() ?? '') ?? 0);

    return CrmSeriesPoint(
      ts: (json['ts'] ?? '').toString(),
      avg: toNum(json['avg']),
      min: toNum(json['min']),
      max: toNum(json['max']),
      last: json['last'] == null ? null : toNum(json['last']),
      samples: int.tryParse((json['samples'] ?? '0').toString()) ?? 0,
    );
  }
}

class CrmDeviceProfileFullResponse {
  CrmDeviceProfileFullResponse({
    required this.deviceId,
    required this.summary,
    required this.from,
    required this.to,
    required this.bucket,
    required this.sensors,
    required this.latestReadings,
    required this.activeAlerts,
    required this.kpisAlerts24h,
    required this.kpisAlerts7d,
  });

  final String deviceId;
  final CrmDeviceSummary summary;
  final String from;
  final String to;
  final String bucket;
  final List<CrmDeviceSensorSeries> sensors;
  final List<CrmLatestReading> latestReadings;
  final List<Map<String, dynamic>> activeAlerts;
  final Map<String, int> kpisAlerts24h;
  final Map<String, int> kpisAlerts7d;

  factory CrmDeviceProfileFullResponse.fromJson(Map<String, dynamic> json) {
    Map<String, int> toIntMap(dynamic raw) {
      if (raw is! Map) return {};
      final out = <String, int>{};
      raw.forEach((k, v) {
        out[k.toString()] = int.tryParse(v.toString()) ?? 0;
      });
      return out;
    }

    final kpis = (json['kpis'] as Map?)?.cast<String, dynamic>() ?? const {};

    return CrmDeviceProfileFullResponse(
      deviceId: (json['deviceId'] ?? '').toString(),
      summary: CrmDeviceSummary.fromJson((json['summary'] as Map).cast<String, dynamic>()),
      from: (json['from'] ?? '').toString(),
      to: (json['to'] ?? '').toString(),
      bucket: (json['bucket'] ?? '').toString(),
      sensors: ((json['sensors'] as List?) ?? const [])
          .whereType<Map>()
          .map((e) => CrmDeviceSensorSeries.fromJson(e.cast<String, dynamic>()))
          .toList(),
      latestReadings: ((json['latestReadings'] as List?) ?? const [])
          .whereType<Map>()
          .map((e) => CrmLatestReading.fromJson(e.cast<String, dynamic>()))
          .toList(),
      activeAlerts: ((json['activeAlerts'] as List?) ?? const [])
          .whereType<Map>()
          .map((e) => e.cast<String, dynamic>())
          .toList(),
      kpisAlerts24h: toIntMap(kpis['alerts24h']),
      kpisAlerts7d: toIntMap(kpis['alerts7d']),
    );
  }
}
