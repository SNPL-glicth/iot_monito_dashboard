class DeviceWithSensorViewModel {
  DeviceWithSensorViewModel({
    required this.deviceId,
    required this.deviceUuid,
    required this.deviceName,
    required this.deviceType,
    required this.deviceStatus,
    this.lastConnection,
    this.sensorId,
    this.sensorUuid,
    this.sensorType,
    this.sensorName,
    this.unit,
    this.sensorActive,
    this.sensorStatus,
  });

  final String deviceId;
  final String deviceUuid;
  final String deviceName;
  final String deviceType;
  final String deviceStatus;
  final String? lastConnection;
  final String? sensorId;
  final String? sensorUuid;
  final String? sensorType;
  final String? sensorName;
  final String? unit;
  final bool? sensorActive;
  final String? sensorStatus;

  factory DeviceWithSensorViewModel.fromJson(Map<String, dynamic> json) {
    return DeviceWithSensorViewModel(
      deviceId: (json['deviceId'] ?? json['device_id'] ?? '').toString(),
      deviceUuid: (json['deviceUuid'] ?? json['device_uuid'] ?? '').toString(),
      deviceName: (json['deviceName'] ?? json['device_name'] ?? '').toString(),
      deviceType: (json['deviceType'] ?? json['device_type'] ?? '').toString(),
      deviceStatus: (json['deviceStatus'] ?? json['device_status'] ?? '').toString(),
      lastConnection: (json['lastConnection'] ?? json['last_connection'])?.toString(),
      sensorId: (json['sensorId'] ?? json['sensor_id'])?.toString(),
      sensorUuid: (json['sensorUuid'] ?? json['sensor_uuid'])?.toString(),
      sensorType: (json['sensorType'] ?? json['sensor_type'])?.toString(),
      sensorName: (json['sensorName'] ?? json['sensor_name'])?.toString(),
      unit: (json['unit'] ?? json['sensor_unit'])?.toString(),
      sensorActive: (json['sensorActive'] ?? json['sensor_active']) as bool?,
      sensorStatus: (json['sensorStatus'] ?? json['sensor_status'])?.toString(),
    );
  }

  /// Verifica si el sensor puede ser eliminado según su estado
  bool get canDelete {
    final status = (sensorStatus ?? '').toLowerCase();
    const deletableStates = ['draft', 'pending_claim', 'pending_confirmation', 'revoked'];
    
    // Permitir eliminar si:
    // 1. Status está en estados eliminables, O
    // 2. Sensor está inactivo, O
    // 3. Dispositivo está offline
    if (deletableStates.contains(status)) return true;
    if (sensorActive != true) return true;
    if (deviceStatus.toLowerCase() != 'online') return true;
    
    return false;
  }
}
