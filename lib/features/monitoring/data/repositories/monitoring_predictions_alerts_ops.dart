import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../core/network/api_client.dart';
import '../models/monitoring_view_models.dart';
import '../models/prediction_view_model.dart';
import 'monitoring_cache.dart';

/// Operaciones de predicciones y alertas
class MonitoringPredictionsAlertsOps {
  final ApiClient _apiClient;

  MonitoringPredictionsAlertsOps(this._apiClient);

  Future<List<ActiveAlertViewModel>> fetchActiveAlerts() async {
    final cached = MonitoringCache.getActiveAlertsCache();
    if (cached != null) {
      final now = DateTime.now();
      final age = now.difference(MonitoringCache.activeAlertsCacheTimestamp!).inSeconds;
      debugPrint('🔵 [Cache HIT] activeAlerts — age: ${age}s');
      return cached.map((e) => ActiveAlertViewModel.fromJson(e as Map<String, dynamic>)).toList();
    }
    
    debugPrint('🟢 [Cache MISS] activeAlerts — fetching from API');
    final data = await _apiClient.getList('/monitoring/alerts/active');
    final result = data
        .map((e) => ActiveAlertViewModel.fromJson(e as Map<String, dynamic>))
        .toList();
    
    MonitoringCache.setActiveAlertsCache(result);
    return result;
  }

  Future<List<PredictionViewModel>> fetchPredictions() async {
    final cached = MonitoringCache.getPredictionsCache();
    if (cached != null) {
      final now = DateTime.now();
      final age = now.difference(MonitoringCache.predictionsCacheTimestamp!).inSeconds;
      debugPrint('🔵 [Cache HIT] predictions — age: ${age}s');
      return cached;
    }
    
    debugPrint('🟢 [Cache MISS] predictions — fetching from API');
    final data = await _apiClient.getList('/monitoring/predictions');
    final result = data
        .map((e) => PredictionViewModel.fromJson(e as Map<String, dynamic>))
        .toList();
    
    MonitoringCache.setPredictionsCache(result);
    return result;
  }
}
