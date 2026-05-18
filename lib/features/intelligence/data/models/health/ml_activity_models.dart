/// Modelos de actividad y anomalías ML
library;

/// Actividad del modelo ML.
class MlActivityViewModel {
  const MlActivityViewModel({
    required this.predictionsLast1h,
    required this.predictionsLast24h,
    required this.predictionsLast7d,
    required this.avgPredictionsPerHour,
  });

  final int predictionsLast1h;
  final int predictionsLast24h;
  final int predictionsLast7d;
  final double avgPredictionsPerHour;

  factory MlActivityViewModel.fromJson(Map<String, dynamic> json) {
    return MlActivityViewModel(
      predictionsLast1h: _parseInt(json['predictionsLast1h']),
      predictionsLast24h: _parseInt(json['predictionsLast24h']),
      predictionsLast7d: _parseInt(json['predictionsLast7d']),
      avgPredictionsPerHour: _parseDouble(json['avgPredictionsPerHour']),
    );
  }
}

/// Detección de anomalías.
class MlAnomalyDetectionViewModel {
  const MlAnomalyDetectionViewModel({
    required this.totalAnomalies,
    required this.anomalyRate,
    this.falsePositiveEstimate,
  });

  final int totalAnomalies;
  final double anomalyRate;
  final double? falsePositiveEstimate;

  factory MlAnomalyDetectionViewModel.fromJson(Map<String, dynamic> json) {
    return MlAnomalyDetectionViewModel(
      totalAnomalies: _parseInt(json['totalAnomalies']),
      anomalyRate: _parseDouble(json['anomalyRate']),
      falsePositiveEstimate: _parseNullableDouble(json['falsePositiveEstimate']),
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
