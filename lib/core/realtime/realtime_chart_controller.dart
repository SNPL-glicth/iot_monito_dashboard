/// Controlador de gráficas en tiempo real con MQTT y fallback HTTP.
///
/// FLUJO:
/// 1. Intenta MQTT primero (push, baja latencia)
/// 2. Si MQTT falla, usa HTTP polling (fallback)
/// 3. Combina datos de ambas fuentes
///
/// CARACTERÍSTICAS:
/// - Reconexión automática
/// - Cambio de red transparente
/// - Sin duplicados
/// - Ordenado por timestamp
library;

import 'dart:async';

import 'package:flutter/foundation.dart';

import 'mqtt_telemetry_service.dart';
import '../network/api_client.dart';

/// Estado de la fuente de datos.
enum DataSourceState {
  mqtt,
  http,
  disconnected,
}

/// Controlador para gráficas de telemetría en tiempo real.
///
/// Uso:
/// ```dart
/// final controller = RealtimeChartController(sensorId: '42');
/// await controller.start();
/// controller.pointStream.listen((point) {
///   // Actualizar gráfica
/// });
/// ```
class RealtimeChartController {
  RealtimeChartController({
    required this.sensorId,
    this.httpPollingInterval = const Duration(seconds: 2),
    this.maxPoints = 120,
  });

  final String sensorId;
  final Duration httpPollingInterval;
  final int maxPoints;

  final MqttTelemetryService _mqttService = MqttTelemetryService();
  final ApiClient _apiClient = ApiClient();

  final _pointController = StreamController<TelemetryPoint>.broadcast();
  final _stateController = StreamController<DataSourceState>.broadcast();
  
  Timer? _httpPollingTimer;
  bool _started = false;
  DataSourceState _state = DataSourceState.disconnected;
  
  // Buffer de puntos
  final List<TelemetryPoint> _points = [];

  /// Stream de puntos de telemetría.
  Stream<TelemetryPoint> get pointStream => _pointController.stream;

  /// Stream del estado de la fuente de datos.
  Stream<DataSourceState> get stateStream => _stateController.stream;

  /// Estado actual de la fuente de datos.
  DataSourceState get state => _state;

  /// Puntos actuales en buffer.
  List<TelemetryPoint> get points => List.unmodifiable(_points);

  /// Indica si está usando MQTT.
  bool get isUsingMqtt => _state == DataSourceState.mqtt;

  /// Inicia el controlador.
  Future<void> start() async {
    if (_started) return;
    _started = true;

    debugPrint('[RealtimeChart] Starting for sensor $sensorId');

    // Intentar MQTT primero
    final mqttSuccess = await _startMqtt();
    
    if (mqttSuccess) {
      _setState(DataSourceState.mqtt);
      debugPrint('[RealtimeChart] Using MQTT for sensor $sensorId');
    } else {
      // Fallback a HTTP
      _startHttpPolling();
      _setState(DataSourceState.http);
      debugPrint('[RealtimeChart] Using HTTP fallback for sensor $sensorId');
    }

    // Cargar datos iniciales por HTTP
    await _fetchInitialData();
  }

  /// Detiene el controlador.
  void stop() {
    _started = false;
    _httpPollingTimer?.cancel();
    _httpPollingTimer = null;
    _mqttService.unsubscribeSensor(sensorId);
    _setState(DataSourceState.disconnected);
    debugPrint('[RealtimeChart] Stopped for sensor $sensorId');
  }

  /// Libera recursos.
  void dispose() {
    stop();
    _pointController.close();
    _stateController.close();
    _points.clear();
  }

  Future<bool> _startMqtt() async {
    if (!_mqttService.isEnabled) return false;

    try {
      await _mqttService.initialize();
      
      final success = await _mqttService.subscribeSensor(sensorId, _onMqttPoint);
      
      if (success) {
        // Monitorear desconexión para fallback
        _monitorMqttConnection();
      }
      
      return success;
    } catch (e) {
      debugPrint('[RealtimeChart] MQTT start failed: $e');
      return false;
    }
  }

  void _onMqttPoint(TelemetryPoint point) {
    _addPoint(point);
    
    // Si estábamos en HTTP, cambiar a MQTT
    if (_state == DataSourceState.http) {
      _setState(DataSourceState.mqtt);
      _stopHttpPolling();
    }
  }

  void _startHttpPolling() {
    _httpPollingTimer?.cancel();
    _httpPollingTimer = Timer.periodic(httpPollingInterval, (_) {
      _fetchLatestPoint();
    });
  }

  void _stopHttpPolling() {
    _httpPollingTimer?.cancel();
    _httpPollingTimer = null;
  }

  Future<void> _fetchInitialData() async {
    try {
      final response = await _apiClient.getJson(
        '/telemetry/sensors/$sensorId/realtime?limit=$maxPoints',
      );

      if (response['points'] is List) {
        final pointsList = response['points'] as List;
        
        for (final p in pointsList) {
          final point = TelemetryPoint(
            sensorId: sensorId,
            value: (p['value'] as num).toDouble(),
            timestamp: DateTime.parse(p['timestamp'] as String),
            state: p['state'] as String? ?? 'normal',
          );
          _addPoint(point, notify: false);
        }
        
        debugPrint('[RealtimeChart] Loaded ${pointsList.length} initial points');
      }
    } catch (e) {
      debugPrint('[RealtimeChart] Initial fetch failed: $e');
    }
  }

  Future<void> _fetchLatestPoint() async {
    if (!_started) return;

    try {
      final response = await _apiClient.getJson(
        '/telemetry/sensors/$sensorId/realtime?limit=1',
      );

      if (response['points'] is List) {
        final pointsList = response['points'] as List;
        
        if (pointsList.isNotEmpty) {
          final p = pointsList.last;
          final point = TelemetryPoint(
            sensorId: sensorId,
            value: (p['value'] as num).toDouble(),
            timestamp: DateTime.parse(p['timestamp'] as String),
            state: p['state'] as String? ?? 'normal',
          );
          _addPoint(point);
        }
      }
    } catch (e) {
      debugPrint('[RealtimeChart] HTTP fetch failed: $e');
    }
  }

  void _addPoint(TelemetryPoint point, {bool notify = true}) {
    // Deduplicación: verificar si ya existe
    final exists = _points.any((p) => 
      p.timestamp == point.timestamp && p.sensorId == point.sensorId
    );
    
    if (exists) return;

    // Agregar y ordenar
    _points.add(point);
    _points.sort((a, b) => a.timestamp.compareTo(b.timestamp));

    // Mantener tamaño máximo
    while (_points.length > maxPoints) {
      _points.removeAt(0);
    }

    // Notificar
    if (notify) {
      _pointController.add(point);
    }
  }

  void _monitorMqttConnection() {
    // Verificar conexión cada 10 segundos
    Timer.periodic(const Duration(seconds: 10), (timer) {
      if (!_started) {
        timer.cancel();
        return;
      }

      if (!_mqttService.isConnected && _state == DataSourceState.mqtt) {
        debugPrint('[RealtimeChart] MQTT disconnected, switching to HTTP');
        _setState(DataSourceState.http);
        _startHttpPolling();
      } else if (_mqttService.isConnected && _state == DataSourceState.http) {
        debugPrint('[RealtimeChart] MQTT reconnected, switching back');
        _setState(DataSourceState.mqtt);
        _stopHttpPolling();
      }
    });
  }

  void _setState(DataSourceState newState) {
    if (_state != newState) {
      _state = newState;
      _stateController.add(newState);
    }
  }
}
