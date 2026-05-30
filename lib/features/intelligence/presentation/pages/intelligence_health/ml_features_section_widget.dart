import 'package:flutter/material.dart';
import '../../../../devices/presentation/widgets/ml_model_state_widget.dart';
import '../../widgets/intelligence_health_widgets.dart';
import '../../../../../../core/theme/design_colors.dart';
import '../../../../../../core/theme/design_spacing.dart';
import '../../../../../../core/theme/design_text_styles.dart';


/// ML features section widget showing model features
class MLFeaturesSectionWidget extends StatelessWidget {
  const MLFeaturesSectionWidget({
    super.key,
    required this.mlFeatures,
  });

  final dynamic mlFeatures;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(DesignSpacing.lg),
      decoration: BoxDecoration(color: DesignColors.surface, border: Border.all(color: DesignColors.border, width: 0.5), borderRadius: BorderRadius.circular(DesignRadius.lg)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IntelligenceHealthWidgets.sectionHeader(Icons.psychology_rounded, 'Features del Modelo ML', DesignColors.green),
          SizedBox(height: DesignSpacing.lg),
          MLModelStateWidget(
            features: mlFeatures,
            compact: false,
            showDetails: true,
          ),
          if (mlFeatures == null)
            Container(
              margin: EdgeInsets.only(top: 12),
              padding: EdgeInsets.all(DesignSpacing.md),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(DesignRadius.sm),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline_rounded, color: Colors.grey, size: 18),
                  SizedBox(width: DesignSpacing.sm),
                  Expanded(
                    child: Text(
                      'Las features del modelo ML muestran confianza, patrones y anomalías en tiempo real.',
                      style: DesignTextStyles.bodyText,
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
