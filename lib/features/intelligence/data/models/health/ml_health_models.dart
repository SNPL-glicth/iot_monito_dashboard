/// Modelos de salud general del sistema ML
library;

/// Salud general del sistema de inteligencia (ML).
class MlHealthViewModel {
  const MlHealthViewModel({
    required this.status,
    required this.lastRunAt,
    required this.sensorsAnalyzed,
    required this.sensorsOmitted,
    required this.reasonsOmitted,
  });

  /// 'ok' | 'attention'
  final String status;
  final String lastRunAt; // ISO-8601
  final int sensorsAnalyzed;
  final int sensorsOmitted;
  final List<MlOmitReasonViewModel> reasonsOmitted;

  factory MlHealthViewModel.fromJson(Map<String, dynamic> json) {
    final reasons = (json['reasonsOmitted'] as List<dynamic>? ?? const [])
        .whereType<Map>()
        .map((e) => MlOmitReasonViewModel.fromJson(e.cast<String, dynamic>()))
        .toList();

    return MlHealthViewModel(
      status: '${json['status'] ?? 'ok'}',
      lastRunAt: '${json['lastRunAt'] ?? ''}',
      sensorsAnalyzed: json['sensorsAnalyzed'] is int
          ? json['sensorsAnalyzed'] as int
          : int.tryParse('${json['sensorsAnalyzed']}') ?? 0,
      sensorsOmitted: json['sensorsOmitted'] is int
          ? json['sensorsOmitted'] as int
          : int.tryParse('${json['sensorsOmitted']}') ?? 0,
      reasonsOmitted: reasons,
    );
  }
}

class MlOmitReasonViewModel {
  const MlOmitReasonViewModel({
    required this.reason,
    required this.count,
  });

  final String reason;
  final int count;

  factory MlOmitReasonViewModel.fromJson(Map<String, dynamic> json) {
    return MlOmitReasonViewModel(
      reason: '${json['reason'] ?? ''}',
      count: json['count'] is int
          ? json['count'] as int
          : int.tryParse('${json['count']}') ?? 0,
    );
  }
}
