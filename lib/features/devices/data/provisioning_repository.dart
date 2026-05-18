import '../../../core/network/api_client.dart';
import 'models/device_responses.dart';
import 'models/sensor_responses.dart';

// SINGLETON: Evita crear múltiples instancias que causan memory leaks
class ProvisioningRepository {
  // Singleton instance
  static final ProvisioningRepository _instance = ProvisioningRepository._internal();
  
  // Factory constructor retorna siempre la misma instancia
  factory ProvisioningRepository([ApiClient? client]) => _instance;
  
  // Constructor privado interno
  ProvisioningRepository._internal() : _client = ApiClient();

  final ApiClient _client;

  /// PASO 1: Crear dispositivo (lógico)
  /// Solo nombre requerido, estado DRAFT, sin api_key
  Future<ProvisionDeviceResponse> createDevice({
    required String name,
    String? model,
  }) async {
    final body = <String, dynamic>{'name': name};
    if (model != null) body['model'] = model;

    final response = await _client.postJsonAndDecode('/devices/create', body);
    return ProvisionDeviceResponse.fromJson(response);
  }

  /// PASO 2: Preparar activación (cuando hay hardware)
  /// Genera provisioning_code, estado PENDING_ACTIVATION
  /// Retorna QR data para el firmware
  Future<PrepareActivationResponse> prepareActivation({
    required String deviceUuid,
  }) async {
    final response = await _client.postJsonAndDecode(
      '/devices/$deviceUuid/prepare-activation',
      {},
    );
    return PrepareActivationResponse.fromJson(response);
  }

  /// Legacy: Agrega sensor completo (para compatibilidad)
  Future<AddSensorResponse> addSensor({
    required String deviceUuid,
    required String sensorType,
    required String name,
    required String unit,
    double? warningMin,
    double? warningMax,
    double? alertMin,
    double? alertMax,
  }) async {
    final body = <String, dynamic>{
      'sensorType': sensorType,
      'name': name,
      'unit': unit,
    };
    if (warningMin != null) body['warningMin'] = warningMin;
    if (warningMax != null) body['warningMax'] = warningMax;
    if (alertMin != null) body['alertMin'] = alertMin;
    if (alertMax != null) body['alertMax'] = alertMax;

    final response = await _client.postJsonAndDecode(
      '/devices/$deviceUuid/sensors',
      body,
    );
    return AddSensorResponse.fromJson(response);
  }

  // ══════════════════════════════════════════════════════════════════════════
  // NUEVO FLUJO DE SENSORES (paso a paso)
  // ══════════════════════════════════════════════════════════════════════════

  /// PASO 1 SENSOR: Definir sensor (solo métricas, SIN nombre, SIN crear físicamente)
  Future<DefineSensorResponse> defineSensor({
    required String deviceUuid,
    required String sensorType,
    required String unit,
    double? warningMin,
    double? warningMax,
    double? alertMin,
    double? alertMax,
  }) async {
    final body = <String, dynamic>{
      'sensorType': sensorType,
      'unit': unit,
    };
    if (warningMin != null) body['warningMin'] = warningMin;
    if (warningMax != null) body['warningMax'] = warningMax;
    if (alertMin != null) body['alertMin'] = alertMin;
    if (alertMax != null) body['alertMax'] = alertMax;

    final response = await _client.postJsonAndDecode(
      '/devices/$deviceUuid/sensors/define',
      body,
    );
    return DefineSensorResponse.fromJson(response);
  }

  // ══════════════════════════════════════════════════════════════════════════
  // FLUJO DEFINITIVO: PUBLISH → RESERVE → CONFIRM
  // ══════════════════════════════════════════════════════════════════════════

  /// PASO 2: Publicar sensor (hacerlo disponible para claim)
  /// Estado: DRAFT → PENDING_CLAIM
  Future<Map<String, dynamic>> publishSensor({
    required String sensorUuid,
    bool requireQrConfirmation = false,
  }) async {
    final response = await _client.postJsonAndDecode(
      '/devices/sensors/$sensorUuid/publish',
      {'requireQrConfirmation': requireQrConfirmation},
    );
    return response;
  }

  /// Lista sensores disponibles para claim (PENDING_CLAIM)
  Future<List<ClaimableSensor>> getClaimableSensors() async {
    final response = await _client.getJsonAndDecode('/devices/sensors/claimable');
    final list = response as List<dynamic>;
    return list.map((e) => ClaimableSensor.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// PASO 3: Reservar sensor (instalador selecciona)
  /// Estado: PENDING_CLAIM → PENDING_CONFIRMATION
  Future<ReserveSensorResponse> reserveSensor({
    required String sensorUuid,
  }) async {
    final response = await _client.postJsonAndDecode(
      '/devices/sensors/$sensorUuid/reserve',
      {},
    );
    return ReserveSensorResponse.fromJson(response);
  }

  /// PASO 4: Confirmar activación del sensor
  /// Estado: PENDING_CONFIRMATION → ONLINE
  /// 
  /// ⚠️ Auth implícita por claim_token de un solo uso
  /// 🚫 NO acepta nombre - el admin lo asigna después
  /// 
  /// Retorna el API Key del sensor (⚠️ SOLO SE MUESTRA UNA VEZ)
  Future<ConfirmSensorResponse> confirmSensor({
    required String claimToken,
  }) async {
    final response = await _client.postJsonAndDecode(
      '/devices/sensors/confirm',
      {'claimToken': claimToken},
    );
    return ConfirmSensorResponse.fromJson(response);
  }

  // ══════════════════════════════════════════════════════════════════════════
  // ELIMINACIÓN DE DISPOSITIVOS
  // ══════════════════════════════════════════════════════════════════════════

  /// Elimina un dispositivo (soft delete)
  /// Solo permite eliminar dispositivos en estado: draft, pending_activation, offline
  Future<String> deleteDevice({required String deviceId}) async {
    final response = await _client.deleteAndDecode('/devices/$deviceId');
    return response['message'] as String? ?? 'Dispositivo eliminado';
  }

  /// Actualiza datos básicos de un dispositivo (nombre)
  Future<String> updateDevice({
    required String deviceId,
    String? name,
  }) async {
    final body = <String, dynamic>{};
    if (name != null) body['name'] = name;
    
    final response = await _client.patchJsonAndDecode('/devices/$deviceId', body);
    return response['message'] as String? ?? 'Dispositivo actualizado';
  }
}
