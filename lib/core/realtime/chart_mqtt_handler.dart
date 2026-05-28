import 'dart:async';

import 'package:flutter/foundation.dart';

import 'mqtt_telemetry_service.dart';
import 'telemetry_point.dart';

/// Maneja la conexion MQTT y el monitoreo de reconexion para graficas.
class ChartMqttHandler {
  ChartMqttHandler({
    required this.sensorId,
    required this.onPoint,
    required this.onStateChange,
    required this.mqttService,
  });

  final String sensorId;
  final void Function(TelemetryPoint point) onPoint;
  final void Function(bool usingMqtt) onStateChange;
  final MqttTelemetryService mqttService;

  Timer? _monitorTimer;
  bool _started = false;
  bool _wasConnected = false;

  Future<bool> start() async {
    if (!mqttService.isEnabled) return false;
    try {
      await mqttService.initialize();
      final success = await mqttService.subscribeSensor(sensorId, onPoint);
      if (success) {
        _wasConnected = true;
        _startMonitoring();
      }
      return success;
    } catch (e) {
      debugPrint('[ChartMqttHandler] MQTT start failed: $e');
      return false;
    }
  }

  void stop() {
    _started = false;
    _monitorTimer?.cancel();
    _monitorTimer = null;
    mqttService.unsubscribeSensor(sensorId);
  }

  void _startMonitoring() {
    if (_monitorTimer != null) return;
    _started = true;
    _monitorTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (!_started) {
        timer.cancel();
        return;
      }
      final isConnected = mqttService.isConnected;
      if (!isConnected && _wasConnected) {
        debugPrint('[ChartMqttHandler] MQTT disconnected, switching to HTTP');
        _wasConnected = false;
        onStateChange(false);
      } else if (isConnected && !_wasConnected) {
        debugPrint('[ChartMqttHandler] MQTT reconnected, switching back');
        _wasConnected = true;
        onStateChange(true);
      }
    });
  }
}
