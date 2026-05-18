import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../core/network/api_client.dart';
import '../models/monitoring_view_models.dart';
import 'monitoring_cache.dart';

/// Operaciones de dashboard y métricas
class MonitoringDashboardOps {
  final ApiClient _apiClient;

  MonitoringDashboardOps(this._apiClient);

  Future<SensorMetricsViewModel> fetchSensorMetrics(
    String sensorId, {
    String window = '1h',
  }) async {
    final json = await _apiClient.getJson('/sensors/$sensorId/metrics?window=$window');
    return SensorMetricsViewModel.fromJson(json);
  }

  Future<SensorDashboardViewModel> fetchSensorDashboard(
    String sensorId, {
    String range = '6h',
    bool forceRefresh = false,
  }) async {
    final key = '$sensorId|$range';
    final cached = MonitoringCache.getDashboardCache(key);
    
    if (!forceRefresh && cached != null) {
      final now = DateTime.now();
      final age = now.difference(cached.at).inSeconds;
      debugPrint('🔵 [Cache HIT] dashboard:$sensorId — age: ${age}s');
      return cached.data;
    }
    
    debugPrint('🟢 [Cache MISS] dashboard:$sensorId — fetching from API (forceRefresh: $forceRefresh)');

    final next = await _withRetryOnce(() async {
      final json = await _apiClient
          .getJson('/sensors/$sensorId/dashboard?range=$range')
          .timeout(const Duration(seconds: 8));
      return SensorDashboardViewModel.fromJson(json);
    });

    MonitoringCache.setDashboardCache(key, next);
    return next;
  }

  Future<T> _withRetryOnce<T>(Future<T> Function() op) async {
    try {
      return await op();
    } catch (_) {
      await Future<void>.delayed(const Duration(milliseconds: 250));
      return op();
    }
  }
}
