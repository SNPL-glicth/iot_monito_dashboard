import 'package:flutter/material.dart';

import '../../../../../features/monitoring/presentation/styles/dashboard_styles.dart';
import '../../../data/intelligence_models.dart';
import 'prediction_helpers.dart';

/// Tarjeta de predicción del sistema.
class PredictionCard extends StatelessWidget {
  const PredictionCard({
    super.key,
    required this.prediction,
    required this.formatDateTime,
  });

  final PredictionSummaryViewModel prediction;
  final String Function(String) formatDateTime;

  @override
  Widget build(BuildContext context) {
    final p = prediction;
    final trendIcon = PredictionHelpers.trendIcon(p.trend);
    final trendColor = PredictionHelpers.trendColor(p.trend);
    final severityColor = PredictionHelpers.severityColor(p.severity);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.analytics_outlined, color: Colors.white70),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    p.sensorName.isNotEmpty ? p.sensorName : p.sensorType,
                    style: DashboardTextStyles.deviceTitle,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              p.deviceName,
              style: DashboardTextStyles.sensorMeta,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Valor esperado',
                      style: DashboardTextStyles.smallLabel,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${p.predictedValue} ${p.unit}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('Horizonte', style: DashboardTextStyles.smallLabel),
                    const SizedBox(height: 2),
                    Text(
                      'en ${p.horizonMinutes} min',
                      style: DashboardTextStyles.sensorMeta,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      formatDateTime(p.targetTimestamp),
                      style: DashboardTextStyles.smallLabel,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(trendIcon, color: trendColor, size: 20),
                const SizedBox(width: 6),
                Text(
                  p.trend.toLowerCase() == 'up'
                      ? 'Tendencia al alza'
                      : p.trend.toLowerCase() == 'down'
                          ? 'Tendencia a la baja'
                          : 'Tendencia estable',
                  style: DashboardTextStyles.sensorMeta,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: severityColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: severityColor),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        size: 16,
                        color: severityColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        PredictionHelpers.severityLabel(p.severity),
                        style: DashboardTextStyles.smallLabel.copyWith(
                          color: severityColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Anomalía', style: DashboardTextStyles.smallLabel),
                          Text(
                            '${(p.anomalyScore.clamp(0.0, 1.0) * 100).toStringAsFixed(0)}%',
                            style: DashboardTextStyles.sensorMeta,
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: p.anomalyScore.clamp(0.0, 1.0),
                          backgroundColor: Colors.white12,
                          valueColor: AlwaysStoppedAnimation<Color>(severityColor),
                          minHeight: 6,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        PredictionHelpers.anomalyLabel(p),
                        style: DashboardTextStyles.smallLabel,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (p.shortExplanation.isNotEmpty)
              Text(
                p.shortExplanation,
                style: DashboardTextStyles.alertText,
              ),
            if (p.recommendedAction.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  p.recommendedAction,
                  style: DashboardTextStyles.sensorMeta,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
