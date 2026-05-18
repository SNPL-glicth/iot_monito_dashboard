/// Servicio de telemetría MQTT para gráficas en tiempo real.
///
/// Reemplaza polling HTTP por push MQTT.
/// Mantiene HTTP como fallback.
///
/// FLUJO:
///   telemetry_iot → MQTT topic: iot/telemetry/{sensorId}/realtime → Flutter
///
/// CARACTERÍSTICAS:
/// - Suscripción por sensor
/// - Fallback automático a HTTP
/// - Deduplicación por timestamp
/// - Ordenamiento por timestamp
/// - Sin memory leaks (dispose correcto)
library;

import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart';

import '../mqtt/mqtt_service.dart';

/// Punto de telemetría recibido.
class TelemetryPoint {
  const TelemetryPoint({
    required this.sensorId,
    required this.value,
    required this.timestamp,
    required this.state,
  });

  final String sensorId;
  final double value;
  final DateTime timestamp;
  final String state;

  factory TelemetryPoint.fromMqttMessage(MqttMessage message) {
    return TelemetryPoint(
      sensorId: message.sensorId ?? '',
      value: message.value ?? 0.0,
      timestamp: DateTime.tryParse(message.payload['timestamp'] as String? ?? '') ?? 
                 DateTime.now(),
      state: message.metadata?['state'] as String? ?? 'normal',
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TelemetryPoint &&
          sensorId == other.sensorId &&
          timestamp == other.timestamp;

  @override
  int get hashCode => Object.hash(sensorId, timestamp);
}

/// Callback para puntos de telemetría.
typedef TelemetryCallback = void Function(TelemetryPoint point);

/// Servicio de telemetría MQTT.
///
/// Uso:
/// ```dart
/// final service = MqttTelemetryService();
/// await service.subscribeSensor('42', (point) {
///   // Actualizar gráfica
/// });
/// ```
class MqttTelemetryService {
  // Singleton
  static final MqttTelemetryService _instance = MqttTelemetryService._internal();
  factory MqttTelemetryService() => _instance;
  MqttTelemetryService._internal();

  final MqttService _mqttService = MqttService();
  
  // Callbacks por sensor
  final Map<String, List<TelemetryCallback>> _callbacks = {};
  
  // Buffer de puntos por sensor (para gráficas)
  final Map<String, Queue<TelemetryPoint>> _buffers = {};
  static const int _maxBufferSize = 500;
  
  // Deduplicación
  final Map<String, DateTime> _lastTimestamps = {};
  
  // Estado
  bool _initialized = false;
  StreamSubscription? _messageSubscription;
  
  // Estadísticas
  int _pointsReceived = 0;
  int _pointsDeduplicated = 0;
  int _pointsDelivered = 0;

  /// Indica si MQTT está conectado.
  bool get isConnected => _mqttService.isConnected;

  /// Indica si MQTT está habilitado.
  bool get isEnabled => _mqttService.isEnabled;

  /// Estadísticas del servicio.
  Map<String, dynamic> get stats => {
    'connected': isConnected,
    'enabled': isEnabled,
    'pointsReceived': _pointsReceived,
    'pointsDeduplicated': _pointsDeduplicated,
    'pointsDelivered': _pointsDelivered,
    'subscribedSensors': _callbacks.keys.toList(),
  };

  /// Inicializa el servicio.
  Future<void> initialize() async {
    if (_initialized) return;
    
    if (!_mqttService.isEnabled) {
      debugPrint('[MqttTelemetry] MQTT disabled');
      return;
    }

    // Conectar si no está conectado
    if (!_mqttService.isConnected) {
      await _mqttService.connect();
    }

    // Escuchar mensajes de telemetría
    _messageSubscription = _mqttService.messageStream.listen(_onMessage);
    
    // Registrar callback global de telemetría
    _mqttService.onTelemetry(_onTelemetryMessage);

    _initialized = true;
    debugPrint('[MqttTelemetry] Initialized');
  }

  /// Suscribe a telemetría de un sensor.
  ///
  /// [sensorId] - ID del sensor
  /// [callback] - Callback para cada punto recibido
  ///
  /// Retorna true si la suscripción fue exitosa.
  Future<bool> subscribeSensor(String sensorId, TelemetryCallback callback) async {
    if (!_initialized) {
      await initialize();
    }

    // Agregar callback
    _callbacks.putIfAbsent(sensorId, () => []);
    _callbacks[sensorId]!.add(callback);

    // Inicializar buffer
    _buffers.putIfAbsent(sensorId, () => Queue<TelemetryPoint>());

    // Suscribir a MQTT si está conectado
    if (_mqttService.isConnected) {
      final success = await _mqttService.subscribeTelemetry(sensorId: sensorId);
      debugPrint('[MqttTelemetry] Subscribed to sensor $sensorId: $success');
      return success;
    }

    debugPrint('[MqttTelemetry] MQTT not connected, will use HTTP fallback');
    return false;
  }

  /// Desuscribe de un sensor.
  void unsubscribeSensor(String sensorId) {
    _callbacks.remove(sensorId);
    _buffers.remove(sensorId);
    _lastTimestamps.remove(sensorId);
    debugPrint('[MqttTelemetry] Unsubscribed from sensor $sensorId');
  }

  /// Obtiene buffer de puntos para un sensor.
  List<TelemetryPoint> getBuffer(String sensorId) {
    return _buffers[sensorId]?.toList() ?? [];
  }

  /// Limpia buffer de un sensor.
  void clearBuffer(String sensorId) {
    _buffers[sensorId]?.clear();
  }

  void _onMessage(MqttMessage message) {
    // Solo procesar mensajes de telemetría
    if (!message.isReading) return;
    _onTelemetryMessage(message);
  }

  void _onTelemetryMessage(MqttMessage message) {
    _pointsReceived++;

    final sensorId = message.sensorId;
    if (sensorId == null) return;

    // Verificar si tenemos callbacks para este sensor
    final callbacks = _callbacks[sensorId];
    if (callbacks == null || callbacks.isEmpty) return;

    // Parsear punto
    final point = TelemetryPoint.fromMqttMessage(message);

    // Deduplicación por timestamp
    final lastTs = _lastTimestamps[sensorId];
    if (lastTs != null && !point.timestamp.isAfter(lastTs)) {
      _pointsDeduplicated++;
      return;
    }
    _lastTimestamps[sensorId] = point.timestamp;

    // Agregar a buffer
    final buffer = _buffers[sensorId];
    if (buffer != null) {
      buffer.add(point);
      // Mantener tamaño máximo
      while (buffer.length > _maxBufferSize) {
        buffer.removeFirst();
      }
    }

    // Notificar callbacks
    for (final callback in callbacks) {
      try {
        callback(point);
        _pointsDelivered++;
      } catch (e) {
        debugPrint('[MqttTelemetry] Callback error: $e');
      }
    }
  }

  /// Agrega punto manualmente (para fallback HTTP).
  void addPoint(TelemetryPoint point) {
    final sensorId = point.sensorId;
    
    // Deduplicación
    final lastTs = _lastTimestamps[sensorId];
    if (lastTs != null && !point.timestamp.isAfter(lastTs)) {
      return;
    }
    _lastTimestamps[sensorId] = point.timestamp;

    // Agregar a buffer
    final buffer = _buffers[sensorId];
    if (buffer != null) {
      buffer.add(point);
      while (buffer.length > _maxBufferSize) {
        buffer.removeFirst();
      }
    }

    // Notificar callbacks
    final callbacks = _callbacks[sensorId];
    if (callbacks != null) {
      for (final callback in callbacks) {
        try {
          callback(point);
        } catch (e) {
          debugPrint('[MqttTelemetry] Callback error: $e');
        }
      }
    }
  }

  /// Libera recursos.
  void dispose() {
    _messageSubscription?.cancel();
    _messageSubscription = null;
    _callbacks.clear();
    _buffers.clear();
    _lastTimestamps.clear();
    _initialized = false;
    debugPrint('[MqttTelemetry] Disposed');
  }
}
