import 'package:flutter/material.dart';
import '../../widgets/intelligence_health_helpers.dart';
import '../../widgets/intelligence_health_widgets.dart';
import '../../../../../../core/theme/design_colors.dart';
import '../../../../../../core/theme/design_spacing.dart';
import '../../../../../../core/theme/design_text_styles.dart';


/// Pattern analysis section widget showing detected patterns
class PatternAnalysisSectionWidget extends StatelessWidget {
  const PatternAnalysisSectionWidget({
    super.key,
    required this.patternsDetected,
    required this.dominantPattern,
  });

  final List<dynamic> patternsDetected;
  final String? dominantPattern;

  @override
  Widget build(BuildContext context) {
    final hasPatterns = patternsDetected.isNotEmpty;

    return Container(
      padding: EdgeInsets.all(DesignSpacing.lg),
      decoration: BoxDecoration(color: DesignColors.surface, border: Border.all(color: DesignColors.border, width: 0.5), borderRadius: BorderRadius.circular(DesignRadius.lg)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IntelligenceHealthWidgets.sectionHeader(Icons.pattern_rounded, 'Patrones Detectados', Colors.indigo),
          SizedBox(height: DesignSpacing.lg),
          if (!hasPatterns)
            Container(
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
                      'Sin patrones detectados en la ventana de análisis',
                      style: DesignTextStyles.bodyText,
                    ),
                  ),
                ],
              ),
            )
          else ...[
            if (dominantPattern != null)
              Container(
                padding: EdgeInsets.symmetric(horizontal: DesignSpacing.md, vertical: DesignSpacing.sm),
                margin: EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: IntelligenceHealthHelpers.getPatternColor(dominantPattern!).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(DesignRadius.sm),
                  border: Border.all(
                    color: IntelligenceHealthHelpers.getPatternColor(dominantPattern!).withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      IntelligenceHealthHelpers.getPatternIcon(dominantPattern!),
                      color: IntelligenceHealthHelpers.getPatternColor(dominantPattern!),
                      size: 20,
                    ),
                    SizedBox(width: DesignSpacing.sm),
                    Text('Patrón dominante: ', style: DesignTextStyles.bodyText),
                    Text(
                      IntelligenceHealthHelpers.getPatternLabel(dominantPattern!),
                      style: DesignTextStyles.timestamp.copyWith(
                        color: IntelligenceHealthHelpers.getPatternColor(dominantPattern!),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ],
      ),
    );
  }
}
