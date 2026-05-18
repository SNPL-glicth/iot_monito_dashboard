// WRAPPER PATTERN: Extiende UnifiedAlertItem con gestión de estado
// SIN modificar el modelo original para mantener compatibilidad
import 'unified_alert_item.dart';

/// Estados posibles de una alerta
enum AlertState {
  /// Alerta activa, requiere atención
  active,
  
  /// Alerta reconocida pero no resuelta
  acknowledged,
  
  /// Alerta resuelta
  resolved,
  
  /// Alerta expirada por TTL
  expired,
}

/// Wrapper que añade gestión de estado a UnifiedAlertItem
/// Implementa el patrón Decorator para extender sin modificar
class AlertWithState {
  AlertWithState({
    required this.alert,
    required this.state,
    this.acknowledgedAt,
    this.acknowledgedBy,
    this.resolvedAt,
    this.resolvedBy,
    this.ttlSeconds,
  });

  /// Alerta original (sin modificar)
  final UnifiedAlertItem alert;
  
  /// Estado actual de la alerta
  final AlertState state;
  
  /// Timestamp de reconocimiento
  final DateTime? acknowledgedAt;
  
  /// Usuario que reconoció
  final String? acknowledgedBy;
  
  /// Timestamp de resolución
  final DateTime? resolvedAt;
  
  /// Usuario que resolvió
  final String? resolvedBy;
  
  /// TTL en segundos (para auto-expiración)
  final int? ttlSeconds;

  /// Crea desde UnifiedAlertItem con estado por defecto
  factory AlertWithState.fromUnified(UnifiedAlertItem alert) {
    final state = _parseState(alert.status);
    return AlertWithState(
      alert: alert,
      state: state,
    );
  }

  /// Parsea el status string a AlertState
  static AlertState _parseState(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return AlertState.active;
      case 'acknowledged':
      case 'ack':
        return AlertState.acknowledged;
      case 'resolved':
        return AlertState.resolved;
      case 'expired':
        return AlertState.expired;
      default:
        return AlertState.active;
    }
  }

  /// True si la alerta requiere atención (activa o reconocida)
  bool get requiresAttention => 
      state == AlertState.active || state == AlertState.acknowledged;

  /// True si la alerta está activa (no resuelta ni expirada)
  bool get isActive => state == AlertState.active;

  /// True si la alerta fue reconocida
  bool get isAcknowledged => state == AlertState.acknowledged;

  /// True si la alerta está resuelta
  bool get isResolved => state == AlertState.resolved;

  /// Delegación de propiedades del alert original
  String get id => alert.id;
  String get source => alert.source;
  String get severity => alert.severity;
  String get title => alert.title;
  String get deviceName => alert.deviceName;
  String? get sensorId => alert.sensorId;
  String? get sensorName => alert.sensorName;
  String get occurredAt => alert.occurredAt;
  String? get message => alert.message;
  String? get value => alert.value;
  String? get eventCode => alert.eventCode;

  /// Crea una copia con nuevo estado
  AlertWithState copyWith({
    AlertState? state,
    DateTime? acknowledgedAt,
    String? acknowledgedBy,
    DateTime? resolvedAt,
    String? resolvedBy,
  }) {
    return AlertWithState(
      alert: alert,
      state: state ?? this.state,
      acknowledgedAt: acknowledgedAt ?? this.acknowledgedAt,
      acknowledgedBy: acknowledgedBy ?? this.acknowledgedBy,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      resolvedBy: resolvedBy ?? this.resolvedBy,
      ttlSeconds: ttlSeconds,
    );
  }
}

/// Agrupa alertas por sensor para mostrar independencia
class SensorAlertGroup {
  SensorAlertGroup({
    required this.sensorId,
    required this.sensorName,
    required this.deviceName,
    required this.alerts,
  });

  final String sensorId;
  final String sensorName;
  final String deviceName;
  final List<AlertWithState> alerts;

  /// Número de alertas activas en este sensor
  int get activeCount => alerts.where((a) => a.isActive).length;

  /// Número de alertas críticas activas
  int get criticalCount => alerts
      .where((a) => a.isActive && a.severity.toLowerCase() == 'critical')
      .length;

  /// Número de warnings activos
  int get warningCount => alerts
      .where((a) => a.isActive && a.severity.toLowerCase() == 'warning')
      .length;

  /// Alerta más severa activa
  AlertWithState? get mostSevereActive {
    final active = alerts.where((a) => a.isActive).toList();
    if (active.isEmpty) return null;
    
    // Ordenar por severidad (critical > warning > info)
    active.sort((a, b) {
      final rankA = _severityRank(a.severity);
      final rankB = _severityRank(b.severity);
      return rankA.compareTo(rankB);
    });
    
    return active.first;
  }

  static int _severityRank(String severity) {
    switch (severity.toLowerCase()) {
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

  /// Agrupa lista de alertas por sensor
  static List<SensorAlertGroup> groupBySensor(List<AlertWithState> alerts) {
    final Map<String, List<AlertWithState>> grouped = {};
    
    for (final alert in alerts) {
      final key = alert.sensorId ?? 'unknown';
      grouped.putIfAbsent(key, () => []);
      grouped[key]!.add(alert);
    }
    
    return grouped.entries.map((entry) {
      final sensorAlerts = entry.value;
      final first = sensorAlerts.first;
      
      return SensorAlertGroup(
        sensorId: entry.key,
        sensorName: first.sensorName ?? 'Sensor desconocido',
        deviceName: first.deviceName,
        alerts: sensorAlerts,
      );
    }).toList();
  }
}
