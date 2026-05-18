class ActiveAlertStatusViewModel {
  ActiveAlertStatusViewModel({
    required this.id,
    required this.sensorId,
    required this.deviceId,
    required this.thresholdId,
    required this.severity,
    required this.status,
    required this.triggeredValue,
    required this.triggeredAt,
  });

  final String id;
  final String sensorId;
  final String deviceId;
  final String thresholdId;
  final String severity;
  final String status;
  final String triggeredValue;
  final String triggeredAt;

  factory ActiveAlertStatusViewModel.fromJson(Map<String, dynamic> json) {
    return ActiveAlertStatusViewModel(
      id: json['id']?.toString() ?? '',
      sensorId: json['sensor_id']?.toString() ?? '',
      deviceId: json['device_id']?.toString() ?? '',
      thresholdId: json['threshold_id']?.toString() ?? '',
      severity: json['severity']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      triggeredValue: json['triggered_value']?.toString() ?? '',
      triggeredAt: json['triggered_at']?.toString() ?? '',
    );
  }
}

class ActiveWarningStatusViewModel {
  ActiveWarningStatusViewModel({
    required this.id,
    required this.sensorId,
    required this.deviceId,
    required this.eventType,
    required this.eventCode,
    required this.status,
    required this.createdAt,
    required this.title,
    required this.message,
    required this.payload,
  });

  final String id;
  final String sensorId;
  final String deviceId;
  final String eventType;
  final String eventCode;
  final String status;
  final String createdAt;
  final String? title;
  final String? message;
  final Map<String, dynamic>? payload;

  factory ActiveWarningStatusViewModel.fromJson(Map<String, dynamic> json) {
    return ActiveWarningStatusViewModel(
      id: json['id']?.toString() ?? '',
      sensorId: json['sensor_id']?.toString() ?? '',
      deviceId: json['device_id']?.toString() ?? '',
      eventType: json['event_type']?.toString() ?? '',
      eventCode: json['event_code']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      createdAt: json['created_at']?.toString() ?? '',
      title: json['title']?.toString(),
      message: json['message']?.toString(),
      payload: json['payload'] is Map ? (json['payload'] as Map).cast<String, dynamic>() : null,
    );
  }
}

class CurrentPredictionStatusViewModel {
  CurrentPredictionStatusViewModel({
    required this.id,
    required this.sensorId,
    required this.modelId,
    required this.predictedValue,
    required this.confidence,
    required this.predictedAt,
    required this.targetTimestamp,
  });

  final String id;
  final String sensorId;
  final String modelId;
  final String predictedValue;
  final String confidence;
  final String predictedAt;
  final String targetTimestamp;

  factory CurrentPredictionStatusViewModel.fromJson(Map<String, dynamic> json) {
    return CurrentPredictionStatusViewModel(
      id: json['id']?.toString() ?? '',
      sensorId: json['sensor_id']?.toString() ?? '',
      modelId: json['model_id']?.toString() ?? '',
      predictedValue: json['predicted_value']?.toString() ?? '',
      confidence: json['confidence']?.toString() ?? '',
      predictedAt: json['predicted_at']?.toString() ?? '',
      targetTimestamp: json['target_timestamp']?.toString() ?? '',
    );
  }
}

/// Estado operacional autoritativo del sensor (SSOT).
/// Fuente única de verdad - NO inferir desde alertas/warnings.
class OperationalStateViewModel {
  OperationalStateViewModel({
    required this.state,
    required this.stateSince,
    required this.validReadingsCount,
    required this.minReadingsForNormal,
    required this.canGenerateEvents,
  });

  /// Estado actual: INITIALIZING, NORMAL, WARNING, ALERT, STALE, UNKNOWN
  final String state;
  
  /// Timestamp de la última transición de estado
  final String? stateSince;
  
  /// Lecturas válidas consecutivas (para warm-up)
  final int validReadingsCount;
  
  /// Mínimo de lecturas para transicionar a NORMAL
  final int minReadingsForNormal;
  
  /// True si el sensor puede generar WARNING/ALERT
  final bool canGenerateEvents;

  /// True si el sensor está en warm-up (INITIALIZING)
  bool get isWarmingUp => state == 'INITIALIZING';
  
  /// True si el sensor está inactivo (STALE)
  bool get isStale => state == 'STALE';
  
  /// True si el sensor está operando normalmente
  bool get isNormal => state == 'NORMAL';
  
  /// Lecturas restantes para transicionar a NORMAL
  int get readingsUntilNormal => 
      isWarmingUp ? (minReadingsForNormal - validReadingsCount).clamp(0, minReadingsForNormal) : 0;

  factory OperationalStateViewModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return OperationalStateViewModel(
        state: 'UNKNOWN',
        stateSince: null,
        validReadingsCount: 0,
        minReadingsForNormal: 3,
        canGenerateEvents: false,
      );
    }
    return OperationalStateViewModel(
      state: json['state']?.toString() ?? 'UNKNOWN',
      stateSince: json['state_since']?.toString(),
      validReadingsCount: (json['valid_readings_count'] as num?)?.toInt() ?? 0,
      minReadingsForNormal: (json['min_readings_for_normal'] as num?)?.toInt() ?? 3,
      canGenerateEvents: json['can_generate_events'] == true,
    );
  }
}

class SensorConsolidatedStatusViewModel {
  SensorConsolidatedStatusViewModel({
    required this.sensorId,
    required this.finalState,
    required this.alertActive,
    required this.warningActive,
    required this.predictionCurrent,
    required this.operationalState,
  });

  final String sensorId;
  final String finalState;
  final ActiveAlertStatusViewModel? alertActive;

  /// Contrato futuro: puede venir lista. Hoy Nest envía objeto o null.
  final List<ActiveWarningStatusViewModel> warningActive;

  final CurrentPredictionStatusViewModel? predictionCurrent;
  
  /// Estado operacional autoritativo (SSOT).
  /// Usar este campo para determinar si mostrar eventos/notificaciones.
  final OperationalStateViewModel operationalState;

  /// True si el sensor puede generar eventos (WARNING/ALERT).
  /// Usar esto para filtrar notificaciones y eventos fantasma.
  bool get canGenerateEvents => operationalState.canGenerateEvents;
  
  /// True si el sensor está en warm-up (no mostrar eventos).
  bool get isWarmingUp => operationalState.isWarmingUp;
  
  /// True si el sensor está inactivo (STALE).
  bool get isStale => operationalState.isStale;

  factory SensorConsolidatedStatusViewModel.fromJson(Map<String, dynamic> json) {
    final alertJson = json['alert_active'];
    final warningJson = json['warning_active'];
    final predictionJson = json['prediction_current'];
    final operationalJson = json['operational_state'];

    final warnings = <ActiveWarningStatusViewModel>[];
    if (warningJson is List) {
      for (final w in warningJson) {
        if (w is Map) {
          warnings.add(ActiveWarningStatusViewModel.fromJson(w.cast<String, dynamic>()));
        }
      }
    } else if (warningJson is Map) {
      warnings.add(ActiveWarningStatusViewModel.fromJson(warningJson.cast<String, dynamic>()));
    }

    return SensorConsolidatedStatusViewModel(
      sensorId: json['sensor_id']?.toString() ?? '',
      finalState: json['final_state']?.toString() ?? 'unknown',
      alertActive: alertJson is Map
          ? ActiveAlertStatusViewModel.fromJson(alertJson.cast<String, dynamic>())
          : null,
      warningActive: warnings,
      predictionCurrent: predictionJson is Map
          ? CurrentPredictionStatusViewModel.fromJson(
              predictionJson.cast<String, dynamic>(),
            )
          : null,
      operationalState: OperationalStateViewModel.fromJson(
        operationalJson is Map ? operationalJson.cast<String, dynamic>() : null,
      ),
    );
  }
}
