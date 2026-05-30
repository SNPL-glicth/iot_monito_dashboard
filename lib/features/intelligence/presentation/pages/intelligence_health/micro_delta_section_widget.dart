import 'package:flutter/material.dart';
import '../../widgets/intelligence_health_widgets.dart';
import '../../../../../../core/theme/design_colors.dart';
import '../../../../../../core/theme/design_spacing.dart';
import '../../../../../../core/theme/design_text_styles.dart';


/// Micro delta section widget showing sensitivity to micro-changes
class MicroDeltaSectionWidget extends StatelessWidget {
  const MicroDeltaSectionWidget({
    super.key,
    required this.microChangeRate,
    required this.totalChanges,
    required this.microChanges,
    required this.ignoredChangesCount,
    required this.sensitivityThreshold,
  });

  final double microChangeRate;
  final int totalChanges;
  final int microChanges;
  final int ignoredChangesCount;
  final double sensitivityThreshold;

  @override
  Widget build(BuildContext context) {
    final microRate = microChangeRate;
    final rateColor = microRate > 70 ? DesignColors.textSecondary : microRate > 30 ? DesignColors.cyan : DesignColors.green;

    return Container(
      padding: EdgeInsets.all(DesignSpacing.lg),
      decoration: BoxDecoration(color: DesignColors.surface, border: Border.all(color: DesignColors.border, width: 0.5), borderRadius: BorderRadius.circular(DesignRadius.lg)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IntelligenceHealthWidgets.sectionHeader(Icons.tune_rounded, 'Sensibilidad a Micro-cambios', Colors.cyan),
          SizedBox(height: DesignSpacing.lg),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Tasa de micro-cambios', style: DesignTextStyles.bodyText),
                  Text('${microRate.toStringAsFixed(1)}%', style: DesignTextStyles.timestamp),
                ],
              ),
              SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: microRate / 100,
                  backgroundColor: Colors.white.withValues(alpha: 0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(rateColor),
                  minHeight: 8,
                ),
              ),
            ],
          ),
          SizedBox(height: DesignSpacing.lg),
          Row(
            children: [
              Expanded(
                child: IntelligenceHealthWidgets.miniMetric(
                  'Total cambios',
                  '$totalChanges',
                  Icons.swap_vert_rounded,
                ),
              ),
              Expanded(
                child: IntelligenceHealthWidgets.miniMetric(
                  'Micro-cambios',
                  '$microChanges',
                  Icons.grain_rounded,
                  color: DesignColors.textSecondary,
                ),
              ),
              Expanded(
                child: IntelligenceHealthWidgets.miniMetric(
                  'Ignorados',
                  '$ignoredChangesCount',
                  Icons.visibility_off_rounded,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          SizedBox(height: DesignSpacing.md),
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: DesignColors.textSecondary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(DesignRadius.sm),
            ),
            child: Text(
              'Cambios menores a $sensitivityThreshold% no afectan la predicción. '
              'Esto es comportamiento esperado para sensores estables.',
              style: DesignTextStyles.bodyText.copyWith(fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }
}
