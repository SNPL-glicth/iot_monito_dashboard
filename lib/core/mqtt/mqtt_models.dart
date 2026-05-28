/// Modelos y tipos compartidos del servicio MQTT.
library;

/// Estado de conexión MQTT.
///
/// Renombrado a [AppMqttConnectionState] para evitar colisión con
/// `MqttConnectionState` del paquete `mqtt_client`.
enum AppMqttConnectionState {
  disconnected,
  connecting,
  connected,
  reconnecting,
}

/// Mensaje MQTT recibido.
///
/// Renombrado a [AppMqttMessage] para evitar colisión con
/// `MqttMessage` del paquete `mqtt_client`.
class AppMqttMessage {
  const AppMqttMessage({
    required this.topic,
    required this.payload,
    required this.timestamp,
  });

  final String topic;
  final Map<String, dynamic> payload;
  final DateTime timestamp;

  String? get sensorId => payload['sensorId'] as String?;
  double? get value => (payload['value'] as num?)?.toDouble();
  String? get type => payload['type'] as String?;
  Map<String, dynamic>? get metadata =>
      payload['metadata'] as Map<String, dynamic>?;

  String? get severity => metadata?['severity'] as String?;
  String? get eventType => metadata?['eventType'] as String?;
  String? get message => metadata?['message'] as String?;

  bool get isAlert => type == 'alert';
  bool get isMlEvent => type == 'ml_event';
  bool get isReading => type == 'reading';
  bool get isNotification => type == 'notification';

  @override
  String toString() => 'AppMqttMessage(topic: $topic, type: $type, sensorId: $sensorId)';
}

/// Callback para mensajes MQTT.
typedef MqttMessageCallback = void Function(AppMqttMessage message);
