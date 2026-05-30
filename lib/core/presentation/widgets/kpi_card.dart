import 'package:flutter/material.dart';
import '../../theme/design_colors.dart';
import '../../theme/design_spacing.dart';
import '../../theme/design_text_styles.dart';

class KpiCard extends StatelessWidget {
  const KpiCard({
    super.key,
    required this.label,
    required this.value,
    this.unit,
    this.trend,
    this.accentColor = DesignColors.cyan,
    this.onTap,
  });

  final String label;
  final String value;
  final String? unit;
  final double? trend;
  final Color accentColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: DesignColors.surface,
      borderRadius: BorderRadius.circular(DesignRadius.md),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(DesignRadius.md),
        splashColor: DesignColors.cyan.withValues(alpha: 0.1),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: DesignColors.border, width: 0.5),
            borderRadius: BorderRadius.circular(DesignRadius.md),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 2,
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(DesignRadius.md),
                    topRight: Radius.circular(DesignRadius.md),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(DesignSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label.toUpperCase(),
                        style: DesignTextStyles.sectionTitle),
                    SizedBox(height: DesignSpacing.sm),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(value, style: DesignTextStyles.kpiValue),
                        if (unit != null) ...[
                          SizedBox(width: DesignSpacing.xs),
                          Text(unit!, style: DesignTextStyles.bodyText),
                        ],
                      ],
                    ),
                    if (trend != null) ...[
                      SizedBox(height: DesignSpacing.xs),
                      _TrendIndicator(trend: trend!),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TrendIndicator extends StatelessWidget {
  const _TrendIndicator({required this.trend});

  final double trend;

  @override
  Widget build(BuildContext context) {
    final isUp = trend >= 0;
    final color = isUp ? DesignColors.green : DesignColors.red;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          isUp ? Icons.arrow_upward : Icons.arrow_downward,
          size: 12,
          color: color,
        ),
        SizedBox(width: 2),
        Text(
          '${trend.abs().toStringAsFixed(1)}%',
          style: DesignTextStyles.bodyText.copyWith(color: color),
        ),
      ],
    );
  }
}
