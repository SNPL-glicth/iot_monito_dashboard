/// Modelos de tareas y señales
library;

/// Contexto de tarea para ML
class TaskContextViewModel {
  const TaskContextViewModel({
    required this.taskType,
    required this.sensorIds,
    required this.timeWindowMinutes,
    required this.priority,
    required this.description,
    required this.requiredData,
    required this.expectedOutput,
  });

  final String taskType;
  final List<int> sensorIds;
  final int timeWindowMinutes;
  final int priority;
  final String description;
  final List<String> requiredData;
  final String expectedOutput;

  factory TaskContextViewModel.fromJson(Map<String, dynamic> json) {
    return TaskContextViewModel(
      taskType: '${json['taskType'] ?? ''}',
      sensorIds: _parseIntList(json['sensorIds']),
      timeWindowMinutes: _parseInt(json['timeWindowMinutes']),
      priority: _parseInt(json['priority']),
      description: '${json['description'] ?? ''}',
      requiredData: _parseStringList(json['requiredData']),
      expectedOutput: '${json['expectedOutput'] ?? ''}',
    );
  }

  String get taskTypeLabel {
    switch (taskType) {
      case 'anomaly_detection': return 'Detección de anomalías';
      case 'trend_analysis': return 'Análisis de tendencia';
      case 'pattern_recognition': return 'Reconocimiento de patrones';
      case 'threshold_monitoring': return 'Monitoreo de umbrales';
      case 'correlation_analysis': return 'Análisis de correlación';
      case 'degradation_tracking': return 'Seguimiento de degradación';
      default: return taskType;
    }
  }
}

/// Análisis de señal
class SignalAnalysisViewModel {
  const SignalAnalysisViewModel({
    required this.signalStrength,
    required this.signalType,
    required this.isWeakSignal,
    required this.trendDirection,
    required this.trendConfidence,
    required this.anomalyProbability,
    required this.context,
  });

  final double signalStrength;
  final String signalType;
  final bool isWeakSignal;
  final String trendDirection;
  final double trendConfidence;
  final double anomalyProbability;
  final String context;

  factory SignalAnalysisViewModel.fromJson(Map<String, dynamic> json) {
    return SignalAnalysisViewModel(
      signalStrength: _parseDouble(json['signalStrength']),
      signalType: '${json['signalType'] ?? ''}',
      isWeakSignal: json['isWeakSignal'] == true,
      trendDirection: '${json['trendDirection'] ?? 'stable'}',
      trendConfidence: _parseDouble(json['trendConfidence']),
      anomalyProbability: _parseDouble(json['anomalyProbability']),
      context: '${json['context'] ?? ''}',
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

List<int> _parseIntList(dynamic value) {
  if (value is List) {
    return value.map((e) => _parseInt(e)).toList();
  }
  return [];
}

List<String> _parseStringList(dynamic value) {
  if (value is List) {
    return value.map((e) => '$e').toList();
  }
  return [];
}

double _parseDouble(dynamic value) {
  if (value == null) return 0.0;
  if (value is num) return value.toDouble();
  final s = '$value';
  return double.tryParse(s) ?? 0.0;
}
