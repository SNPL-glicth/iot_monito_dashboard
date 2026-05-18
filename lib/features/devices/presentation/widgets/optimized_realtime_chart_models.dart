/// Punto de datos optimizado con índice pre-calculado para alertas
class OptimizedDataPoint {
  const OptimizedDataPoint({
    required this.timestamp,
    required this.value,
    required this.x,
    this.state = 'NORMAL',
    this.events = const [],
  });

  final DateTime timestamp;
  final double value;
  final double x; // Pre-calculado: timestamp.millisecondsSinceEpoch.toDouble()
  final String state;
  final List<String> events;

  bool get isAlert => state.toUpperCase() == 'ALERT';
  bool get isWarning => state.toUpperCase() == 'WARNING';
  bool get isPrediction => state.toUpperCase() == 'PREDICTION';
  bool get hasDeltaSpike => events.any((e) => e.toUpperCase() == 'DELTA_SPIKE');
  bool get isSpecial => isAlert || isWarning || hasDeltaSpike;
}

/// Helper para convertir RealtimeDataPoint a OptimizedDataPoint
extension RealtimeToOptimized on List<dynamic> {
  List<OptimizedDataPoint> toOptimizedPoints() {
    return map((p) {
      if (p is OptimizedDataPoint) return p;
      // Asume que tiene timestamp, value, state, events
      final ts = p.timestamp as DateTime;
      return OptimizedDataPoint(
        timestamp: ts,
        value: p.value as double,
        x: ts.millisecondsSinceEpoch.toDouble(),
        state: (p.state as String?) ?? 'NORMAL',
        events: (p.events as List<String>?) ?? const [],
      );
    }).toList().cast<OptimizedDataPoint>();
  }
}
