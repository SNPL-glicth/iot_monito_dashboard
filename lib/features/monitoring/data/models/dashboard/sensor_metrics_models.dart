import 'metrics_point_models.dart';

/// Métricas resumidas de un sensor para el dashboard
class SensorMetricsViewModel {
  SensorMetricsViewModel({
    required this.sensorId,
    required this.window,
    required this.rangeMin,
    required this.rangeMax,
    required this.fluctuation,
    required this.alertsCount,
    required this.warningsCount,
    required this.series,
  });

  final String sensorId;
  final String window;
  final double? rangeMin;
  final double? rangeMax;
  final double? fluctuation;
  final int alertsCount;
  final int warningsCount;
  final List<SensorMetricsPointViewModel> series;

  factory SensorMetricsViewModel.fromJson(Map<String, dynamic> json) {
    double? n(dynamic x) {
      if (x == null) return null;
      if (x is num) return x.toDouble();
      return double.tryParse(x.toString().replaceAll(',', '.'));
    }

    int i(dynamic x) {
      if (x == null) return 0;
      if (x is num) return x.toInt();
      return int.tryParse(x.toString()) ?? 0;
    }

    final range = (json['range'] is Map)
        ? (json['range'] as Map).cast<String, dynamic>()
        : const <String, dynamic>{};
    final events = (json['events'] is Map)
        ? (json['events'] as Map).cast<String, dynamic>()
        : const <String, dynamic>{};
    final seriesRaw = (json['series'] as List?) ?? const [];
    return SensorMetricsViewModel(
      sensorId: json['sensorId']?.toString() ?? '',
      window: json['window']?.toString() ?? '',
      rangeMin: n(range['min']),
      rangeMax: n(range['max']),
      fluctuation: n(json['fluctuation']),
      alertsCount: i(events['alerts']),
      warningsCount: i(events['warnings']),
      series: seriesRaw
          .whereType<Map>()
          .map((e) =>
              SensorMetricsPointViewModel.fromJson(e.cast<String, dynamic>()))
          .toList(),
    );
  }
}
