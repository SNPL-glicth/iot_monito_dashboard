/// Modelos de snapshots de alertas
library;

/// Punto de datos en un snapshot de alerta
class AlertSnapshotPoint {
  const AlertSnapshotPoint({
    required this.timestamp,
    required this.value,
    this.isAlertTrigger = false,
    this.state = 'NORMAL',
  });

  final DateTime timestamp;
  final double value;
  final bool isAlertTrigger; // true si este punto disparó la alerta
  final String state;

  Map<String, dynamic> toJson() => {
    'timestamp': timestamp.toIso8601String(),
    'value': value,
    'isAlertTrigger': isAlertTrigger,
    'state': state,
  };

  factory AlertSnapshotPoint.fromJson(Map<String, dynamic> json) {
    return AlertSnapshotPoint(
      timestamp: DateTime.parse(json['timestamp'] as String),
      value: (json['value'] as num).toDouble(),
      isAlertTrigger: json['isAlertTrigger'] as bool? ?? false,
      state: json['state'] as String? ?? 'NORMAL',
    );
  }
}

/// Snapshot completo de una alerta con datos congelados
class AlertSnapshot {
  const AlertSnapshot({
    required this.alertId,
    required this.sensorId,
    required this.sensorName,
    required this.deviceName,
    required this.unit,
    required this.severity,
    required this.triggeredValue,
    required this.triggeredAt,
    required this.points,
    this.thresholdMin,
    this.thresholdMax,
    this.warningMin,
    this.warningMax,
    this.message,
  });

  final String alertId;
  final String sensorId;
  final String sensorName;
  final String deviceName;
  final String unit;
  final String severity; // 'warning', 'critical', 'alert'
  final double triggeredValue;
  final DateTime triggeredAt;
  final List<AlertSnapshotPoint> points; // Datos congelados
  final double? thresholdMin;
  final double? thresholdMax;
  final double? warningMin;
  final double? warningMax;
  final String? message;

  /// Punto que disparó la alerta
  AlertSnapshotPoint? get triggerPoint {
    try {
      return points.firstWhere((p) => p.isAlertTrigger);
    } catch (_) {
      return null;
    }
  }

  /// Indica si es una alerta crítica
  bool get isCritical => severity.toLowerCase() == 'critical';

  /// Indica si es una advertencia
  bool get isWarning => severity.toLowerCase() == 'warning';

  Map<String, dynamic> toJson() => {
    'alertId': alertId,
    'sensorId': sensorId,
    'sensorName': sensorName,
    'deviceName': deviceName,
    'unit': unit,
    'severity': severity,
    'triggeredValue': triggeredValue,
    'triggeredAt': triggeredAt.toIso8601String(),
    'points': points.map((p) => p.toJson()).toList(),
    'thresholdMin': thresholdMin,
    'thresholdMax': thresholdMax,
    'warningMin': warningMin,
    'warningMax': warningMax,
    'message': message,
  };

  factory AlertSnapshot.fromJson(Map<String, dynamic> json) {
    final pointsList = (json['points'] as List<dynamic>?)
        ?.map((p) => AlertSnapshotPoint.fromJson(p as Map<String, dynamic>))
        .toList() ?? [];

    return AlertSnapshot(
      alertId: json['alertId'] as String,
      sensorId: json['sensorId'] as String,
      sensorName: json['sensorName'] as String? ?? '',
      deviceName: json['deviceName'] as String? ?? '',
      unit: json['unit'] as String? ?? '',
      severity: json['severity'] as String,
      triggeredValue: (json['triggeredValue'] as num).toDouble(),
      triggeredAt: DateTime.parse(json['triggeredAt'] as String),
      points: pointsList,
      thresholdMin: (json['thresholdMin'] as num?)?.toDouble(),
      thresholdMax: (json['thresholdMax'] as num?)?.toDouble(),
      warningMin: (json['warningMin'] as num?)?.toDouble(),
      warningMax: (json['warningMax'] as num?)?.toDouble(),
      message: json['message'] as String?,
    );
  }
}

/// Modo de visualización de gráfica
enum ChartViewMode {
  /// Gráfica en tiempo real con polling (para monitoring)
  realtime,
  
  /// Gráfica congelada de snapshot de alerta (sin polling)
  frozen,
  
  /// Gráfica histórica (navegación manual, sin auto-refresh)
  historical,
}
