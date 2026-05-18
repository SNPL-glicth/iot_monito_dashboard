import 'optimized_realtime_chart_models.dart';

/// Cache de alertas con TTL para evitar recálculos
class AlertCache {
  AlertCache();

  final Map<double, bool> _alertMap = {};
  final Map<double, bool> _warningMap = {};
  int _dataHash = 0;
  DateTime _lastUpdate = DateTime.now();
  static const _ttl = Duration(seconds: 2);

  bool isValid(int dataHash) {
    final now = DateTime.now();
    return _dataHash == dataHash && now.difference(_lastUpdate) < _ttl;
  }

  void update(List<OptimizedDataPoint> points, int dataHash) {
    _alertMap.clear();
    _warningMap.clear();

    for (final p in points) {
      if (p.isAlert) {
        _alertMap[p.x] = true;
      } else if (p.isWarning || p.hasDeltaSpike) {
        _warningMap[p.x] = true;
      }
    }

    _dataHash = dataHash;
    _lastUpdate = DateTime.now();
  }

  bool isAlertAt(double x) => _alertMap[x] ?? false;
  bool isWarningAt(double x) => _warningMap[x] ?? false;
}
