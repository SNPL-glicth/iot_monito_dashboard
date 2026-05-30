import 'package:flutter/material.dart';
import '../../../../../../core/theme/design_colors.dart';
import '../../../../../../core/theme/design_spacing.dart';
import '../../../../../../core/theme/design_text_styles.dart';


/// Warnings section widget showing model warnings
class WarningsSectionWidget extends StatelessWidget {
  const WarningsSectionWidget({
    super.key,
    required this.warnings,
  });

  final List<String> warnings;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(DesignSpacing.lg),
      decoration: BoxDecoration(
        color: DesignColors.amber.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(DesignRadius.lg),
        border: Border.all(color: DesignColors.amber.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning_rounded, color: DesignColors.amber, size: 20),
              SizedBox(width: DesignSpacing.sm),
              Text(
                'Advertencias',
                style: DesignTextStyles.cardTitle.copyWith(color: DesignColors.amber),
              ),
            ],
          ),
          SizedBox(height: DesignSpacing.md),
          ...warnings.map(
            (w) => Padding(
              padding: EdgeInsets.only(bottom: DesignSpacing.sm),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    margin: EdgeInsets.only(top: 6),
                    decoration: BoxDecoration(
                      color: DesignColors.amber,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: DesignSpacing.sm),
                  Expanded(child: Text(w, style: DesignTextStyles.bodyText)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Recommendations section widget showing model recommendations
class RecommendationsSectionWidget extends StatelessWidget {
  const RecommendationsSectionWidget({
    super.key,
    required this.recommendations,
  });

  final List<String> recommendations;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(DesignSpacing.lg),
      decoration: BoxDecoration(
        color: DesignColors.cyan.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(DesignRadius.lg),
        border: Border.all(color: DesignColors.cyan.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb_outline_rounded, color: DesignColors.cyan, size: 20),
              SizedBox(width: DesignSpacing.sm),
              Text(
                'Recomendaciones',
                style: DesignTextStyles.cardTitle.copyWith(color: DesignColors.cyan),
              ),
            ],
          ),
          SizedBox(height: DesignSpacing.md),
          ...recommendations.map(
            (r) => Padding(
              padding: EdgeInsets.only(bottom: DesignSpacing.sm),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    margin: EdgeInsets.only(top: 6),
                    decoration: BoxDecoration(
                      color: DesignColors.cyan,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: DesignSpacing.sm),
                  Expanded(child: Text(r, style: DesignTextStyles.bodyText)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
