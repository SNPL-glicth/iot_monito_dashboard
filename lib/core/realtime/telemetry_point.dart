import '../mqtt/mqtt_models.dart';

/// Punto de telemetria recibido.
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

  factory TelemetryPoint.fromAppMqttMessage(AppMqttMessage message) {
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

/// Callback para puntos de telemetria.
typedef TelemetryCallback = void Function(TelemetryPoint point);
