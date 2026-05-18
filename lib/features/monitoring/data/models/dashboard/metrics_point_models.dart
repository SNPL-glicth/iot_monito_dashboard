/// Punto individual en una serie de métricas de sensor
class SensorMetricsPointViewModel {
  SensorMetricsPointViewModel({
    required this.timestamp,
    this.value,
    this.prediction,
    this.event,
  });

  final String timestamp;
  final double? value;
  final double? prediction;

  /// null | "WARNING" | "ALERT"
  final String? event;

  factory SensorMetricsPointViewModel.fromJson(Map<String, dynamic> json) {
    double? n(dynamic x) {
      if (x == null) return null;
      if (x is num) return x.toDouble();
      return double.tryParse(x.toString().replaceAll(',', '.'));
    }

    return SensorMetricsPointViewModel(
      timestamp: json['timestamp']?.toString() ?? '',
      value: n(json['value']),
      prediction: n(json['prediction']),
      event: json['event']?.toString(),
    );
  }
}
