/// Respuesta al agregar un sensor (legacy)
class AddSensorResponse {
  final String sensorUuid;
  final String sensorId;
  final String name;
  final String sensorType;
  final String unit;
  final SensorThresholds? thresholds;

  AddSensorResponse({
    required this.sensorUuid,
    required this.sensorId,
    required this.name,
    required this.sensorType,
    required this.unit,
    this.thresholds,
  });

  factory AddSensorResponse.fromJson(Map<String, dynamic> json) {
    return AddSensorResponse(
      sensorUuid: (json['sensorUuid'] ?? '').toString(),
      sensorId: (json['sensorId'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      sensorType: (json['sensorType'] ?? '').toString(),
      unit: (json['unit'] ?? '').toString(),
      thresholds: json['thresholds'] != null
          ? SensorThresholds.fromJson(json['thresholds'] as Map<String, dynamic>)
          : null,
    );
  }
}

/// Respuesta al definir un sensor (PASO 1)
class DefineSensorResponse {
  final String sensorUuid;
  final String sensorId;
  final String sensorType;
  final String unit;
  final String status;
  final String message;

  DefineSensorResponse({
    required this.sensorUuid,
    required this.sensorId,
    required this.sensorType,
    required this.unit,
    required this.status,
    required this.message,
  });

  factory DefineSensorResponse.fromJson(Map<String, dynamic> json) {
    return DefineSensorResponse(
      sensorUuid: (json['sensorUuid'] ?? '').toString(),
      sensorId: (json['sensorId'] ?? '').toString(),
      sensorType: (json['sensorType'] ?? '').toString(),
      unit: (json['unit'] ?? '').toString(),
      status: (json['status'] ?? 'DRAFT').toString(),
      message: (json['message'] ?? '').toString(),
    );
  }
}

/// Respuesta al reservar un sensor
class ReserveSensorResponse {
  final String sensorUuid;
  final String sensorType;
  final String unit;
  final String deviceName;
  final String claimToken;
  final String claimTokenExpires;
  final bool requireQrConfirmation;
  final String? qrData;
  final String message;

  ReserveSensorResponse({
    required this.sensorUuid,
    required this.sensorType,
    required this.unit,
    required this.deviceName,
    required this.claimToken,
    required this.claimTokenExpires,
    required this.requireQrConfirmation,
    this.qrData,
    required this.message,
  });

  factory ReserveSensorResponse.fromJson(Map<String, dynamic> json) {
    return ReserveSensorResponse(
      sensorUuid: (json['sensorUuid'] ?? '').toString(),
      sensorType: (json['sensorType'] ?? '').toString(),
      unit: (json['unit'] ?? '').toString(),
      deviceName: (json['deviceName'] ?? '').toString(),
      claimToken: (json['claimToken'] ?? '').toString(),
      claimTokenExpires: (json['claimTokenExpires'] ?? '').toString(),
      requireQrConfirmation: json['requireQrConfirmation'] as bool? ?? false,
      qrData: json['qrData']?.toString(),
      message: (json['message'] ?? '').toString(),
    );
  }
}

/// Respuesta al confirmar un sensor (incluye API Key)
class ConfirmSensorResponse {
  final String sensorUuid;
  final String sensorId;
  final String name;
  final String sensorType;
  final String unit;
  final String deviceUuid;
  final String deviceName;
  final String status;
  final String sensorApiKey;
  final String apiKeyPrefix;
  final String message;

  ConfirmSensorResponse({
    required this.sensorUuid,
    required this.sensorId,
    required this.name,
    required this.sensorType,
    required this.unit,
    required this.deviceUuid,
    required this.deviceName,
    required this.status,
    required this.sensorApiKey,
    required this.apiKeyPrefix,
    required this.message,
  });

  factory ConfirmSensorResponse.fromJson(Map<String, dynamic> json) {
    return ConfirmSensorResponse(
      sensorUuid: (json['sensorUuid'] ?? '').toString(),
      sensorId: (json['sensorId'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      sensorType: (json['sensorType'] ?? '').toString(),
      unit: (json['unit'] ?? '').toString(),
      deviceUuid: (json['deviceUuid'] ?? '').toString(),
      deviceName: (json['deviceName'] ?? '').toString(),
      status: (json['status'] ?? 'ONLINE').toString(),
      sensorApiKey: (json['sensorApiKey'] ?? '').toString(),
      apiKeyPrefix: (json['apiKeyPrefix'] ?? '').toString(),
      message: (json['message'] ?? '').toString(),
    );
  }
}

/// Umbrales de un sensor
class SensorThresholds {
  final double? warningMin;
  final double? warningMax;
  final double? alertMin;
  final double? alertMax;

  SensorThresholds({
    this.warningMin,
    this.warningMax,
    this.alertMin,
    this.alertMax,
  });

  factory SensorThresholds.fromJson(Map<String, dynamic> json) {
    return SensorThresholds(
      warningMin: (json['warningMin'] as num?)?.toDouble(),
      warningMax: (json['warningMax'] as num?)?.toDouble(),
      alertMin: (json['alertMin'] as num?)?.toDouble(),
      alertMax: (json['alertMax'] as num?)?.toDouble(),
    );
  }
}
