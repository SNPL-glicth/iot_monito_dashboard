import '../ml/ml_models.dart';
import '../sensor/sensor_models.dart';
import '../threshold/threshold_models.dart';
import 'telemetry_metrics_models.dart';
import 'trading_series_models.dart';

/// ViewModel consolidado del dashboard de un sensor
class SensorDashboardViewModel {
  SensorDashboardViewModel({
    required this.sensorId,
    required this.metrics,
    required this.trading,
    required this.mlEvent,
    required this.activeCritical,
    required this.activeWarning,
    this.classification,
    this.severity,
    this.stateReason,
    this.sensorThresholds,
  });

  final String sensorId;
  final TelemetryMetricsViewModel metrics;
  final TradingPayloadViewModel trading;
  final MlEventViewModel? mlEvent;
  final int activeCritical;
  final int activeWarning;

  /// Clasificación del Orquestador: spike, degradation, noise, normal, recovery, unknown
  final String? classification;

  /// Severidad del Orquestador: critical, high, medium, low, none
  final String? severity;

  /// Razón del estado desde el Orquestador
  final String? stateReason;

  /// Umbrales explícitos por sensor
  final SensorThresholdsViewModel? sensorThresholds;

  factory SensorDashboardViewModel.fromJson(Map<String, dynamic> json) {
    int i(dynamic x) {
      if (x == null) return 0;
      if (x is num) return x.toInt();
      return int.tryParse(x.toString()) ?? 0;
    }

    final alerts = (json['alerts'] is Map)
        ? (json['alerts'] as Map).cast<String, dynamic>()
        : const <String, dynamic>{};
    final mlEventRaw = (json['mlEvent'] is Map)
        ? (json['mlEvent'] as Map).cast<String, dynamic>()
        : null;

    return SensorDashboardViewModel(
      sensorId: json['sensorId']?.toString() ?? '',
      metrics: TelemetryMetricsViewModel.fromJson(
          (json['metrics'] as Map).cast<String, dynamic>()),
      trading: TradingPayloadViewModel.fromJson(
          (json['trading'] as Map).cast<String, dynamic>()),
      mlEvent: mlEventRaw == null ? null : MlEventViewModel.fromJson(mlEventRaw),
      activeCritical: i(alerts['activeCritical']),
      activeWarning: i(alerts['activeWarning']),
    );
  }

  /// Factory para el endpoint consolidado de Telemetría (/telemetry/sensors/:id/dashboard)
  factory SensorDashboardViewModel.fromTelemetryDashboard(Map<String, dynamic> json) {
    double? nn(dynamic x) {
      if (x == null) return null;
      if (x is num) return x.toDouble();
      return double.tryParse(x.toString().replaceAll(',', '.'));
    }

    int ii(dynamic x) {
      if (x == null) return 0;
      if (x is int) return x;
      if (x is num) return x.toInt();
      return int.tryParse(x.toString()) ?? 0;
    }

    final thresholdsRaw = json['thresholds'] as Map<String, dynamic>? ?? {};
    final thresholds = CanonicalThresholdsViewModel(
      warning: CanonicalRangeViewModel(
        min: nn(thresholdsRaw['warningMin']),
        max: nn(thresholdsRaw['warningMax']),
      ),
      alert: CanonicalRangeViewModel(
        min: nn(thresholdsRaw['alertMin']),
        max: nn(thresholdsRaw['alertMax']),
      ),
    );

    final seriesRaw = (json['series'] as List?) ?? [];
    final series = seriesRaw.whereType<Map>().map((p) {
      final point = p.cast<String, dynamic>();
      return TradingSeriesPointViewModel(
        timestamp: point['t']?.toString() ?? '',
        readingTimestamp: point['readingTs']?.toString() ?? point['t']?.toString() ?? '',
        value: nn(point['v']) ?? 0.0,
        state: point['state']?.toString() ?? 'NORMAL',
        delta: null,
        events: const [],
      );
    }).toList();

    final trading = TradingPayloadViewModel(
      sensorId: json['sensorId']?.toString() ?? '',
      range: json['range']?.toString() ?? '6h',
      bucketMinutes: 1,
      initialValue: null,
      initialReadingTimestamp: null,
      thresholds: thresholds,
      series: series,
    );

    final List<MLWarningViewModel> warnings = [];
    final predRaw = json['prediction'];
    if (predRaw != null && predRaw is Map) {
      warnings.add(MLWarningViewModel(
        predictedValue: nn(predRaw['value']) ?? 0.0,
        targetTimestamp: predRaw['timestamp']?.toString(),
        confidence: nn(predRaw['confidence'] ?? json['confidence']),
        wouldBreach: TelemetryPredictionWouldBreachViewModel(
          warning: predRaw['wouldBreachWarning'] == true,
          alert: predRaw['wouldBreachAlert'] == true,
        ),
      ));
    }

    final classification = json['classification']?.toString() ?? 'normal';
    final severity = json['severity']?.toString() ?? 'none';
    final stateReason = json['stateReason']?.toString();

    final operationalState = OperationalStateMetricsViewModel(
      state: json['currentState']?.toString() ?? 'NORMAL',
      stateSince: null,
      validReadingsCount: ii(json['pointCount']),
      minReadingsForNormal: 5,
      canGenerateEvents: true,
    );

    final metrics = TelemetryMetricsViewModel(
      sensorId: json['sensorId']?.toString() ?? '',
      currentValue: nn(json['currentValue']),
      currentTimestamp: json['currentTimestamp']?.toString(),
      state: json['currentState']?.toString() ?? 'UNKNOWN',
      thresholds: thresholds,
      warnings: warnings,
      operationalState: operationalState,
    );

    final sensorThresholdsRaw = json['sensorThresholds'] as Map<String, dynamic>?;
    final sensorThresholds = sensorThresholdsRaw != null
        ? SensorThresholdsViewModel.fromJson(sensorThresholdsRaw)
        : null;

    return SensorDashboardViewModel(
      sensorId: json['sensorId']?.toString() ?? '',
      metrics: metrics,
      trading: trading,
      mlEvent: null,
      activeCritical: ii(json['activeAlerts']),
      activeWarning: ii(json['activeWarnings']),
      classification: classification,
      severity: severity,
      stateReason: stateReason,
      sensorThresholds: sensorThresholds,
    );
  }
}
