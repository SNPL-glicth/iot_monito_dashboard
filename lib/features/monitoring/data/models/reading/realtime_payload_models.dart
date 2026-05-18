import '../threshold/threshold_models.dart';
import 'realtime_point_models.dart';

/// Payload completo para gráfica de tiempo real
class RealtimePayloadViewModel {
  RealtimePayloadViewModel({
    required this.sensorId,
    required this.points,
    required this.thresholds,
    required this.meta,
  });

  final String sensorId;
  final List<RealtimePointViewModel> points;
  final CanonicalThresholdsViewModel thresholds;
  final RealtimeMetaViewModel meta;

  factory RealtimePayloadViewModel.fromJson(Map<String, dynamic> json) {
    final pointsList = (json['points'] as List<dynamic>?)
        ?.map((e) => RealtimePointViewModel.fromJson(e as Map<String, dynamic>))
        .toList() ?? [];

    return RealtimePayloadViewModel(
      sensorId: json['sensorId']?.toString() ?? '',
      points: pointsList,
      thresholds: CanonicalThresholdsViewModel.fromJson(
        (json['thresholds'] as Map<String, dynamic>?) ?? {},
      ),
      meta: RealtimeMetaViewModel.fromJson(
        (json['meta'] as Map<String, dynamic>?) ?? {},
      ),
    );
  }
}

/// Metadata de un payload en tiempo real
class RealtimeMetaViewModel {
  RealtimeMetaViewModel({
    required this.count,
    required this.oldestTimestamp,
    required this.newestTimestamp,
    required this.generatedAt,
  });

  final int count;
  final String? oldestTimestamp;
  final String? newestTimestamp;
  final String generatedAt;

  factory RealtimeMetaViewModel.fromJson(Map<String, dynamic> json) {
    return RealtimeMetaViewModel(
      count: (json['count'] as num?)?.toInt() ?? 0,
      oldestTimestamp: json['oldestTimestamp']?.toString(),
      newestTimestamp: json['newestTimestamp']?.toString(),
      generatedAt: json['generatedAt']?.toString() ?? '',
    );
  }
}
