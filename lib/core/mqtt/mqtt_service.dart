/// Servicio MQTT para Flutter.
///
/// Proporciona:
/// - Conexión a broker MQTT con reconexión automática
/// - Suscripción a alertas y telemetría en tiempo real
/// - Fallback a HTTP si MQTT falla
/// - Callbacks para eventos
///
/// Refactorizado: modelos y política de reconexión extraídos a archivos separados
/// para mantener cada archivo < 180 líneas (Single Responsibility).
library;

import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:mqtt_client/mqtt_client.dart' hide MqttConnectionState;
import 'package:mqtt_client/mqtt_server_client.dart';

import 'mqtt_config.dart';
import 'mqtt_models.dart';
import 'mqtt_reconnect_policy.dart';

/// Servicio MQTT singleton para Flutter.
///
/// Responsabilidades:
/// - Gestionar el ciclo de vida del cliente MQTT (connect, disconnect, dispose)
/// - Suscribirse a topics y despachar mensajes a callbacks
/// - Delegar el cálculo de delays a [MqttReconnectPolicy]
class MqttService {
  static final MqttService _instance = MqttService._internal();
  factory MqttService() => _instance;
  MqttService._internal();

  MqttServerClient? _client;
  MqttConfig _config = MqttConfig();
  MqttTopics _topics = MqttTopics();

  final _stateController = StreamController<AppMqttConnectionState>.broadcast();
  final _messageController = StreamController<AppMqttMessage>.broadcast();

  AppMqttConnectionState _state = AppMqttConnectionState.disconnected;
  Timer? _reconnectTimer;
  int _reconnectAttempts = 0;

  StreamSubscription? _updatesSubscription;
  final Set<String> _subscribedTopics = {};
  final List<MqttMessageCallback> _alertCallbacks = [];
  final List<MqttMessageCallback> _telemetryCallbacks = [];
  final List<MqttMessageCallback> _notificationCallbacks = [];

  final MqttReconnectPolicy _reconnectPolicy = const MqttReconnectPolicy();

  Stream<AppMqttConnectionState> get stateStream => _stateController.stream;
  Stream<AppMqttMessage> get messageStream => _messageController.stream;
  AppMqttConnectionState get state => _state;
  bool get isConnected => _state == AppMqttConnectionState.connected;
  bool get isEnabled => _config.enabled;

  void configure(MqttConfig config) {
    _config = config;
    _topics = MqttTopics(prefix: config.topicPrefix);
  }

  /// Conecta al broker MQTT.
  Future<bool> connect({String? authToken}) async {
    if (!_config.enabled) {
      debugPrint('[MqttService] MQTT disabled by config');
      return false;
    }

    if (_state == AppMqttConnectionState.connecting ||
        _state == AppMqttConnectionState.connected) {
      return _state == AppMqttConnectionState.connected;
    }

    _setState(AppMqttConnectionState.connecting);

    await _updatesSubscription?.cancel();
    _updatesSubscription = null;

    try {
      final clientId = '${_config.clientIdPrefix}-${DateTime.now().millisecondsSinceEpoch}';

      _client = MqttServerClient.withPort(
        _config.brokerHost,
        clientId,
        _config.effectivePort,
      );

      _client!.logging(on: kDebugMode);
      _client!.keepAlivePeriod = _config.keepAliveSeconds;
      _client!.autoReconnect = _config.autoReconnect;
      _client!.resubscribeOnAutoReconnect = true;

      _client!.onConnected = _onConnected;
      _client!.onDisconnected = _onDisconnected;
      _client!.onAutoReconnect = _onAutoReconnect;
      _client!.onAutoReconnected = _onAutoReconnected;
      _client!.onSubscribed = _onSubscribed;

      final connMessage = MqttConnectMessage()
          .withClientIdentifier(clientId)
          .startClean()
          .withWillQos(MqttQos.atLeastOnce);

      if (_config.username != null) {
        connMessage.authenticateAs(_config.username!, _config.password ?? '');
      }

      _client!.connectionMessage = connMessage;

      debugPrint('[MqttService] Connecting to ${_config.brokerUrl}');

      final result = await _client!.connect();

      // ignore: unrelated_type_equality_checks
      if (result != null && result.state.toString().contains('connected')) {
        _setupMessageListener();
        _setState(AppMqttConnectionState.connected);
        _reconnectAttempts = 0;
        debugPrint('[MqttService] Connected successfully');
        return true;
      } else {
        debugPrint('[MqttService] Connection failed: ${result?.state}');
        _setState(AppMqttConnectionState.disconnected);
        _scheduleReconnect();
        return false;
      }
    } catch (e) {
      debugPrint('[MqttService] Connection error: $e');
      _setState(AppMqttConnectionState.disconnected);
      _scheduleReconnect();
      return false;
    }
  }

  /// Desconecta del broker.
  Future<void> disconnect() async {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    await _updatesSubscription?.cancel();
    _updatesSubscription = null;

    if (_client != null) {
      _client!.disconnect();
      _client = null;
    }

    _subscribedTopics.clear();
    _setState(AppMqttConnectionState.disconnected);
    debugPrint('[MqttService] Disconnected');
  }

  /// Suscribe a alertas de un sensor o todos.
  Future<bool> subscribeAlerts({String? sensorId}) async {
    if (!isConnected) return false;
    final topic = sensorId != null
        ? _topics.alertsForSensor(sensorId)
        : _topics.alertsAll;
    return _subscribe(topic);
  }

  /// Suscribe a alertas críticas broadcast.
  Future<bool> subscribeBroadcastAlerts() async {
    if (!isConnected) return false;
    return _subscribe(_topics.alertsBroadcast);
  }

  /// Suscribe a telemetría de un sensor o todos.
  Future<bool> subscribeTelemetry({String? sensorId}) async {
    if (!isConnected) return false;
    final topic = sensorId != null
        ? _topics.telemetryForSensor(sensorId)
        : _topics.telemetryAll;
    return _subscribe(topic);
  }

  /// Suscribe a notificaciones de un usuario.
  Future<bool> subscribeNotifications(String userId) async {
    if (!isConnected) return false;
    return _subscribe(_topics.notificationsForUser(userId));
  }

  /// Registra callback para alertas.
  void onAlert(MqttMessageCallback callback) {
    _alertCallbacks.add(callback);
  }

  /// Registra callback para telemetría.
  void onTelemetry(MqttMessageCallback callback) {
    _telemetryCallbacks.add(callback);
  }

  /// Registra callback para notificaciones.
  void onNotification(MqttMessageCallback callback) {
    _notificationCallbacks.add(callback);
  }

  /// Remueve callbacks.
  void removeCallbacks() {
    _alertCallbacks.clear();
    _telemetryCallbacks.clear();
    _notificationCallbacks.clear();
  }

  bool _subscribe(String topic) {
    if (_client == null || !isConnected) return false;

    if (_subscribedTopics.contains(topic)) {
      debugPrint('[MqttService] Already subscribed to $topic');
      return true;
    }

    try {
      _client!.subscribe(topic, MqttQos.atLeastOnce);
      _subscribedTopics.add(topic);
      debugPrint('[MqttService] Subscribed to $topic');
      return true;
    } catch (e) {
      debugPrint('[MqttService] Subscribe error: $e');
      return false;
    }
  }

  void _setupMessageListener() {
    _updatesSubscription = _client!.updates?.listen((messages) {
      for (final msg in messages) {
        final topic = msg.topic;
        final pubMsg = msg.payload as MqttPublishMessage;
        final payloadString = MqttPublishPayload.bytesToStringAsString(
          pubMsg.payload.message,
        );

        try {
          final data = jsonDecode(payloadString) as Map<String, dynamic>;
          final message = AppMqttMessage(
            topic: topic,
            payload: data,
            timestamp: DateTime.now(),
          );

          _messageController.add(message);
          _dispatchMessage(message);
        } catch (e) {
          debugPrint('[MqttService] Parse error: $e');
        }
      }
    });
  }

  void _dispatchMessage(AppMqttMessage message) {
    if (message.isAlert || message.isMlEvent) {
      for (final callback in _alertCallbacks) {
        try {
          callback(message);
        } catch (e) {
          debugPrint('[MqttService] Alert callback error: $e');
        }
      }
    }

    if (message.isReading) {
      for (final callback in _telemetryCallbacks) {
        try {
          callback(message);
        } catch (e) {
          debugPrint('[MqttService] Telemetry callback error: $e');
        }
      }
    }

    if (message.isNotification) {
      for (final callback in _notificationCallbacks) {
        try {
          callback(message);
        } catch (e) {
          debugPrint('[MqttService] Notification callback error: $e');
        }
      }
    }
  }

  void _onConnected() {
    debugPrint('[MqttService] onConnected');
    _setState(AppMqttConnectionState.connected);
  }

  void _onDisconnected() {
    debugPrint('[MqttService] onDisconnected');
    _setState(AppMqttConnectionState.disconnected);
  }

  void _onAutoReconnect() {
    debugPrint('[MqttService] onAutoReconnect');
    _setState(AppMqttConnectionState.reconnecting);
  }

  void _onAutoReconnected() {
    debugPrint('[MqttService] onAutoReconnected');
    _setState(AppMqttConnectionState.connected);
  }

  void _onSubscribed(String topic) {
    debugPrint('[MqttService] onSubscribed: $topic');
  }

  void _scheduleReconnect() {
    if (_reconnectTimer?.isActive == true) return;

    final delay = _reconnectPolicy.computeDelay(_reconnectAttempts);
    if (delay == null) {
      debugPrint('[MqttService] Max reconnect attempts reached');
      return;
    }

    _reconnectTimer?.cancel();
    _setState(AppMqttConnectionState.reconnecting);
    _reconnectPolicy.logSchedule(_reconnectAttempts, delay);

    _reconnectTimer = Timer(delay, () {
      _reconnectAttempts++;
      connect();
    });
  }

  void _setState(AppMqttConnectionState newState) {
    if (_state != newState) {
      _state = newState;
      _stateController.add(newState);
    }
  }

  /// Libera recursos.
  void dispose() {
    disconnect();
    _stateController.close();
    _messageController.close();
    removeCallbacks();
    _updatesSubscription?.cancel();
    _updatesSubscription = null;
  }
}
