import 'package:flutter/material.dart';

import '../../../../monitoring/presentation/styles/dashboard_styles.dart';
import '../../widgets/intelligence_health_widgets.dart';

/// Anomaly section widget showing anomaly detection metrics
class AnomalySectionWidget extends StatelessWidget {
  const AnomalySectionWidget({
    super.key,
    required this.totalAnomalies,
    required this.anomalyRate,
  });

  final int totalAnomalies;
  final double anomalyRate;

  @override
  Widget build(BuildContext context) {
    final hasAnomalies = totalAnomalies > 0;
    final rateColor = anomalyRate > 10 ? DashboardColors.warning : DashboardColors.success;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: ModernCardDecoration.elevated(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IntelligenceHealthWidgets.sectionHeader(Icons.bug_report_rounded, 'Detección de Anomalías', Colors.purple),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: IntelligenceHealthWidgets.miniMetric(
                  'Total detectadas',
                  '$totalAnomalies',
                  Icons.warning_amber_rounded,
                  color: hasAnomalies ? DashboardColors.warning : DashboardColors.success,
                ),
              ),
              Expanded(
                child: IntelligenceHealthWidgets.miniMetric(
                  'Tasa de anomalías',
                  '${anomalyRate.toStringAsFixed(1)}%',
                  Icons.percent_rounded,
                  color: rateColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
