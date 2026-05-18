/// Respuesta al crear un dispositivo lógico
class ProvisionDeviceResponse {
  final String deviceUuid;
  final String deviceId;
  final String status;
  final String message;

  ProvisionDeviceResponse({
    required this.deviceUuid,
    required this.deviceId,
    required this.status,
    required this.message,
  });

  factory ProvisionDeviceResponse.fromJson(Map<String, dynamic> json) {
    return ProvisionDeviceResponse(
      deviceUuid: json['deviceUuid'] as String,
      deviceId: json['deviceId'].toString(),
      status: json['status'] as String? ?? 'PENDING_ACTIVATION',
      message: json['message'] as String,
    );
  }
}

/// Respuesta al preparar activación de un dispositivo
class PrepareActivationResponse {
  final String provisioningCode;
  final String qrData;

  PrepareActivationResponse({
    required this.provisioningCode,
    required this.qrData,
  });

  factory PrepareActivationResponse.fromJson(Map<String, dynamic> json) {
    return PrepareActivationResponse(
      provisioningCode: (json['provisioningCode'] ?? '').toString(),
      qrData: (json['qrData'] ?? '').toString(),
    );
  }
}

/// Sensor disponible para claim
class ClaimableSensor {
  final String sensorUuid;
  final String sensorType;
  final String unit;
  final String deviceUuid;
  final String deviceName;
  final String status;
  final String createdAt;

  ClaimableSensor({
    required this.sensorUuid,
    required this.sensorType,
    required this.unit,
    required this.deviceUuid,
    required this.deviceName,
    required this.status,
    required this.createdAt,
  });

  factory ClaimableSensor.fromJson(Map<String, dynamic> json) {
    return ClaimableSensor(
      sensorUuid: (json['sensorUuid'] ?? '').toString(),
      sensorType: (json['sensorType'] ?? '').toString(),
      unit: (json['unit'] ?? '').toString(),
      deviceUuid: (json['deviceUuid'] ?? '').toString(),
      deviceName: (json['deviceName'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      createdAt: (json['createdAt'] ?? '').toString(),
    );
  }
}
