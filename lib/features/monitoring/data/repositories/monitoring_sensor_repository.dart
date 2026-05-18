import '../../../../core/network/api_client.dart';
import '../models/device_with_sensor_view_model.dart';
import '../models/sensor_consolidated_status_view_model.dart';

/// Repositorio de operaciones de sensores
class MonitoringSensorRepository {
  final ApiClient _apiClient;

  MonitoringSensorRepository(this._apiClient);

  Future<List<DeviceWithSensorViewModel>> fetchDevicesWithSensors() async {
    final data = await _apiClient.getList('/monitoring/devices');
    return data
        .map((e) => DeviceWithSensorViewModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<SensorConsolidatedStatusViewModel> fetchSensorStatus(String sensorId) async {
    final json = await _apiClient.getJson('/sensors/$sensorId/status');
    return SensorConsolidatedStatusViewModel.fromJson(json);
  }

  /// Actualiza los datos básicos de un sensor (nombre, etc.)
  Future<void> updateSensor(String sensorId, {String? name}) async {
    final payload = <String, dynamic>{
      if (name != null) 'name': name,
    };
    await _apiClient.patchJsonAndDecode('/devices/sensors/$sensorId', payload);
  }

  /// Elimina un sensor (requiere que no esté activo/online)
  Future<String> deleteSensor(String sensorId) async {
    final response = await _apiClient.deleteAndDecode('/devices/sensors/$sensorId');
    return response['message'] as String? ?? 'Sensor eliminado';
  }

  /// Batch endpoint para obtener status de múltiples sensores en 1 request
  Future<Map<String, SensorConsolidatedStatusViewModel>> fetchSensorStatusBatch(
    List<String> sensorIds,
  ) async {
    if (sensorIds.isEmpty) {
      return {};
    }

    final idsParam = sensorIds.join(',');
    final json = await _apiClient.getJson('/sensors/status/batch?ids=$idsParam');
    final items = (json['items'] as List<dynamic>?) ?? [];

    final result = <String, SensorConsolidatedStatusViewModel>{};
    for (final item in items) {
      if (item is Map<String, dynamic>) {
        final vm = SensorConsolidatedStatusViewModel.fromJson(item);
        if (vm.sensorId.isNotEmpty) {
          result[vm.sensorId] = vm;
        }
      }
    }
    return result;
  }
}
