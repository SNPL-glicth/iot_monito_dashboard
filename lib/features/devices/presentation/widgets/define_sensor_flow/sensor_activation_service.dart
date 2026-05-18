import 'dart:convert';

import '../../../data/provisioning_repository.dart';

/// Service for sensor activation API calls
class SensorActivationService {
  final _repo = ProvisioningRepository();

  /// Define sensor metrics
  Future<dynamic> defineSensor({
    required String deviceUuid,
    required String sensorType,
    required String unit,
    required double? warningMin,
    required double? warningMax,
    required double? alertMin,
    required double? alertMax,
  }) async {
    return await _repo.defineSensor(
      deviceUuid: deviceUuid,
      sensorType: sensorType,
      unit: unit,
      warningMin: warningMin,
      warningMax: warningMax,
      alertMin: alertMin,
      alertMax: alertMax,
    );
  }

  /// Publish sensor (DRAFT → PENDING_CLAIM)
  Future<void> publishSensor({
    required String sensorUuid,
    bool requireQrConfirmation = true,
  }) async {
    await _repo.publishSensor(
      sensorUuid: sensorUuid,
      requireQrConfirmation: requireQrConfirmation,
    );
  }

  /// Reserve sensor (PENDING_CLAIM → PENDING_CONFIRMATION)
  Future<dynamic> reserveSensor({required String sensorUuid}) async {
    return await _repo.reserveSensor(sensorUuid: sensorUuid);
  }

  /// Confirm sensor activation (PENDING_CONFIRMATION → ONLINE)
  Future<dynamic> confirmSensor({required String claimToken}) async {
    return await _repo.confirmSensor(claimToken: claimToken);
  }

  /// Complete activation flow: publish → reserve → confirm
  Future<dynamic> activateSensorWithCode({
    required String sensorUuid,
  }) async {
    // 1. Publish the sensor (DRAFT → PENDING_CLAIM)
    await publishSensor(
      sensorUuid: sensorUuid,
      requireQrConfirmation: false,
    );

    // 2. Reserve the sensor (PENDING_CLAIM → PENDING_CONFIRMATION)
    final reserveResult = await reserveSensor(sensorUuid: sensorUuid);

    // 3. Confirm activation (PENDING_CONFIRMATION → ONLINE)
    final confirmResult = await confirmSensor(
      claimToken: reserveResult.claimToken,
    );

    return confirmResult;
  }

  /// Parse QR code data to extract sensor ID
  String parseQRCode(String qrData) {
    String sensorCode;
    try {
      final decoded = jsonDecode(qrData);
      sensorCode = decoded['sensor_id']?.toString() ?? 
                   decoded['id']?.toString() ?? 
                   decoded['code']?.toString() ?? 
                   qrData;
    } catch (_) {
      sensorCode = qrData;
    }
    
    // Limitar longitud
    if (sensorCode.length > 50) {
      sensorCode = sensorCode.substring(0, 50);
    }
    
    return sensorCode;
  }
}
