import 'package:flutter/material.dart';

import '../../../../monitoring/presentation/styles/dashboard_styles.dart';
import '../../widgets/intelligence_health_helpers.dart';
import '../../widgets/intelligence_health_widgets.dart';

/// Quality section widget showing prediction quality metrics
class QualitySectionWidget extends StatelessWidget {
  const QualitySectionWidget({
    super.key,
    required this.avgConfidence,
    required this.lowConfidenceRate,
    required this.highConfidenceRate,
    required this.confidenceDistribution,
  });

  final double avgConfidence;
  final double lowConfidenceRate;
  final double highConfidenceRate;
  final Map<String, int> confidenceDistribution;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: ModernCardDecoration.elevated(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IntelligenceHealthWidgets.sectionHeader(Icons.verified_rounded, 'Calidad de Predicciones', DashboardColors.accent),
          const SizedBox(height: 16),
          IntelligenceHealthWidgets.confidenceBar('Confianza promedio', avgConfidence, DashboardColors.success),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: IntelligenceHealthWidgets.qualityChip(
                  'Baja confianza',
                  IntelligenceHealthHelpers.formatPercent(lowConfidenceRate),
                  DashboardColors.warning,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: IntelligenceHealthWidgets.qualityChip(
                  'Alta confianza',
                  IntelligenceHealthHelpers.formatPercent(highConfidenceRate),
                  DashboardColors.success,
                ),
              ),
            ],
          ),
          if (confidenceDistribution.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text('Distribución de confianza', style: DashboardTextStyles.sensorMeta),
            const SizedBox(height: 8),
            ...confidenceDistribution.entries.map(
              (e) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    SizedBox(
                      width: 60,
                      child: Text(e.key, style: DashboardTextStyles.sensorMeta.copyWith(fontSize: 11)),
                    ),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(2),
                        child: LinearProgressIndicator(
                          value: e.value / (confidenceDistribution.values.fold(0, (a, b) => a + b) + 1),
                          backgroundColor: Colors.white.withValues(alpha: 0.1),
                          valueColor: AlwaysStoppedAnimation<Color>(DashboardColors.primary.withValues(alpha: 0.7)),
                          minHeight: 8,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 30,
                      child: Text(
                        '${e.value}',
                        style: DashboardTextStyles.sensorMeta.copyWith(fontSize: 11),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
