/// Modelo para la última lectura de un sensor
class LatestSensorReadingViewModel {
  LatestSensorReadingViewModel({
    required this.sensorId,
    required this.sensorUuid,
    required this.sensorName,
    required this.sensorType,
    required this.unit,
    required this.deviceName,
    this.latestValue,
    this.latestTimestamp,
  });

  final String sensorId;
  final String sensorUuid;
  final String sensorName;
  final String sensorType;
  final String unit;
  final String deviceName;
  final String? latestValue;
  final String? latestTimestamp;

  factory LatestSensorReadingViewModel.fromJson(Map<String, dynamic> json) {
    return LatestSensorReadingViewModel(
      sensorId: json['sensorId']?.toString() ?? '',
      sensorUuid: json['sensorUuid']?.toString() ?? '',
      sensorName: json['sensorName']?.toString() ?? '',
      sensorType: json['sensorType']?.toString() ?? '',
      unit: json['unit']?.toString() ?? '',
      deviceName: json['deviceName']?.toString() ?? '',
      latestValue: json['latestValue']?.toString(),
      latestTimestamp: json['latestTimestamp']?.toString(),
    );
  }
}
