/// Servicio de telemetria MQTT para graficas en tiempo real.
library;

import 'dart:async';

import 'package:flutter/foundation.dart';

import '../mqtt/mqtt_models.dart';
import '../mqtt/mqtt_service.dart';
import 'mqtt_telemetry_buffer.dart';
import 'telemetry_point.dart';

/// Servicio de telemetria MQTT.
class MqttTelemetryService {
  static final MqttTelemetryService _instance = MqttTelemetryService._internal();
  factory MqttTelemetryService() => _instance;
  MqttTelemetryService._internal();

  final MqttService _mqttService = MqttService();
  final MqttTelemetryBuffer _buffer = MqttTelemetryBuffer();

  final Map<String, List<TelemetryCallback>> _callbacks = {};
  bool _initialized = false;
  StreamSubscription? _messageSubscription;

  int _pointsReceived = 0;
  int _pointsDeduplicated = 0;
  int _pointsDelivered = 0;

  bool get isConnected => _mqttService.isConnected;
  bool get isEnabled => _mqttService.isEnabled;

  Map<String, dynamic> get stats => {
    'connected': isConnected,
    'enabled': isEnabled,
    'pointsReceived': _pointsReceived,
    'pointsDeduplicated': _pointsDeduplicated,
    'pointsDelivered': _pointsDelivered,
    'subscribedSensors': _callbacks.keys.toList(),
  };

  Future<void> initialize() async {
    if (_initialized) return;
    if (!_mqttService.isEnabled) {
      debugPrint('[MqttTelemetry] MQTT disabled');
      return;
    }
    if (!_mqttService.isConnected) {
      await _mqttService.connect();
    }
    _messageSubscription = _mqttService.messageStream.listen(_onMessage);
    _mqttService.onTelemetry(_onTelemetryMessage);
    _initialized = true;
    debugPrint('[MqttTelemetry] Initialized');
  }

  Future<bool> subscribeSensor(String sensorId, TelemetryCallback callback) async {
    if (!_initialized) await initialize();
    _callbacks.putIfAbsent(sensorId, () => []);
    _callbacks[sensorId]!.add(callback);
    _buffer.ensureBuffer(sensorId);
    if (_mqttService.isConnected) {
      final success = await _mqttService.subscribeTelemetry(sensorId: sensorId);
      debugPrint('[MqttTelemetry] Subscribed to sensor $sensorId: $success');
      return success;
    }
    debugPrint('[MqttTelemetry] MQTT not connected, will use HTTP fallback');
    return false;
  }

  void unsubscribeSensor(String sensorId) {
    _callbacks.remove(sensorId);
    _buffer.clearSensor(sensorId);
    debugPrint('[MqttTelemetry] Unsubscribed from sensor $sensorId');
  }

  List<TelemetryPoint> getBuffer(String sensorId) => _buffer.getBuffer(sensorId);

  void clearBuffer(String sensorId) => _buffer.clearSensor(sensorId);

  void _onMessage(AppMqttMessage message) {
    if (!message.isReading) return;
    _onTelemetryMessage(message);
  }

  void _onTelemetryMessage(AppMqttMessage message) {
    _pointsReceived++;
    final sensorId = message.sensorId;
    if (sensorId == null) return;
    final callbacks = _callbacks[sensorId];
    if (callbacks == null || callbacks.isEmpty) return;

    final point = TelemetryPoint.fromAppMqttMessage(message);
    final isNew = _buffer.tryAdd(sensorId, point);
    if (!isNew) {
      _pointsDeduplicated++;
      return;
    }

    for (final callback in callbacks) {
      try {
        callback(point);
        _pointsDelivered++;
      } catch (e) {
        debugPrint('[MqttTelemetry] Callback error: $e');
      }
    }
  }

  void addPoint(TelemetryPoint point) {
    final sensorId = point.sensorId;
    if (!_buffer.tryAdd(sensorId, point)) return;
    final callbacks = _callbacks[sensorId];
    if (callbacks == null) return;
    for (final callback in callbacks) {
      try {
        callback(point);
      } catch (e) {
        debugPrint('[MqttTelemetry] Callback error: $e');
      }
    }
  }

  void dispose() {
    _messageSubscription?.cancel();
    _messageSubscription = null;
    _callbacks.clear();
    _buffer.clearAll();
    _initialized = false;
    debugPrint('[MqttTelemetry] Disposed');
  }
}
