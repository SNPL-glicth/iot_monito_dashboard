/// Punto de datos agregados por ventana temporal
class AggregatedDataPoint {
  AggregatedDataPoint({
    required this.timestamp,
    required this.avg,
    required this.min,
    required this.max,
    required this.samples,
  });

  final String timestamp;
  final double avg;
  final double min;
  final double max;
  final int samples;

  factory AggregatedDataPoint.fromJson(Map<String, dynamic> json) {
    return AggregatedDataPoint(
      timestamp: json['timestamp']?.toString() ?? '',
      avg: (json['avg'] as num?)?.toDouble() ?? 0.0,
      min: (json['min'] as num?)?.toDouble() ?? 0.0,
      max: (json['max'] as num?)?.toDouble() ?? 0.0,
      samples: (json['samples'] as num?)?.toInt() ?? 0,
    );
  }
}

/// Payload de lecturas agregadas de un sensor
class AggregatedSensorReadingsViewModel {
  AggregatedSensorReadingsViewModel({
    required this.sensorId,
    required this.sensorName,
    required this.deviceName,
    required this.unit,
    required this.range,
    required this.bucketLabel,
    required this.count,
    required this.series,
  });

  final String sensorId;
  final String sensorName;
  final String deviceName;
  final String unit;
  final String range;
  final String bucketLabel;
  final int count;
  final List<AggregatedDataPoint> series;

  factory AggregatedSensorReadingsViewModel.fromJson(Map<String, dynamic> json) {
    final seriesList = (json['series'] as List<dynamic>?)
        ?.map((e) => AggregatedDataPoint.fromJson(e as Map<String, dynamic>))
        .toList() ?? [];

    return AggregatedSensorReadingsViewModel(
      sensorId: json['sensorId']?.toString() ?? '',
      sensorName: json['sensorName']?.toString() ?? '',
      deviceName: json['deviceName']?.toString() ?? '',
      unit: json['unit']?.toString() ?? '',
      range: json['range']?.toString() ?? '6h',
      bucketLabel: json['bucketLabel']?.toString() ?? '',
      count: (json['count'] as num?)?.toInt() ?? 0,
      series: seriesList,
    );
  }
}
