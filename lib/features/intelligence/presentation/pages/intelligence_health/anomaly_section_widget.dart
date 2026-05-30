import 'package:flutter/material.dart';
import '../../widgets/intelligence_health_widgets.dart';
import '../../../../../../core/theme/design_colors.dart';
import '../../../../../../core/theme/design_spacing.dart';


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
    final rateColor = anomalyRate > 10 ? DesignColors.amber : DesignColors.green;

    return Container(
      padding: EdgeInsets.all(DesignSpacing.lg),
      decoration: BoxDecoration(color: DesignColors.surface, border: Border.all(color: DesignColors.border, width: 0.5), borderRadius: BorderRadius.circular(DesignRadius.lg)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IntelligenceHealthWidgets.sectionHeader(Icons.bug_report_rounded, 'Detección de Anomalías', Colors.purple),
          SizedBox(height: DesignSpacing.lg),
          Row(
            children: [
              Expanded(
                child: IntelligenceHealthWidgets.miniMetric(
                  'Total detectadas',
                  '$totalAnomalies',
                  Icons.warning_amber_rounded,
                  color: hasAnomalies ? DesignColors.amber : DesignColors.green,
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
