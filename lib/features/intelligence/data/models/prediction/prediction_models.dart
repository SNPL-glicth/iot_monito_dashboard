/// Modelos de predicción ML
library;

import 'dart:convert';

/// Vista resumida de una predicción ML para mostrar en la UI.
///
/// Esta vista se ajusta al contrato de `/intelligence/predictions`, donde el backend
/// ya calcula severidad y texto explicativo. Flutter solo consume y representa datos.
class PredictionSummaryViewModel {
  const PredictionSummaryViewModel({
    required this.deviceId,
    required this.deviceName,
    required this.sensorId,
    required this.sensorName,
    required this.sensorType,
    required this.unit,
    required this.predictedValue,
    required this.targetTimestamp,
    required this.horizonMinutes,
    required this.trend,
    required this.severity,
    required this.anomalyScore,
    required this.isAnomaly,
    required this.status,
    required this.explanation,
    required this.recommendedAction,
    required this.shortExplanation,
  });

  final String deviceId;
  final String deviceName;
  final String sensorId;
  final String sensorName;
  final String sensorType;
  final String unit;

  final String predictedValue;
  final String targetTimestamp; // ISO-8601
  final int horizonMinutes;

  /// 'up' | 'down' | 'stable'
  final String trend;

  /// Severidad calculada por el backend: puede venir como
  /// 'info' | 'warning' | 'critical' o variantes en mayúsculas (LOW/HIGH/etc.).
  final String severity;

  /// Score de anomalía normalizado 0-1 (si el backend lo expone).
  final double anomalyScore;

  /// Flag de anomalía calculado por el backend.
  final bool isAnomaly;

  /// Estado lógico de la predicción (p.ej. active | resolved).
  final String status;

  /// Campo explanation bruto, tal y como llega del backend (texto o JSON).
  final String explanation;

  /// Acción recomendada generada por el backend.
  final String recommendedAction;

  /// Explicación corta en lenguaje humano, derivada de explanation.
  final String shortExplanation;

  factory PredictionSummaryViewModel.fromJson(Map<String, dynamic> json) {
    final explanationRaw = '${json['explanation'] ?? ''}';

    String shortExplanation = '';
    String recommendedAction = '${json['recommendedAction'] ?? ''}';

    // Intentar interpretar explanation como JSON para extraer short_message
    // y recommended_action si están presentes.
    try {
      final decoded = jsonDecode(explanationRaw);
      if (decoded is Map<String, dynamic>) {
        shortExplanation = '${decoded['short_message'] ?? decoded['explanation'] ?? ''}';
        final ra = decoded['recommended_action'];
        if ((ra is String && ra.isNotEmpty) && recommendedAction.isEmpty) {
          recommendedAction = ra;
        }
      } else {
        shortExplanation = explanationRaw;
      }
    } catch (_) {
      // No es JSON → usamos el texto crudo como explicación corta.
      shortExplanation = explanationRaw;
    }

    double parseDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is num) return value.toDouble();
      final s = '$value';
      final d = double.tryParse(s);
      return d ?? 0.0;
    }

    bool parseBool(dynamic value) {
      if (value is bool) return value;
      final s = '${value ?? ''}'.toLowerCase().trim();
      return s == 'true' || s == '1' || s == 'yes';
    }

    return PredictionSummaryViewModel(
      deviceId: '${json['deviceId'] ?? ''}',
      deviceName: '${json['deviceName'] ?? ''}',
      sensorId: '${json['sensorId'] ?? ''}',
      sensorName: '${json['sensorName'] ?? ''}',
      sensorType: '${json['sensorType'] ?? ''}',
      unit: '${json['unit'] ?? ''}',
      predictedValue: json['predictedValue'] != null ? '${json['predictedValue']}' : '—',
      targetTimestamp: '${json['targetTimestamp'] ?? ''}',
      horizonMinutes: json['horizonMinutes'] is int
          ? json['horizonMinutes'] as int
          : int.tryParse('${json['horizonMinutes']}') ?? 0,
      trend: '${json['trend'] ?? 'stable'}',
      severity: '${json['severity'] ?? 'info'}',
      anomalyScore: parseDouble(json['anomaly_score'] ?? json['anomalyScore']),
      isAnomaly: parseBool(json['is_anomaly'] ?? json['isAnomaly']),
      status: '${json['status'] ?? 'active'}',
      explanation: explanationRaw,
      recommendedAction: recommendedAction,
      shortExplanation: shortExplanation,
    );
  }
}
