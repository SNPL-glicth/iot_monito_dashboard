import 'dart:async';

import 'package:flutter/foundation.dart';

import '../network/api_client.dart';
import 'telemetry_point.dart';

/// Maneja el polling HTTP y la carga de datos iniciales para una grafica.
class ChartHttpPoller {
  ChartHttpPoller({
    required this.sensorId,
    required this.maxPoints,
    required this.pollingInterval,
    required this.onPoint,
    required this.apiClient,
  });

  final String sensorId;
  final int maxPoints;
  final Duration pollingInterval;
  final void Function(TelemetryPoint point, {bool notify}) onPoint;
  final ApiClient apiClient;

  Timer? _timer;
  bool _started = false;

  void start({bool started = true}) {
    _started = started;
    _timer?.cancel();
    _timer = Timer.periodic(pollingInterval, (_) => _fetchLatest());
  }

  void stop() {
    _started = false;
    _timer?.cancel();
    _timer = null;
  }

  Future<void> fetchInitial() async {
    try {
      final response = await apiClient.getJson(
        '/telemetry/sensors/$sensorId/realtime?limit=$maxPoints',
      );
      if (response['points'] is List) {
        final pointsList = response['points'] as List;
        for (final p in pointsList) {
          onPoint(
            TelemetryPoint(
              sensorId: sensorId,
              value: (p['value'] as num).toDouble(),
              timestamp: DateTime.parse(p['timestamp'] as String),
              state: p['state'] as String? ?? 'normal',
            ),
            notify: false,
          );
        }
        debugPrint('[ChartHttpPoller] Loaded ${pointsList.length} initial points');
      }
    } catch (e) {
      debugPrint('[ChartHttpPoller] Initial fetch failed: $e');
    }
  }

  Future<void> _fetchLatest() async {
    if (!_started) return;
    try {
      final response = await apiClient.getJson(
        '/telemetry/sensors/$sensorId/realtime?limit=1',
      );
      if (response['points'] is List) {
        final pointsList = response['points'] as List;
        if (pointsList.isNotEmpty) {
          final p = pointsList.last;
          onPoint(
            TelemetryPoint(
              sensorId: sensorId,
              value: (p['value'] as num).toDouble(),
              timestamp: DateTime.parse(p['timestamp'] as String),
              state: p['state'] as String? ?? 'normal',
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('[ChartHttpPoller] HTTP fetch failed: $e');
    }
  }
}
