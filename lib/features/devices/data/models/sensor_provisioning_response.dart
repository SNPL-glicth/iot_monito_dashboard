class SensorProvisioningResponse {
  final String sensorUuid;
  final int sensorId;
  final String mqttTopic;
  final String sensorApiKey;
  final int samplingIntervalMs;

  SensorProvisioningResponse({
    required this.sensorUuid,
    required this.sensorId,
    required this.mqttTopic,
    required this.sensorApiKey,
    required this.samplingIntervalMs,
  });

  factory SensorProvisioningResponse.fromJson(Map<String, dynamic> json) {
    return SensorProvisioningResponse(
      sensorUuid: (json['sensorUuid'] ?? json['sensor_uuid'] ?? '').toString(),
      sensorId: json['sensorId'] ?? json['sensor_id'] ?? 0,
      mqttTopic: (json['mqttTopic'] ?? json['mqtt_topic'] ?? '').toString(),
      sensorApiKey: (json['sensorApiKey'] ?? json['sensor_api_key'] ?? '').toString(),
      samplingIntervalMs: json['samplingIntervalMs'] ?? json['sampling_interval_ms'] ?? 2000,
    );
  }
}
