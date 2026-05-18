/// Modelo base para una lectura de sensor
class SensorReadingViewModel {
  SensorReadingViewModel({
    required this.id,
    required this.sensorId,
    required this.value,
    required this.timestamp,
  });

  final String id;
  final String sensorId;
  final String value;
  /// ISO-8601 o string legible (según backend)
  final String timestamp;

  factory SensorReadingViewModel.fromJson(Map<String, dynamic> json) {
    return SensorReadingViewModel(
      id: json['id'].toString(),
      sensorId: json['sensorId'].toString(),
      value: json['value'].toString(),
      timestamp: json['timestamp'].toString(),
    );
  }
}
