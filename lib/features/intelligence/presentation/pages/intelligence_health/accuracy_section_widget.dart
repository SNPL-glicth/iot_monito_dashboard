import 'package:flutter/material.dart';

import '../../../../monitoring/presentation/styles/dashboard_styles.dart';
import '../../widgets/intelligence_health_widgets.dart';

/// Accuracy section widget showing threshold-based accuracy metrics
class AccuracySectionWidget extends StatelessWidget {
  const AccuracySectionWidget({
    super.key,
    required this.totalEvaluated,
    required this.withinThreshold5pct,
    required this.withinThreshold10pct,
    required this.withinThreshold20pct,
  });

  final int totalEvaluated;
  final double withinThreshold5pct;
  final double withinThreshold10pct;
  final double withinThreshold20pct;

  @override
  Widget build(BuildContext context) {
    final hasData = totalEvaluated > 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: ModernCardDecoration.elevated(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IntelligenceHealthWidgets.sectionHeader(Icons.gps_fixed_rounded, 'Precisión por Umbral', Colors.teal),
          const SizedBox(height: 16),
          if (!hasData)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline_rounded, color: Colors.grey, size: 18),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Sin datos suficientes para calcular precisión',
                      style: DashboardTextStyles.sensorMeta,
                    ),
                  ),
                ],
              ),
            )
          else ...[
            IntelligenceHealthWidgets.accuracyBar('±5%', withinThreshold5pct, DashboardColors.success),
            const SizedBox(height: 8),
            IntelligenceHealthWidgets.accuracyBar('±10%', withinThreshold10pct, DashboardColors.info),
            const SizedBox(height: 8),
            IntelligenceHealthWidgets.accuracyBar('±20%', withinThreshold20pct, DashboardColors.warning),
            const SizedBox(height: 12),
            Text(
              'Evaluadas: $totalEvaluated predicciones',
              style: DashboardTextStyles.sensorMeta.copyWith(fontSize: 11),
            ),
          ],
        ],
      ),
    );
  }
}
