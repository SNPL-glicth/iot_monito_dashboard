/// ML Features Model - Observable ML features for visualization.
/// 
/// FASE 2.4: This model represents ML features that are ALWAYS produced,
/// making the ML observable and explainable in the UI.
class MLFeaturesModel {
  const MLFeaturesModel({
    required this.sensorId,
    required this.timestamp,
    required this.timestampIso,
    required this.currentValue,
    required this.baseline,
    required this.baselineStd,
    required this.deviation,
    required this.deviationPct,
    required this.zScore,
    required this.trendSlope,
    required this.trendDirection,
    required this.stabilityScore,
    required this.confidence,
    required this.patternDetected,
    required this.isAnomalous,
    required this.anomalyScore,
    required this.windowSize,
    required this.modelVersion,
  });

  final int sensorId;
  final double timestamp; // Unix epoch
  final String timestampIso;
  final double currentValue;
  
  // Baseline (expected value from model)
  final double baseline;
  final double baselineStd;
  
  // Deviation from baseline
  final double deviation;
  final double deviationPct;
  final double zScore;
  
  // Trend analysis
  final double trendSlope;
  final String trendDirection; // 'up', 'down', 'stable'
  
  // Stability (0 = unstable, 1 = very stable)
  final double stabilityScore;
  
  // Model confidence (0 to 1)
  final double confidence;
  
  // Pattern classification
  final String patternDetected;
  
  // Anomaly indicators
  final bool isAnomalous;
  final double anomalyScore;
  
  // Metadata
  final int windowSize;
  final String modelVersion;

  factory MLFeaturesModel.fromJson(Map<String, dynamic> json) {
    return MLFeaturesModel(
      sensorId: _parseInt(json['sensor_id']),
      timestamp: _parseDouble(json['timestamp']),
      timestampIso: '${json['timestamp_iso'] ?? ''}',
      currentValue: _parseDouble(json['current_value']),
      baseline: _parseDouble(json['baseline']),
      baselineStd: _parseDouble(json['baseline_std']),
      deviation: _parseDouble(json['deviation']),
      deviationPct: _parseDouble(json['deviation_pct']),
      zScore: _parseDouble(json['z_score']),
      trendSlope: _parseDouble(json['trend_slope']),
      trendDirection: '${json['trend_direction'] ?? 'stable'}',
      stabilityScore: _parseDouble(json['stability_score']),
      confidence: _parseDouble(json['confidence']),
      patternDetected: '${json['pattern_detected'] ?? 'UNKNOWN'}',
      isAnomalous: json['is_anomalous'] == true,
      anomalyScore: _parseDouble(json['anomaly_score']),
      windowSize: _parseInt(json['window_size']),
      modelVersion: '${json['model_version'] ?? '1.0.0'}',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sensor_id': sensorId,
      'timestamp': timestamp,
      'timestamp_iso': timestampIso,
      'current_value': currentValue,
      'baseline': baseline,
      'baseline_std': baselineStd,
      'deviation': deviation,
      'deviation_pct': deviationPct,
      'z_score': zScore,
      'trend_slope': trendSlope,
      'trend_direction': trendDirection,
      'stability_score': stabilityScore,
      'confidence': confidence,
      'pattern_detected': patternDetected,
      'is_anomalous': isAnomalous,
      'anomaly_score': anomalyScore,
      'window_size': windowSize,
      'model_version': modelVersion,
    };
  }

  /// Get DateTime from timestamp
  DateTime get dateTime => DateTime.fromMillisecondsSinceEpoch(
    (timestamp * 1000).toInt(),
    isUtc: true,
  );

  /// Get confidence as percentage string
  String get confidencePercent => '${(confidence * 100).toStringAsFixed(0)}%';

  /// Get stability as percentage string
  String get stabilityPercent => '${(stabilityScore * 100).toStringAsFixed(0)}%';

  /// Get trend icon based on direction
  String get trendIcon {
    switch (trendDirection) {
      case 'up':
        return '↑';
      case 'down':
        return '↓';
      default:
        return '→';
    }
  }

  /// Get pattern label in Spanish
  String get patternLabel {
    switch (patternDetected) {
      case 'STABLE':
        return 'Estable';
      case 'TREND_UP':
        return 'Tendencia ascendente';
      case 'TREND_DOWN':
        return 'Tendencia descendente';
      case 'SPIKE':
        return 'Pico detectado';
      case 'OSCILLATING':
        return 'Oscilante';
      case 'MICRO_VARIATION':
        return 'Micro-variación';
      case 'NORMAL':
        return 'Normal';
      default:
        return patternDetected;
    }
  }

  /// Check if confidence is high (>= 80%)
  bool get isHighConfidence => confidence >= 0.8;

  /// Check if confidence is low (< 50%)
  bool get isLowConfidence => confidence < 0.5;

  /// Get upper confidence band value
  double get upperBand => baseline + baselineStd * 2;

  /// Get lower confidence band value
  double get lowerBand => baseline - baselineStd * 2;

  @override
  String toString() {
    return 'MLFeatures(sensor=$sensorId, baseline=$baseline, deviation=$deviation, '
        'confidence=$confidencePercent, pattern=$patternDetected)';
  }
}

// Helper functions for parsing
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
