/// Servicio de notificaciones MQTT para Flutter.
///
/// Proporciona entrega instantánea de:
/// - Notificaciones de usuario
/// - Alertas de umbral
/// - Alertas críticas broadcast
///
/// CARACTERÍSTICAS:
/// - QoS 1 (garantía de entrega)
/// - Reconexión automática
/// - Sin duplicados (idempotencia por msgId)
/// - Fallback a HTTP polling
/// - Badge en campana
/// - Navegación directa a alerta
library;

import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart';

import '../mqtt/mqtt_service.dart';

/// Notificación recibida por MQTT.
class MqttNotification {
  const MqttNotification({
    required this.id,
    required this.source,
    required this.severity,
    required this.title,
    required this.message,
    required this.timestamp,
    this.sensorId,
    this.sensorName,
    this.deviceName,
    this.alertId,
  });

  final String id;
  final String source;
  final String severity;
  final String title;
  final String? message;
  final DateTime timestamp;
  final String? sensorId;
  final String? sensorName;
  final String? deviceName;
  final String? alertId;

  factory MqttNotification.fromMqttMessage(MqttMessage message) {
    final metadata = message.metadata ?? {};
    return MqttNotification(
      id: metadata['notificationId'] as String? ?? 
          metadata['alertId'] as String? ?? 
          message.payload['msgId'] as String? ?? 
          DateTime.now().millisecondsSinceEpoch.toString(),
      source: metadata['source'] as String? ?? message.type ?? 'unknown',
      severity: metadata['severity'] as String? ?? 'info',
      title: metadata['title'] as String? ?? 'Notificación',
      message: metadata['message'] as String?,
      timestamp: DateTime.tryParse(message.payload['timestamp'] as String? ?? '') ?? 
                 DateTime.now(),
      sensorId: message.sensorId,
      sensorName: metadata['sensorName'] as String?,
      deviceName: metadata['deviceName'] as String?,
      alertId: metadata['alertId'] as String?,
    );
  }

  bool get isCritical => severity == 'critical';
  bool get isWarning => severity == 'warning';
  bool get isAlert => source == 'alert' || source == 'alert_event';
  bool get isMlEvent => source == 'ml_event';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MqttNotification && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// Callback para notificaciones.
typedef NotificationCallback = void Function(MqttNotification notification);

/// Callback para cambio de badge.
typedef BadgeCallback = void Function(int count);

/// Servicio de notificaciones MQTT.
class MqttNotificationService {
  // Singleton
  static final MqttNotificationService _instance = MqttNotificationService._internal();
  factory MqttNotificationService() => _instance;
  MqttNotificationService._internal();

  final MqttService _mqttService = MqttService();

  // Callbacks
  final List<NotificationCallback> _notificationCallbacks = [];
  final List<NotificationCallback> _alertCallbacks = [];
  final List<BadgeCallback> _badgeCallbacks = [];

  // Buffer de notificaciones (para badge y lista)
  final Queue<MqttNotification> _notifications = Queue();
  static const int _maxNotifications = 100;

  // Deduplicación
  final Set<String> _seenIds = {};
  static const int _maxSeenIds = 1000;

  // Estado
  bool _initialized = false;
  String? _currentUserId;
  int _unreadCount = 0;

  /// Número de notificaciones no leídas.
  int get unreadCount => _unreadCount;

  /// Lista de notificaciones recientes.
  List<MqttNotification> get notifications => _notifications.toList();

  /// Indica si está conectado a MQTT.
  bool get isConnected => _mqttService.isConnected;

  /// Indica si MQTT está habilitado.
  bool get isEnabled => _mqttService.isEnabled;

  /// Inicializa el servicio para un usuario.
  Future<void> initialize(String userId) async {
    if (_initialized && _currentUserId == userId) return;

    _currentUserId = userId;

    if (!_mqttService.isEnabled) {
      debugPrint('[MqttNotification] MQTT disabled');
      return;
    }

    // Conectar si no está conectado
    if (!_mqttService.isConnected) {
      await _mqttService.connect();
    }

    // Registrar callbacks
    _mqttService.onNotification(_onNotificationMessage);
    _mqttService.onAlert(_onAlertMessage);

    // Suscribir a topics
    if (_mqttService.isConnected) {
      await _mqttService.subscribeNotifications(userId);
      await _mqttService.subscribeBroadcastAlerts();
    }

    _initialized = true;
    debugPrint('[MqttNotification] Initialized for user $userId');
  }

  /// Suscribe a alertas de un sensor específico.
  Future<bool> subscribeToSensor(String sensorId) async {
    if (!_mqttService.isConnected) return false;
    return _mqttService.subscribeAlerts(sensorId: sensorId);
  }

  /// Registra callback para notificaciones.
  void onNotification(NotificationCallback callback) {
    _notificationCallbacks.add(callback);
  }

  /// Registra callback para alertas.
  void onAlert(NotificationCallback callback) {
    _alertCallbacks.add(callback);
  }

  /// Registra callback para cambio de badge.
  void onBadgeChange(BadgeCallback callback) {
    _badgeCallbacks.add(callback);
    // Notificar estado actual
    callback(_unreadCount);
  }

  /// Marca notificación como leída.
  void markAsRead(String notificationId) {
    _notifications.removeWhere((n) => n.id == notificationId);
    _updateUnreadCount();
  }

  /// Marca todas las notificaciones como leídas.
  void markAllAsRead() {
    _notifications.clear();
    _updateUnreadCount();
  }

  /// Limpia callbacks.
  void removeCallbacks() {
    _notificationCallbacks.clear();
    _alertCallbacks.clear();
    _badgeCallbacks.clear();
  }

  void _onNotificationMessage(MqttMessage message) {
    if (!message.isNotification) return;
    
    final notification = MqttNotification.fromMqttMessage(message);
    _processNotification(notification);
  }

  void _onAlertMessage(MqttMessage message) {
    if (!message.isAlert && !message.isMlEvent) return;
    
    final notification = MqttNotification.fromMqttMessage(message);
    _processAlert(notification);
  }

  void _processNotification(MqttNotification notification) {
    // Deduplicación
    if (_seenIds.contains(notification.id)) {
      debugPrint('[MqttNotification] Duplicate notification ${notification.id}, skipping');
      return;
    }
    _markSeen(notification.id);

    // Agregar a buffer
    _addToBuffer(notification);

    // Notificar callbacks
    for (final callback in _notificationCallbacks) {
      try {
        callback(notification);
      } catch (e) {
        debugPrint('[MqttNotification] Callback error: $e');
      }
    }

    debugPrint('[MqttNotification] Received: ${notification.title}');
  }

  void _processAlert(MqttNotification notification) {
    // Deduplicación
    if (_seenIds.contains(notification.id)) {
      return;
    }
    _markSeen(notification.id);

    // Agregar a buffer si es crítica o warning
    if (notification.isCritical || notification.isWarning) {
      _addToBuffer(notification);
    }

    // Notificar callbacks de alerta
    for (final callback in _alertCallbacks) {
      try {
        callback(notification);
      } catch (e) {
        debugPrint('[MqttNotification] Alert callback error: $e');
      }
    }

    // Log especial para críticas
    if (notification.isCritical) {
      debugPrint('[MqttNotification] CRITICAL ALERT: ${notification.title}');
    }
  }

  void _addToBuffer(MqttNotification notification) {
    _notifications.addFirst(notification);
    
    // Mantener tamaño máximo
    while (_notifications.length > _maxNotifications) {
      _notifications.removeLast();
    }

    _updateUnreadCount();
  }

  void _updateUnreadCount() {
    final newCount = _notifications.length;
    if (newCount != _unreadCount) {
      _unreadCount = newCount;
      
      // Notificar callbacks de badge
      for (final callback in _badgeCallbacks) {
        try {
          callback(_unreadCount);
        } catch (e) {
          debugPrint('[MqttNotification] Badge callback error: $e');
        }
      }
    }
  }

  void _markSeen(String id) {
    _seenIds.add(id);
    
    // Limpiar IDs viejos
    if (_seenIds.length > _maxSeenIds) {
      final toRemove = _seenIds.take(_maxSeenIds ~/ 2).toList();
      for (final id in toRemove) {
        _seenIds.remove(id);
      }
    }
  }

  /// Libera recursos.
  void dispose() {
    removeCallbacks();
    _notifications.clear();
    _seenIds.clear();
    _initialized = false;
    _currentUserId = null;
    debugPrint('[MqttNotification] Disposed');
  }
}
