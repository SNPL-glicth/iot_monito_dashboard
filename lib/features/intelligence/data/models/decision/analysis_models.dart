/// Modelos de análisis de cambios y spikes
library;

/// Análisis de cambio en valores de sensor
class ChangeAnalysisViewModel {
  const ChangeAnalysisViewModel({
    required this.changeType,
    required this.magnitudePct,
    required this.durationReadings,
    required this.isWithinThreshold,
    required this.context,
    required this.confidence,
  });

  final String changeType;
  final double magnitudePct;
  final int durationReadings;
  final bool isWithinThreshold;
  final String context;
  final double confidence;

  factory ChangeAnalysisViewModel.fromJson(Map<String, dynamic> json) {
    return ChangeAnalysisViewModel(
      changeType: '${json['changeType'] ?? 'unknown'}',
      magnitudePct: _parseDouble(json['magnitudePct']),
      durationReadings: _parseInt(json['durationReadings']),
      isWithinThreshold: json['isWithinThreshold'] == true,
      context: '${json['context'] ?? ''}',
      confidence: _parseDouble(json['confidence']),
    );
  }

  String get changeTypeLabel {
    switch (changeType) {
      case 'noise': return 'Ruido';
      case 'micro_variation': return 'Micro-variación';
      case 'small_change': return 'Cambio pequeño';
      case 'significant': return 'Cambio significativo';
      case 'spike': return 'Spike';
      case 'degradation': return 'Degradación';
      case 'stable': return 'Estable';
      default: return changeType;
    }
  }
}

/// Análisis de spike
class SpikeAnalysisViewModel {
  const SpikeAnalysisViewModel({
    required this.spikeType,
    required this.magnitude,
    required this.durationSeconds,
    required this.frequencyPerHour,
    required this.peakValue,
    required this.baselineValue,
    required this.deviationFromBaselinePct,
    required this.isRecurring,
    required this.context,
    required this.probableCause,
    required this.severityAssessment,
  });

  final String spikeType;
  final double magnitude;
  final int durationSeconds;
  final double frequencyPerHour;
  final double peakValue;
  final double baselineValue;
  final double deviationFromBaselinePct;
  final bool isRecurring;
  final String context;
  final String probableCause;
  final String severityAssessment;

  factory SpikeAnalysisViewModel.fromJson(Map<String, dynamic> json) {
    return SpikeAnalysisViewModel(
      spikeType: '${json['spikeType'] ?? 'unknown'}',
      magnitude: _parseDouble(json['magnitude']),
      durationSeconds: _parseInt(json['durationSeconds']),
      frequencyPerHour: _parseDouble(json['frequencyPerHour']),
      peakValue: _parseDouble(json['peakValue']),
      baselineValue: _parseDouble(json['baselineValue']),
      deviationFromBaselinePct: _parseDouble(json['deviationFromBaselinePct']),
      isRecurring: json['isRecurring'] == true,
      context: '${json['context'] ?? ''}',
      probableCause: '${json['probableCause'] ?? ''}',
      severityAssessment: '${json['severityAssessment'] ?? ''}',
    );
  }

  String get spikeTypeLabel {
    switch (spikeType) {
      case 'sudden': return 'Súbito';
      case 'gradual': return 'Gradual';
      case 'sustained': return 'Sostenido';
      case 'oscillating': return 'Oscilante';
      case 'isolated': return 'Aislado';
      default: return spikeType;
    }
  }

  bool get isCritical => severityAssessment.contains('CRÍTICO');
  bool get isHigh => severityAssessment.contains('ALTO');
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
