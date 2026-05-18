/// Modelos de diagnóstico completo ML
library;

import 'ml_diagnostic_metrics.dart';
import 'ml_activity_models.dart';
import 'ml_pattern_models.dart';
import 'ml_microdelta_models.dart';

/// Diagnóstico completo del modelo ML.
/// 
/// Esta vista se ajusta al contrato de `/intelligence/ml/diagnostic`.
/// Proporciona métricas de salud, error, calidad y actividad del modelo.
/// 
/// ISO 27001: Solo expone métricas agregadas, no datos sensibles.
class MlDiagnosticViewModel {
  const MlDiagnosticViewModel({
    required this.timestamp,
    required this.modelHealth,
    required this.healthScore,
    required this.errorMetrics,
    required this.predictionQuality,
    required this.accuracyMetrics,
    required this.modelActivity,
    required this.anomalyDetection,
    required this.patternAnalysis,
    required this.microDeltaSensitivity,
    required this.ignoredDataReasons,
    required this.errorMarginAnalysis,
    required this.recommendations,
    required this.warnings,
  });

  /// Timestamp ISO-8601 del diagnóstico
  final String timestamp;
  
  /// Estado de salud: 'healthy' | 'degraded' | 'critical' | 'unknown'
  final String modelHealth;
  
  /// Puntuación de salud 0-100
  final int healthScore;
  
  /// Métricas de error (MAE, RMSE, MAPE)
  final MlErrorMetricsViewModel errorMetrics;
  
  /// Calidad de predicciones por confianza
  final MlPredictionQualityViewModel predictionQuality;
  
  /// Precisión por umbral
  final MlAccuracyMetricsViewModel accuracyMetrics;
  
  /// Actividad del modelo
  final MlActivityViewModel modelActivity;
  
  /// Detección de anomalías
  final MlAnomalyDetectionViewModel anomalyDetection;
  
  /// Análisis de patrones detectados
  final MlPatternAnalysisViewModel patternAnalysis;
  
  /// Sensibilidad a micro-deltas
  final MlMicroDeltaSensitivityViewModel microDeltaSensitivity;
  
  /// Razones de datos ignorados
  final List<MlIgnoredReasonViewModel> ignoredDataReasons;
  
  /// Análisis de margen de error
  final MlErrorMarginAnalysisViewModel errorMarginAnalysis;
  
  /// Recomendaciones del sistema
  final List<String> recommendations;
  
  /// Advertencias del sistema
  final List<String> warnings;

  factory MlDiagnosticViewModel.fromJson(Map<String, dynamic> json) {
    final ignoredRaw = json['ignoredDataReasons'];
    List<MlIgnoredReasonViewModel> ignoredReasons = [];
    if (ignoredRaw is List) {
      ignoredReasons = ignoredRaw
          .whereType<Map>()
          .map((e) => MlIgnoredReasonViewModel.fromJson(e.cast<String, dynamic>()))
          .toList();
    }

    return MlDiagnosticViewModel(
      timestamp: '${json['timestamp'] ?? ''}',
      modelHealth: '${json['modelHealth'] ?? 'unknown'}',
      healthScore: _parseInt(json['healthScore']),
      errorMetrics: MlErrorMetricsViewModel.fromJson(
        json['errorMetrics'] is Map ? (json['errorMetrics'] as Map).cast<String, dynamic>() : {},
      ),
      predictionQuality: MlPredictionQualityViewModel.fromJson(
        json['predictionQuality'] is Map ? (json['predictionQuality'] as Map).cast<String, dynamic>() : {},
      ),
      accuracyMetrics: MlAccuracyMetricsViewModel.fromJson(
        json['accuracyMetrics'] is Map ? (json['accuracyMetrics'] as Map).cast<String, dynamic>() : {},
      ),
      modelActivity: MlActivityViewModel.fromJson(
        json['modelActivity'] is Map ? (json['modelActivity'] as Map).cast<String, dynamic>() : {},
      ),
      anomalyDetection: MlAnomalyDetectionViewModel.fromJson(
        json['anomalyDetection'] is Map ? (json['anomalyDetection'] as Map).cast<String, dynamic>() : {},
      ),
      patternAnalysis: MlPatternAnalysisViewModel.fromJson(
        json['patternAnalysis'] is Map ? (json['patternAnalysis'] as Map).cast<String, dynamic>() : {},
      ),
      microDeltaSensitivity: MlMicroDeltaSensitivityViewModel.fromJson(
        json['microDeltaSensitivity'] is Map ? (json['microDeltaSensitivity'] as Map).cast<String, dynamic>() : {},
      ),
      ignoredDataReasons: ignoredReasons,
      errorMarginAnalysis: MlErrorMarginAnalysisViewModel.fromJson(
        json['errorMarginAnalysis'] is Map ? (json['errorMarginAnalysis'] as Map).cast<String, dynamic>() : {},
      ),
      recommendations: _parseStringList(json['recommendations']),
      warnings: _parseStringList(json['warnings']),
    );
  }

  /// Indica si el modelo está saludable
  bool get isHealthy => modelHealth == 'healthy';
  
  /// Indica si el modelo está degradado
  bool get isDegraded => modelHealth == 'degraded';
  
  /// Indica si el modelo está crítico
  bool get isCritical => modelHealth == 'critical';
  
  /// Indica si el estado es desconocido
  bool get isUnknown => modelHealth == 'unknown';

  /// Color sugerido según el estado de salud
  String get healthColorHex {
    switch (modelHealth) {
      case 'healthy':
        return '#4CAF50';
      case 'degraded':
        return '#FF9800';
      case 'critical':
        return '#F44336';
      default:
        return '#9E9E9E';
    }
  }

  /// Etiqueta en español del estado de salud
  String get healthLabel {
    switch (modelHealth) {
      case 'healthy':
        return 'Saludable';
      case 'degraded':
        return 'Degradado';
      case 'critical':
        return 'Crítico';
      default:
        return 'Desconocido';
    }
  }
}

int _parseInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is num) return value.toInt();
  final s = '$value';
  return int.tryParse(s) ?? 0;
}

List<String> _parseStringList(dynamic value) {
  if (value is List) {
    return value.map((e) => '$e').toList();
  }
  return [];
}
