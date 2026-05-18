import 'package:flutter/material.dart';

import '../../../../monitoring/presentation/styles/dashboard_styles.dart';
import '../../widgets/intelligence_health_widgets.dart';

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
    final reliableColor = isReliable ? DashboardColors.success : DashboardColors.warning;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: ModernCardDecoration.elevated(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IntelligenceHealthWidgets.sectionHeader(Icons.straighten_rounded, 'Margen de Error', Colors.deepOrange),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '±${estimatedMarginPct.toStringAsFixed(1)}%',
                      style: DashboardTextStyles.kpiValue.copyWith(fontSize: 28),
                    ),
                    const SizedBox(height: 4),
                    const Text('Margen estimado', style: DashboardTextStyles.sensorMeta),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
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
                    const SizedBox(height: 4),
                    Text(
                      isReliable ? 'Confiable' : 'Estimado',
                      style: DashboardTextStyles.sensorMeta.copyWith(
                        fontSize: 11,
                        color: reliableColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Confianza del margen', style: DashboardTextStyles.sensorMeta),
                  Text('${(marginConfidence * 100).toStringAsFixed(0)}%', style: DashboardTextStyles.smallLabel),
                ],
              ),
              const SizedBox(height: 6),
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
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: reliableColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(explanation, style: DashboardTextStyles.sensorMeta.copyWith(fontSize: 11)),
          ),
        ],
      ),
    );
  }
}
