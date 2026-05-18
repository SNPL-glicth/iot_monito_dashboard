import 'package:flutter/material.dart';

import '../../../../monitoring/presentation/styles/dashboard_styles.dart';
import '../../widgets/intelligence_health_widgets.dart';

/// Activity section widget showing model activity metrics
class ActivitySectionWidget extends StatelessWidget {
  const ActivitySectionWidget({
    super.key,
    required this.predictionsLast1h,
    required this.predictionsLast24h,
    required this.predictionsLast7d,
    required this.avgPredictionsPerHour,
  });

  final int predictionsLast1h;
  final int predictionsLast24h;
  final int predictionsLast7d;
  final double avgPredictionsPerHour;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: ModernCardDecoration.elevated(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IntelligenceHealthWidgets.sectionHeader(Icons.timeline_rounded, 'Actividad del Modelo', DashboardColors.primary),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: IntelligenceHealthWidgets.miniMetric(
                  'Última hora',
                  '$predictionsLast1h',
                  Icons.schedule_rounded,
                ),
              ),
              Expanded(
                child: IntelligenceHealthWidgets.miniMetric(
                  '24 horas',
                  '$predictionsLast24h',
                  Icons.today_rounded,
                ),
              ),
              Expanded(
                child: IntelligenceHealthWidgets.miniMetric(
                  '7 días',
                  '$predictionsLast7d',
                  Icons.date_range_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: DashboardColors.info.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.speed_rounded, color: DashboardColors.info, size: 18),
                const SizedBox(width: 8),
                Text(
                  'Promedio: ${avgPredictionsPerHour.toStringAsFixed(1)} predicciones/hora',
                  style: DashboardTextStyles.sensorMeta.copyWith(color: DashboardColors.info),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
