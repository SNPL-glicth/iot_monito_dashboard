import 'package:flutter/foundation.dart';

import '../models/monitoring_view_models.dart';
import '../models/prediction_view_model.dart';

/// Gestión de cache para MonitoringRepository
class MonitoringCache {
  // Cache de dashboard
  static final Map<String, ({DateTime at, SensorDashboardViewModel data})> _dashboardCache = {};
  static const Duration _dashboardTtl = Duration(seconds: 5);
  static const int _dashboardCacheMaxEntries = 30;
  
  // Cache de predicciones
  static List<PredictionViewModel>? _predictionsCache;
  static DateTime? _predictionsCacheTimestamp;
  static const Duration _predictionsCacheTtl = Duration(seconds: 5);
  
  // Cache de alertas activas
  static List<dynamic>? _activeAlertsCache;
  static DateTime? _activeAlertsCacheTimestamp;
  static const Duration _activeAlertsCacheTtl = Duration(seconds: 5);

  /// Obtiene cache de dashboard si es válido
  static ({DateTime at, SensorDashboardViewModel data})? getDashboardCache(String key) {
    final cached = _dashboardCache[key];
    final now = DateTime.now();
    if (cached != null && now.difference(cached.at) <= _dashboardTtl) {
      return cached;
    }
    return null;
  }

  /// Guarda en cache de dashboard
  static void setDashboardCache(String key, SensorDashboardViewModel data) {
    final now = DateTime.now();
    _dashboardCache[key] = (at: now, data: data);
    _pruneCache();
  }

  /// Limpia entries antiguas del cache
  static void _pruneCache() {
    if (_dashboardCache.length <= _dashboardCacheMaxEntries) return;
    
    final entries = _dashboardCache.entries.toList()
      ..sort((a, b) => a.value.at.compareTo(b.value.at));
    
    final toRemove = entries.length - _dashboardCacheMaxEntries;
    for (var i = 0; i < toRemove; i++) {
      _dashboardCache.remove(entries[i].key);
    }
  }

  /// Obtiene cache de predicciones si es válido
  static List<PredictionViewModel>? getPredictionsCache() {
    final now = DateTime.now();
    if (_predictionsCache != null && 
        _predictionsCacheTimestamp != null &&
        now.difference(_predictionsCacheTimestamp!) < _predictionsCacheTtl) {
      return _predictionsCache;
    }
    return null;
  }

  /// Guarda en cache de predicciones
  static void setPredictionsCache(List<PredictionViewModel> data) {
    _predictionsCache = data;
    _predictionsCacheTimestamp = DateTime.now();
  }

  /// Obtiene timestamp de cache de predicciones
  static DateTime? get predictionsCacheTimestamp => _predictionsCacheTimestamp;

  /// Obtiene cache de alertas activas si es válido
  static List<dynamic>? getActiveAlertsCache() {
    final now = DateTime.now();
    if (_activeAlertsCache != null && 
        _activeAlertsCacheTimestamp != null &&
        now.difference(_activeAlertsCacheTimestamp!) < _activeAlertsCacheTtl) {
      return _activeAlertsCache;
    }
    return null;
  }

  /// Guarda en cache de alertas activas
  static void setActiveAlertsCache(List<dynamic> data) {
    _activeAlertsCache = data;
    _activeAlertsCacheTimestamp = DateTime.now();
  }

  /// Obtiene timestamp de cache de alertas activas
  static DateTime? get activeAlertsCacheTimestamp => _activeAlertsCacheTimestamp;

  /// Invalida cache de dashboard para un sensor
  static void invalidateDashboardCache(String sensorId) {
    _dashboardCache.removeWhere((key, _) => key.startsWith('$sensorId|'));
    debugPrint('🗑️ [MonitoringCache] Dashboard cache invalidated for sensor $sensorId');
  }

  /// Invalida todo el cache
  static void invalidateAllCache() {
    _dashboardCache.clear();
    _predictionsCache = null;
    _predictionsCacheTimestamp = null;
    _activeAlertsCache = null;
    _activeAlertsCacheTimestamp = null;
    debugPrint('🗑️ [MonitoringCache] All caches invalidated');
  }

  /// Invalida cache de predicciones
  static void invalidatePredictionsCache() {
    _predictionsCache = null;
    _predictionsCacheTimestamp = null;
  }

  /// Invalida cache de alertas activas
  static void invalidateActiveAlertsCache() {
    _activeAlertsCache = null;
    _activeAlertsCacheTimestamp = null;
  }
}
