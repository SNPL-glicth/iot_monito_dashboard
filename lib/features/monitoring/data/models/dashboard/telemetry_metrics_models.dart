import '../ml/ml_models.dart';
import '../sensor/sensor_models.dart';
import '../threshold/threshold_models.dart';

/// Métricas de telemetría actuales de un sensor
class TelemetryMetricsViewModel {
  TelemetryMetricsViewModel({
    required this.sensorId,
    required this.currentValue,
    required this.currentTimestamp,
    required this.state,
    required this.thresholds,
    required this.warnings,
    required this.operationalState,
  });

  final String sensorId;
  final double? currentValue;
  final String? currentTimestamp;
  final String state;
  final CanonicalThresholdsViewModel thresholds;
  final List<MLWarningViewModel> warnings;
  final OperationalStateMetricsViewModel operationalState;

  bool get isWarmingUp => operationalState.isWarmingUp;

  factory TelemetryMetricsViewModel.fromJson(Map<String, dynamic> json) {
    double? n(dynamic x) {
      if (x == null) return null;
      if (x is num) return x.toDouble();
      return double.tryParse(x.toString().replaceAll(',', '.'));
    }

    final warnsRaw = (json['warnings'] is Map)
        ? (json['warnings'] as Map).cast<String, dynamic>()
        : null;

    final opStateRaw = json['operationalState'] is Map
        ? (json['operationalState'] as Map).cast<String, dynamic>()
        : null;

    return TelemetryMetricsViewModel(
      sensorId: json['sensorId']?.toString() ?? '',
      currentValue: n(json['currentValue']),
      currentTimestamp: json['currentTimestamp']?.toString(),
      state: json['state']?.toString() ?? 'UNKNOWN',
      thresholds: (json['thresholds'] is Map)
          ? CanonicalThresholdsViewModel.fromJson(
              (json['thresholds'] as Map).cast<String, dynamic>())
          : CanonicalThresholdsViewModel(
              warning: CanonicalRangeViewModel(min: null, max: null),
              alert: CanonicalRangeViewModel(min: null, max: null),
            ),
      warnings: warnsRaw == null
          ? []
          : [MLWarningViewModel.fromJson(warnsRaw)],
      operationalState: OperationalStateMetricsViewModel.fromJson(opStateRaw),
    );
  }
}
