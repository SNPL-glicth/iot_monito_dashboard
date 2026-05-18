import 'package:flutter/material.dart';

import '../../../../../core/theme/chart_style.dart';
import '../../../data/models/ml_features_model.dart';
import 'confidence_gauge.dart';
import 'detail_row.dart';
import 'metric_tile.dart';

/// Vista completa del estado ML con gauge, detalles y métricas.
class MlModelFull extends StatelessWidget {
  const MlModelFull({
    super.key,
    required this.features,
    this.showDetails = true,
  });

  final MLFeaturesModel features;
  final bool showDetails;

  Color _getTrendColor(String direction) {
    switch (direction) {
      case 'up':
        return ChartStyle.alertColor;
      case 'down':
        return ChartStyle.valueLineColor;
      default:
        return ChartStyle.normalColor;
    }
  }

  String _getTrendLabel(String direction) {
    switch (direction) {
      case 'up':
        return 'Ascendente';
      case 'down':
        return 'Descendente';
      default:
        return 'Estable';
    }
  }

  @override
  Widget build(BuildContext context) {
    final confidenceColor = ChartStyle.getConfidenceColor(features.confidence);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ChartStyle.backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ChartStyle.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Row(
            children: [
              Icon(
                Icons.psychology,
                color: confidenceColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Estado del Modelo ML',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                'v${features.modelVersion}',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.4),
                  fontSize: 10,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Main content: Gauge + Details
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 100,
                height: 100,
                child: ConfidenceGauge(
                  confidence: features.confidence,
                  color: confidenceColor,
                ),
              ),
              const SizedBox(width: 16),
              if (showDetails)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DetailRow(
                        icon: Icons.pattern,
                        label: 'Patrón',
                        value: features.patternLabel,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 8),
                      DetailRow(
                        icon: Icons.trending_flat,
                        label: 'Tendencia',
                        value:
                            '${features.trendIcon} ${_getTrendLabel(features.trendDirection)}',
                        color: _getTrendColor(features.trendDirection),
                      ),
                      const SizedBox(height: 8),
                      DetailRow(
                        icon: Icons.balance,
                        label: 'Estabilidad',
                        value: features.stabilityPercent,
                        color: ChartStyle.getConfidenceColor(features.stabilityScore),
                      ),
                      const SizedBox(height: 8),
                      DetailRow(
                        icon: Icons.data_usage,
                        label: 'Ventana',
                        value: '${features.windowSize} lecturas',
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ],
                  ),
                ),
            ],
          ),

          // Anomaly alert
          if (features.isAnomalous) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: ChartStyle.alertColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: ChartStyle.alertColor.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    color: ChartStyle.alertColor,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Anomalía Detectada',
                          style: TextStyle(
                            color: ChartStyle.alertColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'Score: ${(features.anomalyScore * 100).toStringAsFixed(0)}% | '
                          'Z-score: ${features.zScore.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: ChartStyle.alertColor.withValues(alpha: 0.8),
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Baseline info
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: MetricTile(
                    label: 'Baseline',
                    value: features.baseline.toStringAsFixed(2),
                    subValue: '±${features.baselineStd.toStringAsFixed(2)}',
                  ),
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: Colors.white.withValues(alpha: 0.1),
                ),
                Expanded(
                  child: MetricTile(
                    label: 'Desviación',
                    value: features.deviation.toStringAsFixed(2),
                    subValue: '${features.deviationPct.toStringAsFixed(1)}%',
                    valueColor: features.deviationPct > 10
                        ? ChartStyle.warningColor
                        : null,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
