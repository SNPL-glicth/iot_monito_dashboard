import 'package:fl_chart/fl_chart.dart';

import '../../../../core/alerts/alert_snapshot_service.dart';

/// Cache de alertas para FrozenAlertChart - evita búsquedas O(n)
class FrozenAlertCache {
  final Map<double, String> _stateMap = {};
  final Set<double> _triggerSet = {};

  void build(List<AlertSnapshotPoint> points) {
    _stateMap.clear();
    _triggerSet.clear();
    for (final p in points) {
      final x = p.timestamp.millisecondsSinceEpoch.toDouble();
      _stateMap[x] = p.state.toUpperCase();
      if (p.isAlertTrigger) {
        _triggerSet.add(x);
      }
    }
  }

  String getStateAt(double x) {
    for (final key in _stateMap.keys) {
      if ((key - x).abs() < 1000) {
        return _stateMap[key]!;
      }
    }
    return 'NORMAL';
  }

  bool isTriggerAt(double x) {
    for (final key in _triggerSet) {
      if ((key - x).abs() < 1000) {
        return true;
      }
    }
    return false;
  }
}

/// Datos computados para el chart
class ChartData {
  final FrozenAlertCache cache;
  final List<FlSpot> spots;
  final List<FlSpot> triggerSpots;
  final double minX;
  final double maxX;
  final double minY;
  final double maxY;

  ChartData({
    required this.cache,
    required this.spots,
    required this.triggerSpots,
    required this.minX,
    required this.maxX,
    required this.minY,
    required this.maxY,
  });
}
