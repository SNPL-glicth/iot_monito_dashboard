/// Modelos de micro-deltas y datos ignorados
library;

/// Sensibilidad a micro-deltas.
class MlMicroDeltaSensitivityViewModel {
  const MlMicroDeltaSensitivityViewModel({
    required this.totalChanges,
    required this.microChanges,
    required this.microChangeRate,
    required this.sensitivityThreshold,
    required this.ignoredChangesCount,
  });

  final int totalChanges;
  final int microChanges;
  final double microChangeRate;
  final double sensitivityThreshold;
  final int ignoredChangesCount;

  factory MlMicroDeltaSensitivityViewModel.fromJson(Map<String, dynamic> json) {
    return MlMicroDeltaSensitivityViewModel(
      totalChanges: _parseInt(json['totalChanges']),
      microChanges: _parseInt(json['microChanges']),
      microChangeRate: _parseDouble(json['microChangeRate']),
      sensitivityThreshold: _parseDouble(json['sensitivityThreshold']),
      ignoredChangesCount: _parseInt(json['ignoredChangesCount']),
    );
  }
}

/// Razón de datos ignorados.
class MlIgnoredReasonViewModel {
  const MlIgnoredReasonViewModel({
    required this.reason,
    required this.count,
    required this.description,
  });

  final String reason;
  final int count;
  final String description;

  factory MlIgnoredReasonViewModel.fromJson(Map<String, dynamic> json) {
    return MlIgnoredReasonViewModel(
      reason: '${json['reason'] ?? ''}',
      count: _parseInt(json['count']),
      description: '${json['description'] ?? ''}',
    );
  }
}

/// Análisis de margen de error.
class MlErrorMarginAnalysisViewModel {
  const MlErrorMarginAnalysisViewModel({
    required this.estimatedMarginPct,
    required this.marginConfidence,
    required this.isReliable,
    required this.explanation,
  });

  final double estimatedMarginPct;
  final double marginConfidence;
  final bool isReliable;
  final String explanation;

  factory MlErrorMarginAnalysisViewModel.fromJson(Map<String, dynamic> json) {
    return MlErrorMarginAnalysisViewModel(
      estimatedMarginPct: _parseDouble(json['estimatedMarginPct']),
      marginConfidence: _parseDouble(json['marginConfidence']),
      isReliable: json['isReliable'] == true,
      explanation: '${json['explanation'] ?? ''}',
    );
  }
}

double _parseDouble(dynamic value) {
  if (value == null) return 0.0;
  if (value is num) return value.toDouble();
  final s = '$value';
  return double.tryParse(s) ?? 0.0;
}

int _parseInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is num) return value.toInt();
  final s = '$value';
  return int.tryParse(s) ?? 0;
}
