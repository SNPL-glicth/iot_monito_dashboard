/// Modelos de ML
library;

class TelemetryPredictionWouldBreachViewModel {
  TelemetryPredictionWouldBreachViewModel({required this.warning, required this.alert});

  final bool warning;
  final bool alert;

  factory TelemetryPredictionWouldBreachViewModel.fromJson(Map<String, dynamic> json) {
    bool b(dynamic x) {
      if (x is bool) return x;
      final s = (x ?? '').toString().toLowerCase();
      return s == '1' || s == 'true' || s == 'yes' || s == 'on';
    }

    return TelemetryPredictionWouldBreachViewModel(
      warning: b(json['warning']),
      alert: b(json['alert']),
    );
  }
}

class MLWarningViewModel {
  MLWarningViewModel({
    required this.predictedValue,
    required this.targetTimestamp,
    required this.confidence,
    required this.wouldBreach,
  });

  final double predictedValue;
  final String? targetTimestamp;
  final double? confidence;
  final TelemetryPredictionWouldBreachViewModel wouldBreach;

  factory MLWarningViewModel.fromJson(Map<String, dynamic> json) {
    double n(dynamic x) {
      if (x is num) return x.toDouble();
      return double.parse(x.toString().replaceAll(',', '.'));
    }

    double? nn(dynamic x) {
      if (x == null) return null;
      if (x is num) return x.toDouble();
      return double.tryParse(x.toString().replaceAll(',', '.'));
    }

    final wbRaw = (json['wouldBreach'] is Map)
        ? TelemetryPredictionWouldBreachViewModel.fromJson((json['wouldBreach'] as Map).cast<String, dynamic>())
        : TelemetryPredictionWouldBreachViewModel(warning: false, alert: false);

    return MLWarningViewModel(
      predictedValue: n(json['predictedValue']),
      targetTimestamp: json['targetTimestamp']?.toString(),
      confidence: nn(json['confidence']),
      wouldBreach: wbRaw,
    );
  }
}

class MlEventViewModel {
  MlEventViewModel({
    required this.eventId,
    required this.eventType,
    required this.eventCode,
    required this.title,
    required this.message,
    required this.createdAt,
    required this.payload,
  });

  final String eventId;
  final String eventType;
  final String eventCode;
  final String title;
  final String? message;
  final String? createdAt;
  final String? payload;

  factory MlEventViewModel.fromJson(Map<String, dynamic> json) {
    return MlEventViewModel(
      eventId: json['eventId']?.toString() ?? '',
      eventType: json['eventType']?.toString() ?? '',
      eventCode: json['eventCode']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      message: json['message']?.toString(),
      createdAt: json['createdAt']?.toString(),
      payload: json['payload']?.toString(),
    );
  }
}

class ActiveAlertViewModel {
  ActiveAlertViewModel({
    required this.alertId,
    required this.sensorId,
    required this.severity,
    required this.status,
    required this.triggeredValue,
    required this.triggeredAt,
    required this.deviceName,
    required this.deviceUuid,
    required this.sensorName,
    required this.sensorType,
    required this.unit,
    required this.thresholdName,
    required this.conditionType,
    this.thresholdValueMin,
    this.thresholdValueMax,
  });

  final String alertId;
  final String sensorId;
  final String severity;
  final String status;
  final String triggeredValue;
  final String triggeredAt;
  final String deviceName;
  final String deviceUuid;
  final String sensorName;
  final String sensorType;
  final String unit;
  final String thresholdName;
  final String conditionType;
  final String? thresholdValueMin;
  final String? thresholdValueMax;

  factory ActiveAlertViewModel.fromJson(Map<String, dynamic> json) {
    return ActiveAlertViewModel(
      alertId: json['alertId'].toString(),
      sensorId: json['sensorId']?.toString() ?? '',
      severity: (json['severity'] ?? 'warning').toString(),
      status: (json['status'] ?? 'active').toString(),
      triggeredValue: json['triggeredValue'].toString(),
      triggeredAt: json['triggeredAt'].toString(),
      deviceName: (json['deviceName'] ?? '').toString(),
      deviceUuid: (json['deviceUuid'] ?? '').toString(),
      sensorName: (json['sensorName'] ?? '').toString(),
      sensorType: (json['sensorType'] ?? '').toString(),
      unit: (json['unit'] ?? '').toString(),
      thresholdName: (json['thresholdName'] ?? 'Alerta de umbral').toString(),
      conditionType: (json['conditionType'] ?? 'unknown').toString(),
      thresholdValueMin: json['thresholdValueMin']?.toString(),
      thresholdValueMax: json['thresholdValueMax']?.toString(),
    );
  }
}
