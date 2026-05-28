/// Servicio de WebSocket para datos en tiempo real.
///
/// FIX FASE 3: Reemplaza polling HTTP por push WebSocket.
/// Reduce latencia y carga en el servidor.
///
/// Refactorizado: modelos y política de reconexión extraídos a archivos separados
/// para mantener cada archivo < 180 líneas (Single Responsibility).
library;

import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart' show debugPrint, visibleForTesting;
import 'package:web_socket_channel/web_socket_channel.dart';

import '../config/api_config.dart';
import '../cache/dashboard_cache_service.dart';
import 'realtime_models.dart';
import 'realtime_reconnect_policy.dart';

/// Servicio singleton para conexión WebSocket en tiempo real.
///
/// Responsabilidades:
/// - Gestionar el ciclo de vida del socket (connect, disconnect, dispose)
/// - Enviar/recibir mensajes con el backend NestJS
/// - Delegar el cálculo de delays a [RealtimeReconnectPolicy]
class RealtimeService {
  static final RealtimeService _instance = RealtimeService._internal();
  factory RealtimeService() => _instance;
  RealtimeService._internal();

  WebSocketChannel? _channel;
  StreamSubscription? _subscription;
  Timer? _reconnectTimer;
  Timer? _pingTimer;

  final _stateController = StreamController<RealtimeConnectionState>.broadcast();
  final _eventController = StreamController<RealtimeEvent>.broadcast();

  RealtimeConnectionState _state = RealtimeConnectionState.disconnected;
  int _reconnectAttempts = 0;
  static const Duration _pingInterval = Duration(seconds: 30);

  final DashboardCacheService _cacheService = DashboardCacheService();
  final RealtimeReconnectPolicy _reconnectPolicy = const RealtimeReconnectPolicy();

  String? _pendingAuthToken;
  bool _authFailed = false;
  bool _isReconnecting = false;

  Stream<RealtimeConnectionState> get stateStream => _stateController.stream;
  Stream<RealtimeEvent> get eventStream => _eventController.stream;
  RealtimeConnectionState get state => _state;
  bool get isConnected => _state == RealtimeConnectionState.connected;

  /// Conecta al servidor WebSocket.
  ///
  /// [authToken] se envía en el primer mensaje después del upgrade TCP,
  /// nunca en la URL. Esto evita que proxies/nginx/Cloudflare logueen el JWT.
  Future<void> connect({String? authToken}) async {
    if (_isReconnecting) {
      debugPrint('[RealtimeService] Reconnect already in progress, skipping');
      return;
    }

    if (_state == RealtimeConnectionState.connecting ||
        _state == RealtimeConnectionState.connected) {
      return;
    }

    _setState(RealtimeConnectionState.connecting);
    _isReconnecting = true;

    if (authToken != null && authToken.isNotEmpty) {
      _pendingAuthToken = authToken;
      _authFailed = false;
    }

    try {
      final wsUrl = buildWebSocketUrl();
      debugPrint('[RealtimeService] Connecting to $wsUrl');

      _channel = WebSocketChannel.connect(Uri.parse(wsUrl));

      _subscription = _channel!.stream.listen(
        _onMessage,
        onError: _onError,
        onDone: _onDone,
        cancelOnError: false,
      );

      if (_pendingAuthToken != null && _pendingAuthToken!.isNotEmpty) {
        _sendRaw({'event': 'auth', 'token': _pendingAuthToken});
      } else {
        _setState(RealtimeConnectionState.connected);
        _reconnectAttempts = 0;
        _isReconnecting = false;
        _startPingTimer();
        debugPrint('[RealtimeService] Connected (anonymous)');
      }
    } catch (e) {
      debugPrint('[RealtimeService] Connection failed: $e');
      _setState(RealtimeConnectionState.disconnected);
      _isReconnecting = false;
      _scheduleReconnect();
    }
  }

  /// Reautentica la conexión activa con un nuevo token.
  void reauthenticate(String token) {
    if (token.isEmpty) return;
    _pendingAuthToken = token;
    _authFailed = false;

    if (_state == RealtimeConnectionState.connected) {
      _sendRaw({'event': 'auth', 'token': token});
      debugPrint('[RealtimeService] Re-authenticating with refreshed token');
    }
  }

  /// Desconecta del servidor.
  Future<void> disconnect() async {
    _reconnectTimer?.cancel();
    _pingTimer?.cancel();
    await _subscription?.cancel();
    await _channel?.sink.close();
    _channel = null;
    _subscription = null;
    _authFailed = false;
    _isReconnecting = false;
    _setState(RealtimeConnectionState.disconnected);
    debugPrint('[RealtimeService] Disconnected');
  }

  /// Envía un mensaje al servidor.
  void send(Map<String, dynamic> message) {
    if (_channel == null || _state != RealtimeConnectionState.connected) {
      debugPrint('[RealtimeService] Cannot send - not connected');
      return;
    }
    _sendRaw(message);
  }

  void _sendRaw(Map<String, dynamic> message) {
    if (_channel == null) {
      debugPrint('[RealtimeService] Cannot send - channel is null');
      return;
    }
    try {
      _channel!.sink.add(jsonEncode(message));
    } catch (e) {
      debugPrint('[RealtimeService] Send error: $e');
    }
  }

  @visibleForTesting
  String buildWebSocketUrl() {
    final baseUrl = ApiConfig.baseUrl;
    final wsScheme = baseUrl.startsWith('https') ? 'wss' : 'ws';
    final host = baseUrl.replaceFirst(RegExp(r'^https?://'), '');
    return '$wsScheme://$host/realtime';
  }

  void _onMessage(dynamic message) {
    try {
      final data = jsonDecode(message as String);
      final eventName = data['event'] as String?;
      final payload = data['data'];

      if (eventName == null) {
        debugPrint('[RealtimeService] Received message without event field: $message');
        return;
      }

      if (eventName == 'auth_ok') {
        _setState(RealtimeConnectionState.connected);
        _reconnectAttempts = 0;
        _isReconnecting = false;
        _startPingTimer();
        debugPrint('[RealtimeService] Authenticated successfully');
        return;
      }

      if (eventName == 'auth_error') {
        final reason = data['data']?['reason'] ?? 'unknown';
        debugPrint('[RealtimeService] Auth rejected: $reason');
        _authFailed = true;
        disconnect();
        return;
      }

      final type = _parseEventType(eventName);
      if (type == null) {
        debugPrint('[RealtimeService] Unknown event type: $eventName');
        return;
      }

      final event = RealtimeEvent(
        type: type,
        data: payload,
        timestamp: DateTime.now(),
      );

      debugPrint('[RealtimeService] ✅ Event received: $eventName');
      _updateCacheFromEvent(event);
      _eventController.add(event);
    } catch (e) {
      debugPrint('[RealtimeService] Message parse error: $e');
    }
  }

  RealtimeEventType? _parseEventType(String eventName) {
    switch (eventName) {
      case 'readings/latest':
        return RealtimeEventType.readingsLatest;
      case 'alerts/active':
        return RealtimeEventType.alertsActive;
      case 'predictions/latest':
        return RealtimeEventType.predictionsLatest;
      case 'ml/events/active':
        return RealtimeEventType.mlEventsActive;
      case 'sensors/consolidated':
        return RealtimeEventType.sensorsConsolidated;
      default:
        return null;
    }
  }

  void _updateCacheFromEvent(RealtimeEvent event) {
    switch (event.type) {
      case RealtimeEventType.readingsLatest:
        _cacheService.invalidateDashboard();
        break;
      case RealtimeEventType.alertsActive:
        _cacheService.invalidateMlAlerts();
        break;
      case RealtimeEventType.predictionsLatest:
        _cacheService.invalidatePredictions();
        break;
      case RealtimeEventType.mlEventsActive:
        _cacheService.invalidateBadge();
        _cacheService.invalidateMlAlerts();
        break;
      case RealtimeEventType.sensorsConsolidated:
        _cacheService.invalidateDashboard();
        _cacheService.invalidateMlAlerts();
        _cacheService.invalidateBadge();
        break;
    }
  }

  void _onError(dynamic error) {
    debugPrint('[RealtimeService] Error: $error');
    _isReconnecting = false;
    _scheduleReconnect();
  }

  void _onDone() {
    debugPrint('[RealtimeService] Connection closed');
    _setState(RealtimeConnectionState.disconnected);
    _isReconnecting = false;
    _scheduleReconnect();
  }

  void _scheduleReconnect() {
    if (_reconnectTimer?.isActive == true) return;

    if (_authFailed) {
      debugPrint('[RealtimeService] Auth failed, abandoning reconnects');
      return;
    }

    final delay = _reconnectPolicy.computeDelay(_reconnectAttempts);
    if (delay == null) {
      debugPrint('[RealtimeService] Max reconnect attempts reached');
      return;
    }

    _reconnectTimer?.cancel();
    _setState(RealtimeConnectionState.reconnecting);
    _reconnectPolicy.logSchedule(_reconnectAttempts, delay);

    _reconnectTimer = Timer(delay, () {
      _reconnectAttempts++;
      _isReconnecting = true;
      connect();
    });
  }

  void _startPingTimer() {
    _pingTimer?.cancel();
    _pingTimer = Timer.periodic(_pingInterval, (_) {
      if (_state == RealtimeConnectionState.connected) {
        send({'event': 'ping'});
      }
    });
  }

  void _setState(RealtimeConnectionState newState) {
    if (_state != newState) {
      _state = newState;
      _stateController.add(newState);
    }
  }

  void dispose() {
    disconnect();
    _stateController.close();
    _eventController.close();
  }
}
