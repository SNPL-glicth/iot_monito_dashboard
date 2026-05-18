import 'package:flutter/material.dart';

import '../../../../../core/theme/chart_style.dart';
import '../../../data/models/ml_features_model.dart';
import 'mini_confidence_gauge.dart';

/// Vista compacta del estado ML (gauge mini + patrón/tendencia).
class MlModelCompact extends StatelessWidget {
  const MlModelCompact({
    super.key,
    required this.features,
  });

  final MLFeaturesModel features;

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

  @override
  Widget build(BuildContext context) {
    final confidenceColor = ChartStyle.getConfidenceColor(features.confidence);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: ChartStyle.backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: confidenceColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 32,
            height: 32,
            child: MiniConfidenceGauge(
              confidence: features.confidence,
              color: confidenceColor,
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                features.patternLabel,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    features.trendIcon,
                    style: TextStyle(
                      color: _getTrendColor(features.trendDirection),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    features.confidencePercent,
                    style: TextStyle(
                      color: confidenceColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (features.isAnomalous) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: ChartStyle.alertColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                '!',
                style: TextStyle(
                  color: ChartStyle.alertColor,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
