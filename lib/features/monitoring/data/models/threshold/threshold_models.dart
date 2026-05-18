/// Modelos de umbrales
library;

class CanonicalRangeViewModel {
  CanonicalRangeViewModel({required this.min, required this.max});

  final double? min;
  final double? max;

  factory CanonicalRangeViewModel.fromJson(Map<String, dynamic> json) {
    double? n(dynamic x) {
      if (x == null) return null;
      if (x is num) return x.toDouble();
      return double.tryParse(x.toString().replaceAll(',', '.'));
    }

    return CanonicalRangeViewModel(
      min: n(json['min']),
      max: n(json['max']),
    );
  }
}

class CanonicalThresholdsViewModel {
  CanonicalThresholdsViewModel({required this.warning, required this.alert});

  final CanonicalRangeViewModel warning;
  final CanonicalRangeViewModel alert;

  factory CanonicalThresholdsViewModel.fromJson(Map<String, dynamic> json) {
    final warning = (json['warning'] is Map)
        ? CanonicalRangeViewModel.fromJson((json['warning'] as Map).cast<String, dynamic>())
        : CanonicalRangeViewModel(min: null, max: null);
    final alert = (json['alert'] is Map)
        ? CanonicalRangeViewModel.fromJson((json['alert'] as Map).cast<String, dynamic>())
        : CanonicalRangeViewModel(min: null, max: null);
    return CanonicalThresholdsViewModel(warning: warning, alert: alert);
  }
}

class AlertThresholdViewModel {
  AlertThresholdViewModel({
    required this.id,
    required this.sensorId,
    required this.name,
    required this.conditionType,
    this.thresholdValueMin,
    this.thresholdValueMax,
    required this.severity,
    required this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String sensorId;
  final String name;
  final String conditionType;
  final String? thresholdValueMin;
  final String? thresholdValueMax;
  final String severity;
  final bool isActive;
  final String? createdAt;
  final String? updatedAt;

  factory AlertThresholdViewModel.fromJson(Map<String, dynamic> json) {
    return AlertThresholdViewModel(
      id: json['id'].toString(),
      sensorId: json['sensorId'].toString(),
      name: json['name']?.toString() ?? '',
      conditionType: json['conditionType']?.toString() ?? '',
      thresholdValueMin: json['thresholdValueMin']?.toString(),
      thresholdValueMax: json['thresholdValueMax']?.toString(),
      severity: json['severity']?.toString() ?? 'warning',
      isActive: json['isActive'] == true,
      createdAt: json['createdAt']?.toString(),
      updatedAt: json['updatedAt']?.toString(),
    );
  }
}

class ThresholdHistoryViewModel {
  ThresholdHistoryViewModel({
    required this.id,
    required this.thresholdId,
    this.oldMin,
    this.oldMax,
    this.newMin,
    this.newMax,
    required this.changedBy,
    required this.changedAt,
    this.reason,
  });

  final String id;
  final String thresholdId;
  final String? oldMin;
  final String? oldMax;
  final String? newMin;
  final String? newMax;
  final String changedBy;
  final String changedAt;
  final String? reason;

  factory ThresholdHistoryViewModel.fromJson(Map<String, dynamic> json) {
    return ThresholdHistoryViewModel(
      id: json['id'].toString(),
      thresholdId: json['thresholdId'].toString(),
      oldMin: json['oldMin']?.toString(),
      oldMax: json['oldMax']?.toString(),
      newMin: json['newMin']?.toString(),
      newMax: json['newMax']?.toString(),
      changedBy: json['changedBy']?.toString() ?? '-',
      changedAt: json['changedAt']?.toString() ?? '-',
      reason: json['reason']?.toString(),
    );
  }
}
