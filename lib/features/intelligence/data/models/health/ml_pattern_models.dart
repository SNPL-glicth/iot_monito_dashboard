/// Modelos de patrones detectados por ML
library;

/// Patrón detectado por el modelo ML.
class MlPatternViewModel {
  const MlPatternViewModel({
    required this.patternType,
    required this.count,
    required this.description,
  });

  final String patternType;
  final int count;
  final String description;

  factory MlPatternViewModel.fromJson(Map<String, dynamic> json) {
    return MlPatternViewModel(
      patternType: '${json['patternType'] ?? ''}',
      count: _parseInt(json['count']),
      description: '${json['description'] ?? ''}',
    );
  }
}

/// Análisis de patrones detectados.
class MlPatternAnalysisViewModel {
  const MlPatternAnalysisViewModel({
    required this.patternsDetected,
    this.dominantPattern,
    required this.patternDiversity,
  });

  final List<MlPatternViewModel> patternsDetected;
  final String? dominantPattern;
  final double patternDiversity;

  factory MlPatternAnalysisViewModel.fromJson(Map<String, dynamic> json) {
    final patternsRaw = json['patternsDetected'];
    List<MlPatternViewModel> patterns = [];
    if (patternsRaw is List) {
      patterns = patternsRaw
          .whereType<Map>()
          .map((e) => MlPatternViewModel.fromJson(e.cast<String, dynamic>()))
          .toList();
    }

    return MlPatternAnalysisViewModel(
      patternsDetected: patterns,
      dominantPattern: json['dominantPattern']?.toString(),
      patternDiversity: _parseDouble(json['patternDiversity']),
    );
  }
}

int _parseInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is num) return value.toInt();
  final s = '$value';
  return int.tryParse(s) ?? 0;
}

double _parseDouble(dynamic value) {
  if (value == null) return 0.0;
  if (value is num) return value.toDouble();
  final s = '$value';
  return double.tryParse(s) ?? 0.0;
}
