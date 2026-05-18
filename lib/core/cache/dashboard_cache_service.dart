/// Servicio de cache centralizado para datos del dashboard.
/// 
/// FIX FASE 2: Reduce requests HTTP duplicados y mejora rendimiento.
/// 
/// Características:
/// - Cache en memoria con TTL configurable
/// - Invalidación selectiva por tipo de dato
/// - Thread-safe para uso concurrente
/// - Singleton para compartir cache entre widgets
library;

import '../../features/crm/data/models/crm_dashboard_models.dart';
import '../../features/monitoring/data/models/prediction_view_model.dart';
import '../../features/alerts/data/models/unified_alert_item.dart';

/// Entrada de cache con timestamp y TTL
class _CacheEntry<T> {
  _CacheEntry({
    required this.data,
    required this.ttl,
  }) : timestamp = DateTime.now();

  final T data;
  final DateTime timestamp;
  final Duration ttl;

  bool get isExpired => DateTime.now().difference(timestamp) > ttl;
  
  /// Tiempo restante antes de expirar
  Duration get remainingTtl {
    final elapsed = DateTime.now().difference(timestamp);
    final remaining = ttl - elapsed;
    return remaining.isNegative ? Duration.zero : remaining;
  }
}

/// Servicio singleton de cache para el dashboard
class DashboardCacheService {
  // Singleton
  static final DashboardCacheService _instance = DashboardCacheService._internal();
  factory DashboardCacheService() => _instance;
  DashboardCacheService._internal();

  // TTLs configurables
  static const Duration defaultTtl = Duration(seconds: 30);
  static const Duration badgeTtl = Duration(seconds: 30);
  static const Duration predictionsTtl = Duration(seconds: 45);
  static const Duration alertsTtl = Duration(seconds: 20);
  
  // Cache entries
  _CacheEntry<CrmDashboardResponse>? _dashboardCache;
  _CacheEntry<int>? _badgeCountCache;
  _CacheEntry<List<PredictionViewModel>>? _predictionsCache;
  _CacheEntry<List<UnifiedAlertItem>>? _mlAlertsCache;
  
  // Cache de sensores por ID (para detalles)
  final Map<String, _CacheEntry<dynamic>> _sensorCache = {};
  static const int _maxSensorCacheEntries = 50;

  // ============ Dashboard ============
  
  /// Obtiene el dashboard cacheado si está fresco
  CrmDashboardResponse? getDashboard() {
    if (_dashboardCache == null || _dashboardCache!.isExpired) {
      return null;
    }
    return _dashboardCache!.data;
  }

  /// Guarda el dashboard en cache
  void setDashboard(CrmDashboardResponse data, {Duration? ttl}) {
    _dashboardCache = _CacheEntry(
      data: data,
      ttl: ttl ?? defaultTtl,
    );
  }

  /// Invalida el cache del dashboard
  void invalidateDashboard() {
    _dashboardCache = null;
  }

  // ============ Badge Count ============
  
  /// Obtiene el conteo de badge cacheado si está fresco
  int? getBadgeCount() {
    if (_badgeCountCache == null || _badgeCountCache!.isExpired) {
      return null;
    }
    return _badgeCountCache!.data;
  }

  /// Guarda el conteo de badge en cache
  void setBadgeCount(int count, {Duration? ttl}) {
    _badgeCountCache = _CacheEntry(
      data: count,
      ttl: ttl ?? badgeTtl,
    );
  }

  /// Invalida el cache del badge
  void invalidateBadge() {
    _badgeCountCache = null;
  }

  // ============ Predictions ============
  
  /// Obtiene las predicciones cacheadas si están frescas
  List<PredictionViewModel>? getPredictions() {
    if (_predictionsCache == null || _predictionsCache!.isExpired) {
      return null;
    }
    return _predictionsCache!.data;
  }

  /// Guarda las predicciones en cache
  void setPredictions(List<PredictionViewModel> data, {Duration? ttl}) {
    _predictionsCache = _CacheEntry(
      data: data,
      ttl: ttl ?? predictionsTtl,
    );
  }

  /// Invalida el cache de predicciones
  void invalidatePredictions() {
    _predictionsCache = null;
  }

  // ============ ML Alerts ============
  
  /// Obtiene las alertas ML cacheadas si están frescas
  List<UnifiedAlertItem>? getMlAlerts() {
    if (_mlAlertsCache == null || _mlAlertsCache!.isExpired) {
      return null;
    }
    return _mlAlertsCache!.data;
  }

  /// Guarda las alertas ML en cache
  void setMlAlerts(List<UnifiedAlertItem> data, {Duration? ttl}) {
    _mlAlertsCache = _CacheEntry(
      data: data,
      ttl: ttl ?? alertsTtl,
    );
  }

  /// Invalida el cache de alertas ML
  void invalidateMlAlerts() {
    _mlAlertsCache = null;
  }

  // ============ Sensor Cache ============
  
  /// Obtiene datos de sensor cacheados
  T? getSensorData<T>(String sensorId, String dataType) {
    final key = '${sensorId}_$dataType';
    final entry = _sensorCache[key];
    if (entry == null || entry.isExpired) {
      _sensorCache.remove(key);
      return null;
    }
    return entry.data as T?;
  }

  /// Guarda datos de sensor en cache
  void setSensorData<T>(String sensorId, String dataType, T data, {Duration? ttl}) {
    final key = '${sensorId}_$dataType';
    _sensorCache[key] = _CacheEntry(
      data: data,
      ttl: ttl ?? defaultTtl,
    );
    _pruneSensorCache();
  }

  /// Invalida cache de un sensor específico
  void invalidateSensor(String sensorId) {
    _sensorCache.removeWhere((key, _) => key.startsWith('${sensorId}_'));
  }

  /// Limpia entradas antiguas del cache de sensores
  void _pruneSensorCache() {
    if (_sensorCache.length <= _maxSensorCacheEntries) return;
    
    // Eliminar entradas expiradas primero
    _sensorCache.removeWhere((_, entry) => entry.isExpired);
    
    // Si aún excede el límite, eliminar las más antiguas
    if (_sensorCache.length > _maxSensorCacheEntries) {
      final entries = _sensorCache.entries.toList()
        ..sort((a, b) => a.value.timestamp.compareTo(b.value.timestamp));
      
      final toRemove = entries.length - _maxSensorCacheEntries;
      for (var i = 0; i < toRemove; i++) {
        _sensorCache.remove(entries[i].key);
      }
    }
  }

  // ============ Utilidades ============
  
  /// Invalida todo el cache
  void invalidateAll() {
    _dashboardCache = null;
    _badgeCountCache = null;
    _predictionsCache = null;
    _mlAlertsCache = null;
    _sensorCache.clear();
  }

  /// Obtiene estadísticas del cache (para debugging)
  Map<String, dynamic> getStats() {
    return {
      'dashboard': _dashboardCache != null ? {
        'expired': _dashboardCache!.isExpired,
        'remainingTtl': _dashboardCache!.remainingTtl.inSeconds,
      } : null,
      'badge': _badgeCountCache != null ? {
        'value': _badgeCountCache!.data,
        'expired': _badgeCountCache!.isExpired,
      } : null,
      'predictions': _predictionsCache != null ? {
        'count': _predictionsCache!.data.length,
        'expired': _predictionsCache!.isExpired,
      } : null,
      'mlAlerts': _mlAlertsCache != null ? {
        'count': _mlAlertsCache!.data.length,
        'expired': _mlAlertsCache!.isExpired,
      } : null,
      'sensorCacheSize': _sensorCache.length,
    };
  }
}
