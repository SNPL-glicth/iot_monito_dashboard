class SensorProvisioningRequest {
  final String deviceUuid;
  final String sensorName;
  final String sensorType;
  final int samplingIntervalMs;
  final String unit;
  final int qos;

  SensorProvisioningRequest({
    required this.deviceUuid,
    required this.sensorName,
    required this.sensorType,
    required this.samplingIntervalMs,
    required this.unit,
    required this.qos,
  });

  Map<String, dynamic> toJson() {
    return {
      'device_uuid': deviceUuid,
      'sensor_name': sensorName,
      'sensor_type': sensorType,
      'sampling_interval_ms': samplingIntervalMs,
      'unit': unit,
      'qos': qos,
    };
  }
}
