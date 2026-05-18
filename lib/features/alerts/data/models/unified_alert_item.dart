class UnifiedAlertItem {
  UnifiedAlertItem({
    required this.source,
    required this.id,
    required this.severity,
    required this.status,
    required this.title,
    required this.deviceName,
    required this.sensorId,
    required this.sensorName,
    required this.occurredAt,
    this.message,
    this.value,
    this.eventCode,
  });

  /// "threshold" (tabla alerts) o "ml" (tabla ml_events)
  final String source;
  final String id;
  final String severity;
  final String status;
  final String title;
  final String deviceName;

  /// Preferido para navegación. Para eventos ML debe venir.
  final String? sensorId;
  final String? sensorName;

  /// string (viene ya formateado desde backend en dd/MM/yyyy HH:mm)
  final String occurredAt;

  final String? message;
  final String? value;

  /// Para eventos ML, contiene el eventCode (ej: DELTA_SPIKE, ANOMALY_DETECTED, ...).
  /// Para alertas de umbral (source == 'threshold') suele ser null.
  final String? eventCode;
}
