import '../../../../core/network/api_client.dart';
import '../models/monitoring_view_models.dart';

/// Operaciones de umbrales de sensores
class MonitoringThresholdOps {
  final ApiClient _apiClient;

  MonitoringThresholdOps(this._apiClient);

  Future<SensorThresholdProfileViewModel> fetchSensorThresholdProfile(String sensorId) async {
    final json = await _apiClient.getJson('/monitoring/sensors/$sensorId/threshold-profile');
    return SensorThresholdProfileViewModel.fromJson(json);
  }

  Future<SensorThresholdProfileViewModel> updateSensorThresholdProfile(
    String sensorId, {
    String? warningMin,
    String? warningMax,
    String? alertMin,
    String? alertMax,
    int? cooldownSeconds,
  }) async {
    final payload = <String, dynamic>{
      'warningMin': warningMin == null || warningMin.trim().isEmpty ? null : num.tryParse(warningMin),
      'warningMax': warningMax == null || warningMax.trim().isEmpty ? null : num.tryParse(warningMax),
      'alertMin': alertMin == null || alertMin.trim().isEmpty ? null : num.tryParse(alertMin),
      'alertMax': alertMax == null || alertMax.trim().isEmpty ? null : num.tryParse(alertMax),
      if (cooldownSeconds != null) 'cooldownSeconds': cooldownSeconds,
    };

    final json = await _apiClient.patchJsonAndDecode(
      '/monitoring/sensors/$sensorId/threshold-profile',
      payload,
    );
    return SensorThresholdProfileViewModel.fromJson(json);
  }

  Future<List<AlertThresholdViewModel>> fetchSensorThresholds(String sensorId) async {
    final data = await _apiClient.getList('/monitoring/sensors/$sensorId/thresholds');
    return data
        .map((e) => AlertThresholdViewModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<AlertThresholdViewModel> createSensorThreshold(
    String sensorId, {
    required String name,
    required String conditionType,
    String? thresholdValueMin,
    String? thresholdValueMax,
    String severity = 'warning',
  }) async {
    final payload = <String, dynamic>{
      'name': name,
      'conditionType': conditionType,
      'thresholdValueMin': thresholdValueMin == null || thresholdValueMin.isEmpty
          ? null
          : num.tryParse(thresholdValueMin),
      'thresholdValueMax': thresholdValueMax == null || thresholdValueMax.isEmpty
          ? null
          : num.tryParse(thresholdValueMax),
      'severity': severity,
    };

    final json = await _apiClient.postJsonAndDecode(
      '/monitoring/sensors/$sensorId/thresholds',
      payload,
    );

    return AlertThresholdViewModel.fromJson(json);
  }

  Future<AlertThresholdViewModel> updateThreshold(
    String thresholdId, {
    String? thresholdValueMin,
    String? thresholdValueMax,
    String? severity,
    String? name,
    String? reason,
  }) async {
    final payload = <String, dynamic>{
      if (thresholdValueMin != null && thresholdValueMin.trim().isNotEmpty)
        'thresholdValueMin': num.tryParse(thresholdValueMin),
      if (thresholdValueMax != null && thresholdValueMax.trim().isNotEmpty)
        'thresholdValueMax': num.tryParse(thresholdValueMax),
      if (severity != null) 'severity': severity,
      if (name != null) 'name': name,
      if (reason != null) 'reason': reason,
    };

    final json = await _apiClient.patchJsonAndDecode(
      '/monitoring/thresholds/$thresholdId',
      payload,
    );

    return AlertThresholdViewModel.fromJson(json);
  }

  Future<void> deactivateThreshold(String thresholdId, {String? reason}) async {
    final q = (reason == null || reason.trim().isEmpty) ? '' : '?reason=${Uri.encodeComponent(reason)}';
    await _apiClient.delete('/monitoring/thresholds/$thresholdId$q');
  }

  Future<List<ThresholdHistoryViewModel>> fetchThresholdHistory(String thresholdId) async {
    final data = await _apiClient.getList('/monitoring/thresholds/$thresholdId/history');
    return data
        .map((e) => ThresholdHistoryViewModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
