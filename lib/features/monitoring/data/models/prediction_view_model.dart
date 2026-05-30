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
  final String sensorId;
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
    String _sanitize(dynamic v) {
      final s = v?.toString() ?? '';
      if (s.isEmpty || s == 'undefined' || s == 'null') return '';
      return s.trim();
    }

    final sensor = json['sensor'] as Map<String, dynamic>?;
    final model = json['model'] as Map<String, dynamic>?;
    final device = sensor != null ? sensor['device'] as Map<String, dynamic>? : null;

    final rawSensorId = json['sensorId'] ?? json['sensor_id'] ?? sensor?['id'] ?? sensor?['sensorId'] ?? sensor?['sensor_id'];

    return PredictionViewModel(
      id: _sanitize(json['id']),
      sensorId: _sanitize(rawSensorId),
      predictedValue:
          _sanitize(json['predictedValue'] ?? json['predicted_value']),
      confidence: _sanitize(json['confidence']),
      predictedAt:
          _sanitize(json['predictedAt'] ?? json['predicted_at']),
      targetTimestamp:
          _sanitize(json['targetTimestamp'] ?? json['target_timestamp']),
      sensorName: _sanitize(json['sensorName'] ?? sensor?['name']),
      unit: _sanitize(json['unit'] ?? sensor?['unit']),
      deviceName: _sanitize(json['deviceName'] ?? device?['deviceName'] ?? device?['name']),
      modelName:
          _sanitize(json['modelName'] ?? model?['modelName']),
      modelVersion:
          _sanitize(json['modelVersion'] ?? model?['version']),
    );
  }
}
//un objetivo es quitar el problema, claro , pregunta problema, que resultados da
//