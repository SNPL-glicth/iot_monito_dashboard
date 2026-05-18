// WRAPPER PATTERN: Envuelve AlertsRepository existente con gestión de estado
// SIN modificar el repositorio original para mantener compatibilidad
import 'alerts_repository.dart';
import 'models/unified_alert_item.dart';
import 'models/alert_with_state.dart';

/// Repositorio que envuelve AlertsRepository con gestión de estado mejorada
/// Implementa el patrón Decorator para extender sin modificar
class StateAwareAlertRepository {
  // Singleton
  static final StateAwareAlertRepository _instance = StateAwareAlertRepository._internal();
  factory StateAwareAlertRepository() => _instance;
  StateAwareAlertRepository._internal();

  /// Repositorio original (sin modificar)
  final AlertsRepository _baseRepo = AlertsRepository();

  /// Cache de estados locales (para UI optimista)
  final Map<String, AlertState> _localStateCache = {};

  /// Obtiene alertas importantes con estado enriquecido
  Future<List<AlertWithState>> fetchImportantAlertsWithState({int limit = 50}) async {
    final alerts = await _baseRepo.fetchImportantAlerts(limit: limit);
    return _enrichWithState(alerts);
  }

  /// Obtiene eventos ML con estado enriquecido
  Future<List<AlertWithState>> fetchMlAlertsWithState({int limit = 50}) async {
    final alerts = await _baseRepo.fetchImportantMlAlerts(limit: limit);
    return _enrichWithState(alerts);
  }

  /// Obtiene alertas agrupadas por sensor
  Future<List<SensorAlertGroup>> fetchAlertsBySensor({int limit = 50}) async {
    final alertsWithState = await fetchImportantAlertsWithState(limit: limit);
    return SensorAlertGroup.groupBySensor(alertsWithState);
  }

  /// Obtiene solo alertas activas (no resueltas ni expiradas)
  Future<List<AlertWithState>> fetchActiveAlertsOnly({int limit = 50}) async {
    final all = await fetchImportantAlertsWithState(limit: limit);
    return all.where((a) => a.requiresAttention).toList();
  }

  /// Obtiene contadores de alertas activas por severidad
  Future<AlertCounters> fetchActiveCounters() async {
    final active = await fetchActiveAlertsOnly(limit: 200);
    
    int critical = 0;
    int warning = 0;
    int info = 0;
    
    for (final alert in active) {
      switch (alert.severity.toLowerCase()) {
        case 'critical':
          critical++;
          break;
        case 'warning':
          warning++;
          break;
        default:
          info++;
      }
    }
    
    return AlertCounters(
      total: active.length,
      critical: critical,
      warning: warning,
      info: info,
    );
  }

  /// Enriquece alertas con estado
  List<AlertWithState> _enrichWithState(List<UnifiedAlertItem> alerts) {
    return alerts.map((alert) {
      // Verificar si hay estado local cacheado
      final cachedState = _localStateCache[alert.id];
      
      if (cachedState != null) {
        return AlertWithState(
          alert: alert,
          state: cachedState,
        );
      }
      
      return AlertWithState.fromUnified(alert);
    }).toList();
  }

  /// Actualiza estado local (UI optimista)
  void updateLocalState(String alertId, AlertState newState) {
    _localStateCache[alertId] = newState;
  }

  /// Limpia cache de estados locales
  void clearLocalStateCache() {
    _localStateCache.clear();
  }

  /// Deduplica predicciones por sensor (solo la más reciente)
  Future<List<AlertWithState>> fetchDeduplicatedMlAlerts({int limit = 50}) async {
    final all = await fetchMlAlertsWithState(limit: limit * 2);
    
    // Agrupar por sensorId y quedarse solo con la más reciente
    final Map<String, AlertWithState> bySensor = {};
    
    for (final alert in all) {
      final key = alert.sensorId ?? 'unknown';
      
      // Si no existe o la nueva es más reciente, reemplazar
      if (!bySensor.containsKey(key)) {
        bySensor[key] = alert;
      } else {
        // Comparar timestamps (occurredAt)
        final existing = bySensor[key]!;
        if (_isMoreRecent(alert.occurredAt, existing.occurredAt)) {
          bySensor[key] = alert;
        }
      }
    }
    
    // Ordenar por severidad y fecha
    final result = bySensor.values.toList();
    result.sort((a, b) {
      final rankA = _severityRank(a.severity);
      final rankB = _severityRank(b.severity);
      if (rankA != rankB) return rankA.compareTo(rankB);
      return b.occurredAt.compareTo(a.occurredAt);
    });
    
    return result.take(limit).toList();
  }

  bool _isMoreRecent(String a, String b) {
    final dateA = _tryParseDate(a);
    final dateB = _tryParseDate(b);
    if (dateA == null || dateB == null) return false;
    return dateA.isAfter(dateB);
  }

  DateTime? _tryParseDate(String raw) {
    final iso = DateTime.tryParse(raw);
    if (iso != null) return iso;

    final parts = raw.split(' ');
    if (parts.length != 2) return null;

    final d = parts[0].split('/');
    final t = parts[1].split(':');
    if (d.length != 3 || t.length < 2) return null;

    final day = int.tryParse(d[0]);
    final month = int.tryParse(d[1]);
    final year = int.tryParse(d[2]);
    final hour = int.tryParse(t[0]);
    final minute = int.tryParse(t[1]);
    if ([day, month, year, hour, minute].any((x) => x == null)) return null;

    return DateTime(year!, month!, day!, hour!, minute!);
  }

  int _severityRank(String s) {
    switch (s.toLowerCase()) {
      case 'critical':
        return 0;
      case 'warning':
        return 1;
      case 'info':
      case 'notice':
        return 2;
      default:
        return 3;
    }
  }
}

/// Contadores de alertas activas
class AlertCounters {
  const AlertCounters({
    required this.total,
    required this.critical,
    required this.warning,
    required this.info,
  });

  final int total;
  final int critical;
  final int warning;
  final int info;

  /// Contadores vacíos
  static const empty = AlertCounters(
    total: 0,
    critical: 0,
    warning: 0,
    info: 0,
  );
}
