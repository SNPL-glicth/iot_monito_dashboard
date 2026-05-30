/// Modelos de acciones de decisión
library;

/// Acción recomendada dentro de una decisión.
class RecommendedActionViewModel {
  const RecommendedActionViewModel({
    required this.priority,
    required this.action,
    required this.timeframe,
  });

  final int priority;
  final String action;
  final String timeframe;

  factory RecommendedActionViewModel.fromJson(Map<String, dynamic> json) {
    return RecommendedActionViewModel(
      priority: json['priority'] is int
          ? (json['priority'] as num).toInt()
          : int.tryParse('${json['priority']}') ?? 3,
      action: '${json['action'] ?? ''}',
      timeframe: '${json['timeframe'] ?? ''}',
    );
  }
}

/// Decisión consolidada del Decision Orchestrator Worker.
class DecisionActionViewModel {
  const DecisionActionViewModel({
    required this.id,
    required this.deviceId,
    required this.deviceName,
    required this.patternSignature,
    required this.decisionType,
    required this.priority,
    required this.severity,
    required this.title,
    required this.summary,
    required this.explanation,
    required this.recommendedActions,
    required this.affectedSensorIds,
    required this.eventCount,
    required this.status,
    required this.shouldNotify,
    required this.createdAt,
    required this.expiresAt,
    required this.acknowledgedAt,
    required this.resolvedAt,
    required this.ageMinutes,
  });

  final String id;
  final String deviceId;
  final String deviceName;
  final String patternSignature;
  final String decisionType;
  final int priority;
  final String severity;
  final String title;
  final String summary;
  final String? explanation;
  final List<RecommendedActionViewModel> recommendedActions;
  final List<int> affectedSensorIds;
  final int eventCount;
  final String status;
  final bool shouldNotify;
  final String createdAt;
  final String? expiresAt;
  final String? acknowledgedAt;
  final String? resolvedAt;
  final int ageMinutes;

  factory DecisionActionViewModel.fromJson(Map<String, dynamic> json) {
    final actionsRaw = json['recommendedActions'];
    List<RecommendedActionViewModel> actions = [];
    if (actionsRaw is List) {
      actions = actionsRaw
          .whereType<Map>()
          .map((e) => RecommendedActionViewModel.fromJson(e.cast<String, dynamic>()))
          .toList();
    }

    final sensorsRaw = json['affectedSensorIds'];
    List<int> sensorIds = [];
    if (sensorsRaw is List) {
      sensorIds = sensorsRaw
          .map((e) => e is int ? e : int.tryParse('$e') ?? 0)
          .toList();
    }

    return DecisionActionViewModel(
      id: '${json['id'] ?? ''}',
      deviceId: '${json['deviceId'] ?? ''}',
      deviceName: '${json['deviceName'] ?? 'Dispositivo'}',
      patternSignature: '${json['patternSignature'] ?? ''}',
      decisionType: '${json['decisionType'] ?? 'monitor'}',
      priority: json['priority'] is int
          ? (json['priority'] as num).toInt()
          : int.tryParse('${json['priority']}') ?? 3,
      severity: '${json['severity'] ?? 'info'}',
      title: '${json['title'] ?? ''}',
      summary: '${json['summary'] ?? ''}',
      explanation: json['explanation']?.toString(),
      recommendedActions: actions,
      affectedSensorIds: sensorIds,
      eventCount: json['eventCount'] is int
          ? (json['eventCount'] as num).toInt()
          : int.tryParse('${json['eventCount']}') ?? 0,
      status: '${json['status'] ?? 'pending'}',
      shouldNotify: json['shouldNotify'] == true,
      createdAt: '${json['createdAt'] ?? ''}',
      expiresAt: json['expiresAt']?.toString(),
      acknowledgedAt: json['acknowledgedAt']?.toString(),
      resolvedAt: json['resolvedAt']?.toString(),
      ageMinutes: json['ageMinutes'] is int
          ? (json['ageMinutes'] as num).toInt()
          : int.tryParse('${json['ageMinutes']}') ?? 0,
    );
  }

  /// Indica si la decisión está pendiente de atención.
  bool get isPending => status == 'pending';

  /// Indica si la decisión fue reconocida.
  bool get isAcknowledged => status == 'acknowledged';

  /// Indica si la decisión fue resuelta.
  bool get isResolved => status == 'resolved';

  /// Indica si es crítica.
  bool get isCritical => severity == 'critical';

  /// Indica si es warning.
  bool get isWarning => severity == 'warning';
}
