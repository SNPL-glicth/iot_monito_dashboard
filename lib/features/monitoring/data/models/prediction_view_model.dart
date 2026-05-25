class PredictionViewModel {
  PredictionViewModel({
    required this.id,
    required this.sensorId,
    required this.predictedValue,
    required this.confidence,
    required this.predictedAt,
    required this.targetTimestamp,
    required this.sensorName,
    required this.unit,
    required this.deviceName,
    required this.modelName,
    required this.modelVersion,
  });

  final String id;
  final int sensorId;
  final String predictedValue;
  final String confidence;
  final String predictedAt;
  final String targetTimestamp;
  final String sensorName;
  final String unit;
  final String deviceName;
  final String modelName;
  final String modelVersion;

  factory PredictionViewModel.fromJson(Map<String, dynamic> json) {
    final sensor = json['sensor'] as Map<String, dynamic>?;
    final model = json['model'] as Map<String, dynamic>?;
    final device = sensor != null ? sensor['device'] as Map<String, dynamic>? : null;

    final rawSensorId = json['sensorId'] ?? json['sensor_id'] ?? sensor?['id'] ?? sensor?['sensorId'] ?? sensor?['sensor_id'];

    return PredictionViewModel(
      id: json['id']?.toString() ?? '',
      sensorId: rawSensorId is int ? rawSensorId : int.tryParse(rawSensorId?.toString() ?? '') ?? 0,
      predictedValue:
          json['predictedValue']?.toString() ?? json['predicted_value']?.toString() ?? '',
      confidence: json['confidence']?.toString() ?? '',
      predictedAt:
          json['predictedAt']?.toString() ?? json['predicted_at']?.toString() ?? '',
      targetTimestamp:
          json['targetTimestamp']?.toString() ?? json['target_timestamp']?.toString() ?? '',
      sensorName: json['sensorName'] as String? ?? sensor?['name'] as String? ?? '',
      unit: json['unit'] as String? ?? sensor?['unit'] as String? ?? '',
      deviceName: json['deviceName'] as String? ??
          device?['deviceName'] as String? ??
          device?['name'] as String? ??
          '',
      modelName:
          json['modelName'] as String? ?? model?['modelName'] as String? ?? '',
      modelVersion:
          json['modelVersion'] as String? ?? model?['version'] as String? ?? '',
    );
  }
}
