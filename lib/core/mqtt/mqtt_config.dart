/// Configuración MQTT para el cliente Flutter.
///
/// Soporta:
/// - Conexión a broker MQTT
/// - TLS/SSL
/// - Autenticación
/// - Feature flags
library;

import 'dart:io';

class MqttConfig {
  MqttConfig({
    this.brokerHost = 'localhost',
    this.brokerPort = 1883,
    this.brokerPortTls = 8883,
    this.useTls = false,
    this.username,
    this.password,
    this.clientIdPrefix = 'flutter',
    this.topicPrefix = 'iot',
    this.keepAliveSeconds = 60,
    this.autoReconnect = true,
    this.reconnectDelaySeconds = 5,
    this.enabled = false,
  });

  final String brokerHost;
  final int brokerPort;
  final int brokerPortTls;
  final bool useTls;
  final String? username;
  final String? password;
  final String clientIdPrefix;
  final String topicPrefix;
  final int keepAliveSeconds;
  final bool autoReconnect;
  final int reconnectDelaySeconds;
  final bool enabled;

  int get effectivePort => useTls ? brokerPortTls : brokerPort;

  String get brokerUrl => '${useTls ? "mqtts" : "mqtt"}://$brokerHost:$effectivePort';

  /// Crea configuración desde variables de entorno o defaults.
  factory MqttConfig.fromEnvironment() {
    final enabled = const String.fromEnvironment(
      'MQTT_ENABLED',
      defaultValue: 'false',
    ).toLowerCase() == 'true';

    return MqttConfig(
      brokerHost: const String.fromEnvironment(
        'MQTT_BROKER_HOST',
        defaultValue: 'localhost',
      ),
      brokerPort: int.tryParse(const String.fromEnvironment(
        'MQTT_BROKER_PORT',
        defaultValue: '1883',
      )) ?? 1883,
      useTls: const String.fromEnvironment(
        'MQTT_USE_TLS',
        defaultValue: 'false',
      ).toLowerCase() == 'true',
      topicPrefix: const String.fromEnvironment(
        'MQTT_TOPIC_PREFIX',
        defaultValue: 'iot',
      ),
      enabled: enabled,
    );
  }

  /// Crea configuración para desarrollo local.
  factory MqttConfig.development() {
    return MqttConfig(
      brokerHost: Platform.isAndroid ? '10.0.2.2' : 'localhost',
      brokerPort: 1883,
      useTls: false,
      enabled: true,
    );
  }

  /// Crea configuración para producción.
  factory MqttConfig.production({
    required String brokerHost,
    String? username,
    String? password,
  }) {
    return MqttConfig(
      brokerHost: brokerHost,
      brokerPort: 8883,
      brokerPortTls: 8883,
      useTls: true,
      username: username,
      password: password,
      enabled: true,
    );
  }

  MqttConfig copyWith({
    String? brokerHost,
    int? brokerPort,
    bool? useTls,
    String? username,
    String? password,
    bool? enabled,
  }) {
    return MqttConfig(
      brokerHost: brokerHost ?? this.brokerHost,
      brokerPort: brokerPort ?? this.brokerPort,
      useTls: useTls ?? this.useTls,
      username: username ?? this.username,
      password: password ?? this.password,
      enabled: enabled ?? this.enabled,
    );
  }
}

/// Topics MQTT del sistema IoT.
class MqttTopics {
  MqttTopics({this.prefix = 'iot'});

  final String prefix;

  String get alertsAll => '$prefix/alerts/#';
  String get alertsBroadcast => '$prefix/alerts/broadcast/critical';
  String get telemetryAll => '$prefix/telemetry/+/realtime';
  
  String alertsForSensor(String sensorId) => '$prefix/alerts/$sensorId/#';
  String telemetryForSensor(String sensorId) => '$prefix/telemetry/$sensorId/realtime';
  String notificationsForUser(String userId) => '$prefix/notifications/$userId/unread';
}
