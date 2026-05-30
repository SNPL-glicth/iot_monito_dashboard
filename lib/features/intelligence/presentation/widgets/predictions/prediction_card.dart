import 'package:flutter/material.dart';
import '../../../data/intelligence_models.dart';
import 'prediction_helpers.dart';
import '../../../../../../core/theme/design_colors.dart';
import '../../../../../../core/theme/design_spacing.dart';
import '../../../../../../core/theme/design_text_styles.dart';


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
        padding: EdgeInsets.all(DesignSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.analytics_outlined, color: DesignColors.textPrimary),
                SizedBox(width: DesignSpacing.sm),
                Expanded(
                  child: Text(
                    p.sensorName.isNotEmpty ? p.sensorName : p.sensorType,
                    style: DesignTextStyles.cardTitle,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            if (p.sensorId.isNotEmpty && p.sensorId != '0') ...[
              SizedBox(height: 2),
              Text(
                'Sensor ID: ${p.sensorId}',
                style: DesignTextStyles.timestamp,
              ),
            ],
            SizedBox(height: DesignSpacing.xs),
            Text(
              p.deviceName,
              style: DesignTextStyles.bodyText,
            ),
            SizedBox(height: DesignSpacing.sm),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Valor esperado',
                      style: DesignTextStyles.timestamp,
                    ),
                    SizedBox(height: 2),
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
                    Text('Horizonte', style: DesignTextStyles.timestamp),
                    SizedBox(height: 2),
                    Text(
                      'en ${p.horizonMinutes} min',
                      style: DesignTextStyles.bodyText,
                    ),
                    SizedBox(height: 2),
                    Text(
                      formatDateTime(p.targetTimestamp),
                      style: DesignTextStyles.timestamp,
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: DesignSpacing.sm),
            Row(
              children: [
                Icon(trendIcon, color: trendColor, size: 20),
                SizedBox(width: 6),
                Text(
                  p.trend.toLowerCase() == 'up'
                      ? 'Tendencia al alza'
                      : p.trend.toLowerCase() == 'down'
                          ? 'Tendencia a la baja'
                          : 'Tendencia estable',
                  style: DesignTextStyles.bodyText,
                ),
              ],
            ),
            SizedBox(height: DesignSpacing.sm),
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: DesignSpacing.sm, vertical: DesignSpacing.xs),
                  decoration: BoxDecoration(
                    color: severityColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(DesignRadius.md),
                    border: Border.all(color: severityColor),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        size: 16,
                        color: severityColor,
                      ),
                      SizedBox(width: 4),
                      Text(
                        PredictionHelpers.severityLabel(p.severity),
                        style: DesignTextStyles.timestamp.copyWith(
                          color: severityColor,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: DesignSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Anomalía', style: DesignTextStyles.timestamp),
                          Text(
                            '${(p.anomalyScore.clamp(0.0, 1.0) * 100).toStringAsFixed(0)}%',
                            style: DesignTextStyles.bodyText,
                          ),
                        ],
                      ),
                      SizedBox(height: DesignSpacing.xs),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: p.anomalyScore.clamp(0.0, 1.0),
                          backgroundColor: Colors.white12,
                          valueColor: AlwaysStoppedAnimation<Color>(severityColor),
                          minHeight: 6,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        PredictionHelpers.anomalyLabel(p),
                        style: DesignTextStyles.timestamp,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: DesignSpacing.sm),
            if (p.shortExplanation.isNotEmpty)
              Text(
                p.shortExplanation,
                style: DesignTextStyles.bodyText,
              ),
            if (p.recommendedAction.isNotEmpty)
              Padding(
                padding: EdgeInsets.only(top: DesignSpacing.xs),
                child: Text(
                  p.recommendedAction,
                  style: DesignTextStyles.bodyText,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
