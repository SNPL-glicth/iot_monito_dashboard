import '../threshold/threshold_models.dart';

/// Punto individual en una serie de trading/bucketizada
class TradingSeriesPointViewModel {
  TradingSeriesPointViewModel({
    required this.timestamp,
    required this.readingTimestamp,
    required this.value,
    required this.state,
    required this.delta,
    required this.events,
  });

  final String timestamp;
  final String? readingTimestamp;
  final double value;
  final String state;
  final double? delta;
  final List<String> events;

  factory TradingSeriesPointViewModel.fromJson(Map<String, dynamic> json) {
    double n(dynamic x) {
      if (x is num) return x.toDouble();
      return double.parse(x.toString().replaceAll(',', '.'));
    }

    double? nn(dynamic x) {
      if (x == null) return null;
      if (x is num) return x.toDouble();
      return double.tryParse(x.toString().replaceAll(',', '.'));
    }

    final evRaw = (json['events'] as List?) ?? const [];
    final events = evRaw
        .map((e) => e?.toString() ?? '')
        .where((s) => s.trim().isNotEmpty)
        .toList();

    return TradingSeriesPointViewModel(
      timestamp: json['timestamp']?.toString() ?? '',
      readingTimestamp: json['readingTimestamp']?.toString(),
      value: n(json['value']),
      state: json['state']?.toString() ?? 'NORMAL',
      delta: nn(json['delta']),
      events: events,
    );
  }
}

/// Payload completo de serie de trading para un sensor
class TradingPayloadViewModel {
  TradingPayloadViewModel({
    required this.sensorId,
    required this.range,
    required this.bucketMinutes,
    required this.initialValue,
    required this.initialReadingTimestamp,
    required this.thresholds,
    required this.series,
  });

  final String sensorId;
  final String range;
  final int bucketMinutes;
  final double? initialValue;
  final String? initialReadingTimestamp;
  final CanonicalThresholdsViewModel thresholds;
  final List<TradingSeriesPointViewModel> series;

  factory TradingPayloadViewModel.fromJson(Map<String, dynamic> json) {
    int i(dynamic x) {
      if (x == null) return 0;
      if (x is num) return x.toInt();
      return int.tryParse(x.toString()) ?? 0;
    }

    final seriesRaw = (json['series'] as List?) ?? const [];
    final series = seriesRaw
        .whereType<Map>()
        .map((e) => TradingSeriesPointViewModel.fromJson(
            e.cast<String, dynamic>()))
        .toList();

    double? nn(dynamic x) {
      if (x == null) return null;
      if (x is num) return x.toDouble();
      return double.tryParse(x.toString().replaceAll(',', '.'));
    }

    return TradingPayloadViewModel(
      sensorId: json['sensorId']?.toString() ?? '',
      range: json['range']?.toString() ?? '',
      bucketMinutes: i(json['bucketMinutes']),
      initialValue: nn(json['initialValue']),
      initialReadingTimestamp: json['initialReadingTimestamp']?.toString(),
      thresholds: (json['thresholds'] is Map)
          ? CanonicalThresholdsViewModel.fromJson(
              (json['thresholds'] as Map).cast<String, dynamic>())
          : CanonicalThresholdsViewModel(
              warning: CanonicalRangeViewModel(min: null, max: null),
              alert: CanonicalRangeViewModel(min: null, max: null),
            ),
      series: series,
    );
  }
}
