/// Modelos de sensores
library;

/// FIX AUDITORIA: Estado operacional del sensor (SSOT desde BD)
class OperationalStateMetricsViewModel {
  OperationalStateMetricsViewModel({
    required this.state,
    required this.stateSince,
    required this.validReadingsCount,
    required this.minReadingsForNormal,
    required this.canGenerateEvents,
  });

  final String state;
  final String? stateSince;
  final int validReadingsCount;
  final int minReadingsForNormal;
  final bool canGenerateEvents;

  /// True si el sensor está en warm-up (INITIALIZING)
  bool get isWarmingUp => state == 'INITIALIZING';
  
  /// True si el sensor está inactivo (STALE)
  bool get isStale => state == 'STALE';
  
  /// Lecturas restantes para transicionar a NORMAL
  int get readingsUntilNormal => 
      isWarmingUp ? (minReadingsForNormal - validReadingsCount).clamp(0, minReadingsForNormal) : 0;

  factory OperationalStateMetricsViewModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return OperationalStateMetricsViewModel(
        state: 'UNKNOWN',
        stateSince: null,
        validReadingsCount: 0,
        minReadingsForNormal: 10,
        canGenerateEvents: false,
      );
    }
    return OperationalStateMetricsViewModel(
      state: json['state']?.toString() ?? 'UNKNOWN',
      stateSince: json['stateSince']?.toString(),
      validReadingsCount: (json['validReadingsCount'] as num?)?.toInt() ?? 0,
      minReadingsForNormal: (json['minReadingsForNormal'] as num?)?.toInt() ?? 10,
      canGenerateEvents: json['canGenerateEvents'] == true,
    );
  }
}

class SensorThresholdProfileViewModel {
  SensorThresholdProfileViewModel({
    required this.sensorId,
    this.warningMin,
    this.warningMax,
    this.alertMin,
    this.alertMax,
    required this.cooldownSeconds,
    this.updatedAt,
  });

  final String sensorId;
  final String? warningMin;
  final String? warningMax;
  final String? alertMin;
  final String? alertMax;
  final int cooldownSeconds;
  final String? updatedAt;

  factory SensorThresholdProfileViewModel.fromJson(Map<String, dynamic> json) {
    dynamic pick(String camel, String snake) => json.containsKey(camel) ? json[camel] : json[snake];
    return SensorThresholdProfileViewModel(
      sensorId: json['sensorId']?.toString() ?? '',
      warningMin: pick('warningMin', 'warning_min')?.toString(),
      warningMax: pick('warningMax', 'warning_max')?.toString(),
      alertMin: pick('alertMin', 'alert_min')?.toString(),
      alertMax: pick('alertMax', 'alert_max')?.toString(),
      cooldownSeconds: (json['cooldownSeconds'] is num)
          ? (json['cooldownSeconds'] as num).toInt()
          : int.tryParse(json['cooldownSeconds']?.toString() ?? '') ?? 300,
      updatedAt: json['updatedAt']?.toString(),
    );
  }
}

/// Umbrales explícitos por sensor (NUEVO - del Orquestador)
class SensorThresholdsViewModel {
  SensorThresholdsViewModel({
    required this.sensorId,
    this.thresholdMin,
    this.thresholdMax,
    this.warningMin,
    this.warningMax,
    required this.severity,
  });

  final int sensorId;
  final double? thresholdMin;
  final double? thresholdMax;
  final double? warningMin;
  final double? warningMax;
  final String severity;

  factory SensorThresholdsViewModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return SensorThresholdsViewModel(sensorId: 0, severity: 'none');
    }
    double? nn(dynamic x) {
      if (x == null) return null;
      if (x is num) return x.toDouble();
      return double.tryParse(x.toString().replaceAll(',', '.'));
    }
    return SensorThresholdsViewModel(
      sensorId: (json['sensorId'] as num?)?.toInt() ?? 0,
      thresholdMin: nn(json['thresholdMin']),
      thresholdMax: nn(json['thresholdMax']),
      warningMin: nn(json['warningMin']),
      warningMax: nn(json['warningMax']),
      severity: json['severity']?.toString() ?? 'none',
    );
  }
}

