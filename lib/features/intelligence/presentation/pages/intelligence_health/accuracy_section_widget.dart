import 'package:flutter/material.dart';
import '../../widgets/intelligence_health_widgets.dart';
import '../../../../../../core/theme/design_colors.dart';
import '../../../../../../core/theme/design_spacing.dart';
import '../../../../../../core/theme/design_text_styles.dart';


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
      padding: EdgeInsets.all(DesignSpacing.lg),
      decoration: BoxDecoration(color: DesignColors.surface, border: Border.all(color: DesignColors.border, width: 0.5), borderRadius: BorderRadius.circular(DesignRadius.lg)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IntelligenceHealthWidgets.sectionHeader(Icons.gps_fixed_rounded, 'Precisión por Umbral', Colors.teal),
          SizedBox(height: DesignSpacing.lg),
          if (!hasData)
            Container(
              padding: EdgeInsets.all(DesignSpacing.md),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(DesignRadius.sm),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline_rounded, color: Colors.grey, size: 18),
                  SizedBox(width: DesignSpacing.sm),
                  Expanded(
                    child: Text(
                      'Sin datos suficientes para calcular precisión',
                      style: DesignTextStyles.bodyText,
                    ),
                  ),
                ],
              ),
            )
          else ...[
            IntelligenceHealthWidgets.accuracyBar('±5%', withinThreshold5pct, DesignColors.green),
            SizedBox(height: DesignSpacing.sm),
            IntelligenceHealthWidgets.accuracyBar('±10%', withinThreshold10pct, DesignColors.cyan),
            SizedBox(height: DesignSpacing.sm),
            IntelligenceHealthWidgets.accuracyBar('±20%', withinThreshold20pct, DesignColors.amber),
            SizedBox(height: DesignSpacing.md),
            Text(
              'Evaluadas: $totalEvaluated predicciones',
              style: DesignTextStyles.bodyText.copyWith(fontSize: 11),
            ),
          ],
        ],
      ),
    );
  }
}
