import 'package:flutter/material.dart';
import '../../../../../../core/theme/design_colors.dart';
import '../../../../../../core/theme/design_spacing.dart';
import '../../../../../../core/theme/design_text_styles.dart';


/// Ignored data section widget showing data the model ignores by design
class IgnoredDataSectionWidget extends StatelessWidget {
  const IgnoredDataSectionWidget({
    super.key,
    required this.reasons,
  });

  final List<dynamic> reasons;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(DesignSpacing.lg),
      decoration: BoxDecoration(
        color: DesignColors.textSecondary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(DesignRadius.lg),
        border: Border.all(color: DesignColors.textSecondary.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.visibility_off_rounded, color: DesignColors.textSecondary, size: 20),
              SizedBox(width: DesignSpacing.sm),
              Text(
                'Datos que el Modelo Ignora',
                style: DesignTextStyles.cardTitle.copyWith(color: DesignColors.textSecondary),
              ),
            ],
          ),
          SizedBox(height: DesignSpacing.xs),
          Text(
            'Estos datos no afectan las predicciones por diseño',
            style: DesignTextStyles.bodyText.copyWith(fontSize: 11),
          ),
          SizedBox(height: DesignSpacing.md),
          ...reasons.map(
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
                      color: DesignColors.textSecondary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: DesignSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text('${r.description}', style: DesignTextStyles.bodyText),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: DesignSpacing.sm, vertical: DesignSpacing.xs),
                              decoration: BoxDecoration(
                                color: DesignColors.textSecondary.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(DesignRadius.sm),
                              ),
                              child: Text(
                                '${r.count}',
                                style: DesignTextStyles.bodyText.copyWith(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
