import 'package:flutter/material.dart';
import '../../widgets/intelligence_health_widgets.dart';
import '../../../../../../core/theme/design_colors.dart';
import '../../../../../../core/theme/design_spacing.dart';
import '../../../../../../core/theme/design_text_styles.dart';


/// Error margin section widget showing error margin analysis
class ErrorMarginSectionWidget extends StatelessWidget {
  const ErrorMarginSectionWidget({
    super.key,
    required this.estimatedMarginPct,
    required this.isReliable,
    required this.marginConfidence,
    required this.explanation,
  });

  final double estimatedMarginPct;
  final bool isReliable;
  final double marginConfidence;
  final String explanation;

  @override
  Widget build(BuildContext context) {
    final reliableColor = isReliable ? DesignColors.green : DesignColors.amber;

    return Container(
      padding: EdgeInsets.all(DesignSpacing.lg),
      decoration: BoxDecoration(color: DesignColors.surface, border: Border.all(color: DesignColors.border, width: 0.5), borderRadius: BorderRadius.circular(DesignRadius.lg)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IntelligenceHealthWidgets.sectionHeader(Icons.straighten_rounded, 'Margen de Error', Colors.deepOrange),
          SizedBox(height: DesignSpacing.lg),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '±${estimatedMarginPct.toStringAsFixed(1)}%',
                      style: DesignTextStyles.kpiValue.copyWith(fontSize: 28),
                    ),
                    SizedBox(height: DesignSpacing.xs),
                    Text('Margen estimado', style: DesignTextStyles.bodyText),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(DesignSpacing.sm),
                      decoration: BoxDecoration(
                        color: reliableColor.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isReliable ? Icons.verified_rounded : Icons.help_outline_rounded,
                        color: reliableColor,
                        size: 24,
                      ),
                    ),
                    SizedBox(height: DesignSpacing.xs),
                    Text(
                      isReliable ? 'Confiable' : 'Estimado',
                      style: DesignTextStyles.bodyText.copyWith(
                        fontSize: 11,
                        color: reliableColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: DesignSpacing.lg),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Confianza del margen', style: DesignTextStyles.bodyText),
                  Text('${(marginConfidence * 100).toStringAsFixed(0)}%', style: DesignTextStyles.timestamp),
                ],
              ),
              SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: marginConfidence,
                  backgroundColor: Colors.white.withValues(alpha: 0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(reliableColor),
                  minHeight: 8,
                ),
              ),
            ],
          ),
          SizedBox(height: DesignSpacing.md),
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: reliableColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(DesignRadius.sm),
            ),
            child: Text(explanation, style: DesignTextStyles.bodyText.copyWith(fontSize: 11)),
          ),
        ],
      ),
    );
  }
}
