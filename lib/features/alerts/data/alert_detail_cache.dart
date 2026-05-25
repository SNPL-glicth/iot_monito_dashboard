import '../../crm/data/models/crm_alerts_models.dart';

/// Cache en memoria de alertas ya vistas en la sesión.
/// Evita recargar del API al volver a abrir una alerta.
class AlertDetailCache {
  static final AlertDetailCache _instance = AlertDetailCache._internal();
  factory AlertDetailCache() => _instance;
  AlertDetailCache._internal();

  final Map<String, CrmAlertHistoryItem> _cache = {};

  CrmAlertHistoryItem? get(String alertId) => _cache[alertId];

  void set(String alertId, CrmAlertHistoryItem alert) {
    _cache[alertId] = alert;
  }

  bool has(String alertId) => _cache.containsKey(alertId);

  void invalidate(String alertId) {
    _cache.remove(alertId);
  }

  void clear() => _cache.clear();
}
