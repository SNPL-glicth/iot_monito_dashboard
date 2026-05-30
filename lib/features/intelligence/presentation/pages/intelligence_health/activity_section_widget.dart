import 'package:flutter/material.dart';
import '../../widgets/intelligence_health_widgets.dart';
import '../../../../../../core/theme/design_colors.dart';
import '../../../../../../core/theme/design_spacing.dart';
import '../../../../../../core/theme/design_text_styles.dart';


/// Activity section widget showing model activity metrics
class ActivitySectionWidget extends StatelessWidget {
  const ActivitySectionWidget({
    super.key,
    required this.predictionsLast1h,
    required this.predictionsLast24h,
    required this.predictionsLast7d,
    required this.avgPredictionsPerHour,
  });

  final int predictionsLast1h;
  final int predictionsLast24h;
  final int predictionsLast7d;
  final double avgPredictionsPerHour;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(DesignSpacing.lg),
      decoration: BoxDecoration(color: DesignColors.surface, border: Border.all(color: DesignColors.border, width: 0.5), borderRadius: BorderRadius.circular(DesignRadius.lg)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IntelligenceHealthWidgets.sectionHeader(Icons.timeline_rounded, 'Actividad del Modelo', DesignColors.cyan),
          SizedBox(height: DesignSpacing.lg),
          Row(
            children: [
              Expanded(
                child: IntelligenceHealthWidgets.miniMetric(
                  'Última hora',
                  '$predictionsLast1h',
                  Icons.schedule_rounded,
                ),
              ),
              Expanded(
                child: IntelligenceHealthWidgets.miniMetric(
                  '24 horas',
                  '$predictionsLast24h',
                  Icons.today_rounded,
                ),
              ),
              Expanded(
                child: IntelligenceHealthWidgets.miniMetric(
                  '7 días',
                  '$predictionsLast7d',
                  Icons.date_range_rounded,
                ),
              ),
            ],
          ),
          SizedBox(height: DesignSpacing.md),
          Container(
            padding: EdgeInsets.symmetric(horizontal: DesignSpacing.md, vertical: DesignSpacing.sm),
            decoration: BoxDecoration(
              color: DesignColors.cyan.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(DesignRadius.sm),
            ),
            child: Row(
              children: [
                Icon(Icons.speed_rounded, color: DesignColors.cyan, size: 18),
                SizedBox(width: DesignSpacing.sm),
                Text(
                  'Promedio: ${avgPredictionsPerHour.toStringAsFixed(1)} predicciones/hora',
                  style: DesignTextStyles.bodyText.copyWith(color: DesignColors.cyan),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
