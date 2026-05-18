import 'historical_point_models.dart';

/// Payload completo de lecturas históricas por rango de fechas
class HistoricalReadingsViewModel {
  HistoricalReadingsViewModel({
    required this.sensorId,
    required this.sensorName,
    required this.deviceName,
    required this.unit,
    required this.from,
    required this.to,
    required this.count,
    required this.thresholds,
    required this.series,
  });

  final String sensorId;
  final String sensorName;
  final String deviceName;
  final String unit;
  final String from;
  final String to;
  final int count;
  final HistoricalThresholdsData thresholds;
  final List<HistoricalReadingPoint> series;

  factory HistoricalReadingsViewModel.fromJson(Map<String, dynamic> json) {
    final seriesList = (json['series'] as List<dynamic>?)
        ?.map((e) => HistoricalReadingPoint.fromJson(e as Map<String, dynamic>))
        .toList() ?? [];

    return HistoricalReadingsViewModel(
      sensorId: json['sensorId']?.toString() ?? '',
      sensorName: json['sensorName']?.toString() ?? '',
      deviceName: json['deviceName']?.toString() ?? '',
      unit: json['unit']?.toString() ?? '',
      from: json['from']?.toString() ?? '',
      to: json['to']?.toString() ?? '',
      count: (json['count'] as num?)?.toInt() ?? 0,
      thresholds: HistoricalThresholdsData.fromJson(
        json['thresholds'] as Map<String, dynamic>?,
      ),
      series: seriesList,
    );
  }
}
