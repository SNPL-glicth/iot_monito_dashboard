import 'package:flutter/material.dart';

import '../../../../monitoring/presentation/styles/dashboard_styles.dart';
import '../../widgets/intelligence_health_helpers.dart';
import '../../widgets/intelligence_health_widgets.dart';

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
      padding: const EdgeInsets.all(16),
      decoration: ModernCardDecoration.elevated(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IntelligenceHealthWidgets.sectionHeader(Icons.analytics_rounded, 'Métricas de Error', DashboardColors.secondary),
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
                      'Sin datos suficientes para calcular métricas de error',
                      style: DashboardTextStyles.sensorMeta,
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
                const SizedBox(width: 12),
                Expanded(
                  child: IntelligenceHealthWidgets.errorMetricTile('RMSE', IntelligenceHealthHelpers.formatDecimal(rmse), 'Raíz del Error Cuadrático'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: IntelligenceHealthWidgets.errorMetricTile('MAPE', mape != null ? IntelligenceHealthHelpers.formatPercent(mape!) : '-', 'Error Porcentual Medio'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: IntelligenceHealthWidgets.errorMetricTile('σ', IntelligenceHealthHelpers.formatDecimal(stdDev), 'Desviación Estándar'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Basado en $sampleSize muestras evaluadas',
              style: DashboardTextStyles.sensorMeta.copyWith(fontSize: 11),
            ),
          ],
        ],
      ),
    );
  }
}
