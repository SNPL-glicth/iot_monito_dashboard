class MlEventViewModel {
  MlEventViewModel({
    required this.eventId,
    required this.eventType,
    required this.eventCode,
    required this.title,
    required this.message,
    required this.status,
    required this.createdAt,
    required this.deviceId,
    required this.deviceUuid,
    required this.deviceName,
    required this.sensorId,
    required this.sensorName,
    required this.sensorType,
    required this.unit,
    required this.predictionId,
    required this.predictedValue,
    required this.confidence,
    required this.targetTimestamp,
    required this.payload,
  });

  final String eventId;
  final String eventType; // notice/warning/critical
  final String eventCode;
  final String title;
  final String? message;
  final String status;
  final String createdAt;

  final String deviceId;
  final String deviceUuid;
  final String deviceName;

  final String? sensorId;
  final String? sensorName;
  final String? sensorType;
  final String? unit;

  final String? predictionId;
  final String? predictedValue;
  final String? confidence;
  final String? targetTimestamp;
  final String? payload;

  factory MlEventViewModel.fromJson(Map<String, dynamic> json) {
    return MlEventViewModel(
      eventId: (json['eventId'] ?? json['event_id'] ?? json['eventId']).toString(),
      eventType: (json['eventType'] ?? json['event_type'] ?? '').toString(),
      eventCode: (json['eventCode'] ?? json['event_code'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      message: json['message']?.toString(),
      status: (json['status'] ?? '').toString(),
      createdAt: (json['createdAt'] ?? json['created_at'] ?? '').toString(),
      deviceId: (json['deviceId'] ?? json['device_id'] ?? '').toString(),
      deviceUuid: (json['deviceUuid'] ?? json['device_uuid'] ?? '').toString(),
      deviceName: (json['deviceName'] ?? json['device_name'] ?? '').toString(),
      sensorId: (json['sensorId'] ?? json['sensor_id'])?.toString(),
      sensorName: (json['sensorName'] ?? json['sensor_name'])?.toString(),
      sensorType: (json['sensorType'] ?? json['sensor_type'])?.toString(),
      unit: (json['unit'])?.toString(),
      predictionId: (json['predictionId'] ?? json['prediction_id'])?.toString(),
      predictedValue: (json['predictedValue'] ?? json['predicted_value'])?.toString(),
      confidence: (json['confidence'])?.toString(),
      targetTimestamp: (json['targetTimestamp'] ?? json['target_timestamp'])?.toString(),
      payload: (json['payload'])?.toString(),
    );
  }
}
