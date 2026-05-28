import 'dart:collection';

import 'telemetry_point.dart';

/// Maneja buffers y deduplicacion por timestamp para telemetria MQTT.
class MqttTelemetryBuffer {
  MqttTelemetryBuffer({this.maxBufferSize = 500});

  final int maxBufferSize;
  final Map<String, Queue<TelemetryPoint>> _buffers = {};
  final Map<String, DateTime> _lastTimestamps = {};

  void ensureBuffer(String sensorId) {
    _buffers.putIfAbsent(sensorId, () => Queue<TelemetryPoint>());
  }

  bool tryAdd(String sensorId, TelemetryPoint point) {
    ensureBuffer(sensorId);
    final lastTs = _lastTimestamps[sensorId];
    if (lastTs != null && !point.timestamp.isAfter(lastTs)) {
      return false;
    }
    _lastTimestamps[sensorId] = point.timestamp;
    final buffer = _buffers[sensorId]!;
    buffer.add(point);
    while (buffer.length > maxBufferSize) {
      buffer.removeFirst();
    }
    return true;
  }

  List<TelemetryPoint> getBuffer(String sensorId) {
    return _buffers[sensorId]?.toList() ?? [];
  }

  void clearSensor(String sensorId) {
    _buffers[sensorId]?.clear();
    _lastTimestamps.remove(sensorId);
  }

  void clearAll() {
    _buffers.clear();
    _lastTimestamps.clear();
  }
}
