/// Punto histórico individual para gráficas congeladas
class HistoricalReadingPoint {
  HistoricalReadingPoint({
    required this.timestamp,
    required this.value,
    required this.state,
  });

  final String timestamp;
  final double value;
  final String state; // NORMAL, WARNING, ALERT

  factory HistoricalReadingPoint.fromJson(Map<String, dynamic> json) {
    return HistoricalReadingPoint(
      timestamp: json['timestamp']?.toString() ?? '',
      value: (json['value'] as num?)?.toDouble() ?? 0.0,
      state: json['state']?.toString() ?? 'NORMAL',
    );
  }
}

/// Umbrales asociados a datos históricos
class HistoricalThresholdsData {
  HistoricalThresholdsData({
    this.alertMin,
    this.alertMax,
    this.warningMin,
    this.warningMax,
  });

  final double? alertMin;
  final double? alertMax;
  final double? warningMin;
  final double? warningMax;

  factory HistoricalThresholdsData.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return HistoricalThresholdsData();
    }
    return HistoricalThresholdsData(
      alertMin: (json['alertMin'] as num?)?.toDouble(),
      alertMax: (json['alertMax'] as num?)?.toDouble(),
      warningMin: (json['warningMin'] as num?)?.toDouble(),
      warningMax: (json['warningMax'] as num?)?.toDouble(),
    );
  }
}
