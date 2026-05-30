import 'package:flutter/material.dart';
import '../../widgets/intelligence_health_helpers.dart';
import '../../widgets/intelligence_health_widgets.dart';
import '../../../../../../core/theme/design_colors.dart';
import '../../../../../../core/theme/design_spacing.dart';
import '../../../../../../core/theme/design_text_styles.dart';


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
      padding: EdgeInsets.all(DesignSpacing.lg),
      decoration: BoxDecoration(color: DesignColors.surface, border: Border.all(color: DesignColors.border, width: 0.5), borderRadius: BorderRadius.circular(DesignRadius.lg)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IntelligenceHealthWidgets.sectionHeader(Icons.verified_rounded, 'Calidad de Predicciones', DesignColors.green),
          SizedBox(height: DesignSpacing.lg),
          IntelligenceHealthWidgets.confidenceBar('Confianza promedio', avgConfidence, DesignColors.green),
          SizedBox(height: DesignSpacing.md),
          Row(
            children: [
              Expanded(
                child: IntelligenceHealthWidgets.qualityChip(
                  'Baja confianza',
                  IntelligenceHealthHelpers.formatPercent(lowConfidenceRate),
                  DesignColors.amber,
                ),
              ),
              SizedBox(width: DesignSpacing.md),
              Expanded(
                child: IntelligenceHealthWidgets.qualityChip(
                  'Alta confianza',
                  IntelligenceHealthHelpers.formatPercent(highConfidenceRate),
                  DesignColors.green,
                ),
              ),
            ],
          ),
          if (confidenceDistribution.isNotEmpty) ...[
            SizedBox(height: DesignSpacing.lg),
            Text('Distribución de confianza', style: DesignTextStyles.bodyText),
            SizedBox(height: DesignSpacing.sm),
            ...confidenceDistribution.entries.map(
              (e) => Padding(
                padding: EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    SizedBox(
                      width: 60,
                      child: Text(e.key, style: DesignTextStyles.bodyText.copyWith(fontSize: 11)),
                    ),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(2),
                        child: LinearProgressIndicator(
                          value: e.value / (confidenceDistribution.values.fold(0, (a, b) => a + b) + 1),
                          backgroundColor: Colors.white.withValues(alpha: 0.1),
                          valueColor: AlwaysStoppedAnimation<Color>(DesignColors.cyan.withValues(alpha: 0.7)),
                          minHeight: 8,
                        ),
                      ),
                    ),
                    SizedBox(width: DesignSpacing.sm),
                    SizedBox(
                      width: 30,
                      child: Text(
                        '${e.value}',
                        style: DesignTextStyles.bodyText.copyWith(fontSize: 11),
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
