/// Servicio de WebSocket para datos en tiempo real.
/// 
/// FIX FASE 3: Reemplaza polling HTTP por push WebSocket.
/// Reduce latencia y carga en el servidor.
/// 
/// Eventos soportados:
/// - readings/latest: Últimas lecturas de sensores
/// - alerts/active: Alertas activas
/// - predictions/latest: Predicciones ML
/// - ml/events/active: Eventos ML activos
/// - sensors/consolidated: Estado consolidado de sensores (SSOT)
library;

import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../config/api_config.dart';
import '../cache/dashboard_cache_service.dart';

/// Tipos de eventos que el servidor puede enviar
enum RealtimeEventType {
  readingsLatest,
  alertsActive,
  predictionsLatest,
  mlEventsActive,
  /// FIX AUDITORIA: Estado consolidado de sensores (operational_state SSOT)
  sensorsConsolidated,
}

/// Evento recibido del servidor
class RealtimeEvent {
  const RealtimeEvent({
    required this.type,
    required this.data,
    required this.timestamp,
  });

  final RealtimeEventType type;
  final dynamic data;
  final DateTime timestamp;
}

/// Callback para eventos de realtime
typedef RealtimeEventCallback = void Function(RealtimeEvent event);

/// Estado de la conexión WebSocket
enum RealtimeConnectionState {
  disconnected,
  connecting,
  connected,
  reconnecting,
}

/// Servicio singleton para conexión WebSocket en tiempo real
class RealtimeService {
  // Singleton
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
  static const int _maxReconnectAttempts = 5;
  static const Duration _reconnectDelay = Duration(seconds: 5);
  static const Duration _pingInterval = Duration(seconds: 30);
  
  final DashboardCacheService _cacheService = DashboardCacheService();

  /// Stream del estado de conexión
  Stream<RealtimeConnectionState> get stateStream => _stateController.stream;
  
  /// Stream de eventos recibidos
  Stream<RealtimeEvent> get eventStream => _eventController.stream;
  
  /// Estado actual de la conexión
  RealtimeConnectionState get state => _state;
  
  /// Indica si está conectado
  bool get isConnected => _state == RealtimeConnectionState.connected;

  /// Conecta al servidor WebSocket
  Future<void> connect({String? authToken}) async {
    if (_state == RealtimeConnectionState.connecting ||
        _state == RealtimeConnectionState.connected) {
      return;
    }

    _setState(RealtimeConnectionState.connecting);
    
    try {
      final wsUrl = _buildWebSocketUrl(authToken);
      debugPrint('[RealtimeService] Connecting to $wsUrl');
      
      _channel = WebSocketChannel.connect(Uri.parse(wsUrl));
      
      _subscription = _channel!.stream.listen(
        _onMessage,
        onError: _onError,
        onDone: _onDone,
        cancelOnError: false,
      );

      _setState(RealtimeConnectionState.connected);
      _reconnectAttempts = 0;
      _startPingTimer();
      
      debugPrint('[RealtimeService] Connected successfully');
    } catch (e) {
      debugPrint('[RealtimeService] Connection failed: $e');
      _setState(RealtimeConnectionState.disconnected);
      _scheduleReconnect();
    }
  }

  /// Desconecta del servidor
  Future<void> disconnect() async {
    _reconnectTimer?.cancel();
    _pingTimer?.cancel();
    await _subscription?.cancel();
    await _channel?.sink.close();
    _channel = null;
    _subscription = null;
    _setState(RealtimeConnectionState.disconnected);
    debugPrint('[RealtimeService] Disconnected');
  }

  /// Envía un mensaje al servidor
  void send(Map<String, dynamic> message) {
    if (_channel == null || _state != RealtimeConnectionState.connected) {
      debugPrint('[RealtimeService] Cannot send - not connected');
      return;
    }
    
    try {
      _channel!.sink.add(jsonEncode(message));
    } catch (e) {
      debugPrint('[RealtimeService] Send error: $e');
    }
  }

  String _buildWebSocketUrl(String? authToken) {
    // Convertir HTTP URL a WebSocket URL
    final baseUrl = ApiConfig.baseUrl;
    final wsScheme = baseUrl.startsWith('https') ? 'wss' : 'ws';
    final host = baseUrl.replaceFirst(RegExp(r'^https?://'), '');
    
    var url = '$wsScheme://$host/realtime';
    if (authToken != null && authToken.isNotEmpty) {
      url += '?token=$authToken';
    }
    return url;
  }

  void _onMessage(dynamic message) {
    try {
      // CRITICAL FIX: Backend now sends structured {event, data} messages
      final data = jsonDecode(message as String);
      final eventName = data['event'] as String?;
      final payload = data['data'];
      
      if (eventName == null) {
        debugPrint('[RealtimeService] Received message without event field: $message');
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
      
      // Actualizar cache con datos recibidos
      _updateCacheFromEvent(event);
      
      // Emitir evento
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
    // Invalidar cache relevante cuando llegan datos nuevos
    // El siguiente fetch obtendrá datos frescos
    switch (event.type) {
      case RealtimeEventType.readingsLatest:
        // Las lecturas actualizan el dashboard
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
        // FIX AUDITORIA: Estado consolidado invalida dashboard y alertas
        // Este es el evento SSOT para estados de sensores
        _cacheService.invalidateDashboard();
        _cacheService.invalidateMlAlerts();
        _cacheService.invalidateBadge();
        break;
    }
  }

  void _onError(dynamic error) {
    debugPrint('[RealtimeService] Error: $error');
    _scheduleReconnect();
  }

  void _onDone() {
    debugPrint('[RealtimeService] Connection closed');
    _setState(RealtimeConnectionState.disconnected);
    _scheduleReconnect();
  }

  void _scheduleReconnect() {
    if (_reconnectAttempts >= _maxReconnectAttempts) {
      debugPrint('[RealtimeService] Max reconnect attempts reached');
      return;
    }

    _reconnectTimer?.cancel();
    _setState(RealtimeConnectionState.reconnecting);
    
    final delay = _reconnectDelay * (_reconnectAttempts + 1);
    debugPrint('[RealtimeService] Reconnecting in ${delay.inSeconds}s (attempt ${_reconnectAttempts + 1})');
    
    _reconnectTimer = Timer(delay, () {
      _reconnectAttempts++;
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

  /// Libera recursos
  void dispose() {
    disconnect();
    _stateController.close();
    _eventController.close();
  }
}
