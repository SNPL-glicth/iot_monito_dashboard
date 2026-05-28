import 'package:flutter/foundation.dart';

import 'telemetry_point.dart';

/// Buffer de puntos de telemetria con validacion defensiva e insercion ordenada.
///
/// Reemplaza el sort O(n log n) por insercion binaria O(log n) + shift O(n).
/// Para n=120: ~7 comparaciones + 60 shifts vs ~840 comparaciones.
class ChartPointBuffer {
  ChartPointBuffer({required this.sensorId, required this.maxPoints});

  final String sensorId;
  final int maxPoints;
  final List<TelemetryPoint> _points = [];

  List<TelemetryPoint> get points => List.unmodifiable(_points);

  bool add(TelemetryPoint point, {bool notify = true}) {
    if (!_isValid(point)) return false;
    if (_points.any((p) => p.timestamp == point.timestamp && p.sensorId == point.sensorId)) {
      return false;
    }
    _insertSorted(point);
    while (_points.length > maxPoints) {
      _points.removeAt(0);
    }
    assert(_isSorted(), '[ChartPointBuffer] Points must remain sorted');
    return true;
  }

  void clear() => _points.clear();

  bool _isValid(TelemetryPoint point) {
    if (point.value.isNaN || point.value.isInfinite) {
      debugPrint('[ChartPointBuffer] Rejected invalid value for sensor $sensorId: ${point.value}');
      return false;
    }
    final now = DateTime.now();
    if (point.timestamp.isAfter(now.add(const Duration(minutes: 1)))) {
      debugPrint('[ChartPointBuffer] Rejected future timestamp for sensor $sensorId: ${point.timestamp}');
      return false;
    }
    if (point.timestamp.isBefore(now.subtract(const Duration(hours: 24)))) {
      debugPrint('[ChartPointBuffer] Rejected stale timestamp for sensor $sensorId: ${point.timestamp}');
      return false;
    }
    return true;
  }

  void _insertSorted(TelemetryPoint point) {
    int lo = 0;
    int hi = _points.length;
    while (lo < hi) {
      final mid = (lo + hi) >> 1;
      if (_points[mid].timestamp.isBefore(point.timestamp)) {
        lo = mid + 1;
      } else {
        hi = mid;
      }
    }
    _points.insert(lo, point);
  }

  bool _isSorted() {
    for (int i = 1; i < _points.length; i++) {
      if (_points[i - 1].timestamp.isAfter(_points[i].timestamp)) return false;
    }
    return true;
  }
}
