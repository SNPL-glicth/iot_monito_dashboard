import 'package:flutter/material.dart';
import '../../widgets/intelligence_health_helpers.dart';
import '../../widgets/intelligence_health_widgets.dart';
import '../../../../../../core/theme/design_colors.dart';
import '../../../../../../core/theme/design_spacing.dart';
import '../../../../../../core/theme/design_text_styles.dart';


/// Error metrics section widget showing MAE, RMSE, MAPE, std dev
class ErrorMetricsSectionWidget extends StatelessWidget {
  const ErrorMetricsSectionWidget({
    super.key,
    required this.sampleSize,
    required this.mae,
    required this.rmse,
    required this.mape,
    required this.stdDev,
  });

  final int sampleSize;
  final double mae;
  final double rmse;
  final double? mape;
  final double stdDev;

  @override
  Widget build(BuildContext context) {
    final hasData = sampleSize > 0;

    return Container(
      padding: EdgeInsets.all(DesignSpacing.lg),
      decoration: BoxDecoration(color: DesignColors.surface, border: Border.all(color: DesignColors.border, width: 0.5), borderRadius: BorderRadius.circular(DesignRadius.lg)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IntelligenceHealthWidgets.sectionHeader(Icons.analytics_rounded, 'Métricas de Error', DesignColors.cyanDim),
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
                      'Sin datos suficientes para calcular métricas de error',
                      style: DesignTextStyles.bodyText,
                    ),
                  ),
                ],
              ),
            )
          else ...[
            Row(
              children: [
                Expanded(
                  child: IntelligenceHealthWidgets.errorMetricTile('MAE', IntelligenceHealthHelpers.formatDecimal(mae), 'Error Absoluto Medio'),
                ),
                SizedBox(width: DesignSpacing.md),
                Expanded(
                  child: IntelligenceHealthWidgets.errorMetricTile('RMSE', IntelligenceHealthHelpers.formatDecimal(rmse), 'Raíz del Error Cuadrático'),
                ),
              ],
            ),
            SizedBox(height: DesignSpacing.md),
            Row(
              children: [
                Expanded(
                  child: IntelligenceHealthWidgets.errorMetricTile('MAPE', mape != null ? IntelligenceHealthHelpers.formatPercent(mape!) : '-', 'Error Porcentual Medio'),
                ),
                SizedBox(width: DesignSpacing.md),
                Expanded(
                  child: IntelligenceHealthWidgets.errorMetricTile('σ', IntelligenceHealthHelpers.formatDecimal(stdDev), 'Desviación Estándar'),
                ),
              ],
            ),
            SizedBox(height: DesignSpacing.md),
            Text(
              'Basado en $sampleSize muestras evaluadas',
              style: DesignTextStyles.bodyText.copyWith(fontSize: 11),
            ),
          ],
        ],
      ),
    );
  }
}
