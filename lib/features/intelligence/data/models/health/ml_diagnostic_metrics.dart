/// Modelos de métricas de diagnóstico ML
library;

/// Métricas de error del modelo ML.
class MlErrorMetricsViewModel {
  const MlErrorMetricsViewModel({
    this.mae,
    this.rmse,
    this.mape,
    this.stdDev,
    required this.sampleSize,
  });

  /// Mean Absolute Error
  final double? mae;
  /// Root Mean Square Error
  final double? rmse;
  /// Mean Absolute Percentage Error
  final double? mape;
  /// Standard Deviation
  final double? stdDev;
  /// Número de muestras evaluadas
  final int sampleSize;

  factory MlErrorMetricsViewModel.fromJson(Map<String, dynamic> json) {
    return MlErrorMetricsViewModel(
      mae: _parseNullableDouble(json['mae']),
      rmse: _parseNullableDouble(json['rmse']),
      mape: _parseNullableDouble(json['mape']),
      stdDev: _parseNullableDouble(json['stdDev']),
      sampleSize: _parseInt(json['sampleSize']),
    );
  }
}

/// Calidad de predicciones por confianza.
class MlPredictionQualityViewModel {
  const MlPredictionQualityViewModel({
    required this.avgConfidence,
    required this.lowConfidenceRate,
    required this.highConfidenceRate,
    required this.confidenceDistribution,
  });

  final double avgConfidence;
  final double lowConfidenceRate;
  final double highConfidenceRate;
  final Map<String, int> confidenceDistribution;

  factory MlPredictionQualityViewModel.fromJson(Map<String, dynamic> json) {
    final distRaw = json['confidenceDistribution'];
    Map<String, int> dist = {};
    if (distRaw is Map) {
      dist = distRaw.map((k, v) => MapEntry('$k', _parseInt(v)));
    }

    return MlPredictionQualityViewModel(
      avgConfidence: _parseDouble(json['avgConfidence']),
      lowConfidenceRate: _parseDouble(json['lowConfidenceRate']),
      highConfidenceRate: _parseDouble(json['highConfidenceRate']),
      confidenceDistribution: dist,
    );
  }
}

/// Métricas de precisión por umbral.
class MlAccuracyMetricsViewModel {
  const MlAccuracyMetricsViewModel({
    required this.withinThreshold5pct,
    required this.withinThreshold10pct,
    required this.withinThreshold20pct,
    required this.totalEvaluated,
  });

  final double withinThreshold5pct;
  final double withinThreshold10pct;
  final double withinThreshold20pct;
  final int totalEvaluated;

  factory MlAccuracyMetricsViewModel.fromJson(Map<String, dynamic> json) {
    return MlAccuracyMetricsViewModel(
      withinThreshold5pct: _parseDouble(json['withinThreshold5pct']),
      withinThreshold10pct: _parseDouble(json['withinThreshold10pct']),
      withinThreshold20pct: _parseDouble(json['withinThreshold20pct']),
      totalEvaluated: _parseInt(json['totalEvaluated']),
    );
  }
}

double _parseDouble(dynamic value) {
  if (value == null) return 0.0;
  if (value is num) return value.toDouble();
  final s = '$value';
  return double.tryParse(s) ?? 0.0;
}

double? _parseNullableDouble(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  final s = '$value';
  return double.tryParse(s);
}

int _parseInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is num) return value.toInt();
  final s = '$value';
  return int.tryParse(s) ?? 0;
}
