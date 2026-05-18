import 'package:flutter/material.dart';

import '../../../../monitoring/data/models/monitoring_view_models.dart';
import '../../../../monitoring/presentation/styles/dashboard_styles.dart';
import '../../widgets/optimized_realtime_chart.dart';
import '../../widgets/optimized_realtime_chart_models.dart';
import 'sensor_metrics_card.dart';

/// Main body content for sensor detail page
class SensorDetailBody extends StatelessWidget {
  const SensorDetailBody({
    super.key,
    required this.dashboard,
    required this.realtimeData,
    required this.unit,
    required this.isSensorActive,
    required this.refreshing,
    required this.sensorType,
    required this.isFrozen,
    required this.onPointTapped,
  });

  final SensorDashboardViewModel dashboard;
  final RealtimePayloadViewModel? realtimeData;
  final String unit;
  final bool isSensorActive;
  final bool refreshing;
  final String sensorType;
  final bool isFrozen;
  final Function(OptimizedDataPoint) onPointTapped;

  @override
  Widget build(BuildContext context) {
    final m = dashboard.metrics;
    final thresholds = realtimeData?.thresholds ?? m.thresholds;

    return Column(
      children: [
        SensorMetricsCard(
          dashboard: dashboard,
          unit: unit,
          isSensorActive: isSensorActive,
          refreshing: refreshing,
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _chartHeader(),
                const SizedBox(height: 10),
                _buildChart(thresholds),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _chartHeader() {
    return Row(
      children: [
        const Icon(Icons.show_chart, color: Color(0xFF00E676)),
        const SizedBox(width: 8),
        const Expanded(
          child: Text(
            'Gráfica en Tiempo Real',
            style: DashboardTextStyles.deviceTitle,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            'Última hora',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 10,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChart(CanonicalThresholdsViewModel thresholds) {
    final realtime = realtimeData;
    List<OptimizedDataPoint> allPoints;

    if (realtime != null && realtime.points.isNotEmpty) {
      allPoints = realtime.points.map((p) {
        final ts = DateTime.tryParse(p.timestamp);
        if (ts == null) return null;
        final localTs = ts.toLocal();
        return OptimizedDataPoint(
          timestamp: localTs,
          value: p.value,
          x: localTs.millisecondsSinceEpoch.toDouble(),
          state: p.state,
          events: const [],
        );
      }).whereType<OptimizedDataPoint>().toList();
    } else {
      allPoints = dashboard.trading.series.map((p) {
        final ts = DateTime.tryParse(p.timestamp);
        if (ts == null) return null;
        final localTs = ts.toLocal();
        return OptimizedDataPoint(
          timestamp: localTs,
          value: p.value,
          x: localTs.millisecondsSinceEpoch.toDouble(),
          state: p.state,
          events: p.events,
        );
      }).whereType<OptimizedDataPoint>().toList();
    }

    allPoints.sort((a, b) => a.timestamp.compareTo(b.timestamp));

    return OptimizedRealtimeChart(
      points: allPoints,
      unit: unit,
      sensorType: sensorType,
      alertThresholdMin: thresholds.alert.min,
      alertThresholdMax: thresholds.alert.max,
      warningThresholdMin: thresholds.warning.min,
      warningThresholdMax: thresholds.warning.max,
      isFrozen: isFrozen,
      onPointTapped: onPointTapped,
    );
  }
}
