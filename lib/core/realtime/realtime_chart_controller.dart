/// Controlador de graficas en tiempo real con MQTT y fallback HTTP.
library;

import 'dart:async';

import 'package:flutter/foundation.dart';

import '../network/api_client.dart';
import 'chart_http_poller.dart';
import 'chart_mqtt_handler.dart';
import 'chart_point_buffer.dart';
import 'data_source_state.dart';
import 'mqtt_telemetry_service.dart';
import 'telemetry_point.dart';

/// Controlador para graficas de telemetria en tiempo real.
class RealtimeChartController {
  RealtimeChartController({
    required this.sensorId,
    this.httpPollingInterval = const Duration(seconds: 2),
    this.maxPoints = 120,
  });

  final String sensorId;
  final Duration httpPollingInterval;
  final int maxPoints;

  final _pointController = StreamController<TelemetryPoint>.broadcast();
  final _stateController = StreamController<DataSourceState>.broadcast();
  final _buffer = ChartPointBuffer(sensorId: '', maxPoints: 120);
  final _mqttService = MqttTelemetryService();

  late final _httpPoller = ChartHttpPoller(
    sensorId: sensorId,
    maxPoints: maxPoints,
    pollingInterval: httpPollingInterval,
    onPoint: _onHttpPoint,
    apiClient: _apiClient,
  );

  late final _mqttHandler = ChartMqttHandler(
    sensorId: sensorId,
    onPoint: _onMqttPoint,
    onStateChange: _onMqttStateChange,
    mqttService: _mqttService,
  );

  final _apiClient = ApiClient();
  DataSourceState _state = DataSourceState.disconnected;
  bool _started = false;

  Stream<TelemetryPoint> get pointStream => _pointController.stream;
  Stream<DataSourceState> get stateStream => _stateController.stream;
  DataSourceState get state => _state;
  List<TelemetryPoint> get points => _buffer.points;
  bool get isUsingMqtt => _state == DataSourceState.mqtt;

  Future<void> start() async {
    if (_started) return;
    _started = true;
    debugPrint('[RealtimeChart] Starting for sensor $sensorId');

    final mqttSuccess = await _mqttHandler.start();
    if (mqttSuccess) {
      _setState(DataSourceState.mqtt);
      debugPrint('[RealtimeChart] Using MQTT for sensor $sensorId');
    } else {
      _httpPoller.start(started: _started);
      _setState(DataSourceState.http);
      debugPrint('[RealtimeChart] Using HTTP fallback for sensor $sensorId');
    }
    await _httpPoller.fetchInitial();
  }

  void stop() {
    _started = false;
    _httpPoller.stop();
    _mqttHandler.stop();
    _setState(DataSourceState.disconnected);
    debugPrint('[RealtimeChart] Stopped for sensor $sensorId');
  }

  void dispose() {
    stop();
    _pointController.close();
    _stateController.close();
    _buffer.clear();
  }

  void _onMqttPoint(TelemetryPoint point) {
    _addPoint(point);
    if (_state == DataSourceState.http) {
      _setState(DataSourceState.mqtt);
      _httpPoller.stop();
    }
  }

  void _onHttpPoint(TelemetryPoint point, {bool notify = true}) {
    _addPoint(point, notify: notify);
  }

  void _onMqttStateChange(bool usingMqtt) {
    if (usingMqtt) {
      _setState(DataSourceState.mqtt);
      _httpPoller.stop();
    } else {
      _setState(DataSourceState.http);
      _httpPoller.start(started: _started);
    }
  }

  void _addPoint(TelemetryPoint point, {bool notify = true}) {
    if (_buffer.add(point)) {
      if (notify) _pointController.add(point);
    }
  }

  void _setState(DataSourceState newState) {
    if (_state != newState) {
      _state = newState;
      _stateController.add(newState);
    }
  }
}
