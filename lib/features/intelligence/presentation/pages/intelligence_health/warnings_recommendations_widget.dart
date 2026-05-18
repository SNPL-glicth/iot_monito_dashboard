import 'package:flutter/material.dart';

import '../../../../monitoring/presentation/styles/dashboard_styles.dart';

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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DashboardColors.warning.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: DashboardColors.warning.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning_rounded, color: DashboardColors.warning, size: 20),
              const SizedBox(width: 8),
              Text(
                'Advertencias',
                style: DashboardTextStyles.deviceTitle.copyWith(color: DashboardColors.warning),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...warnings.map(
            (w) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    margin: const EdgeInsets.only(top: 6),
                    decoration: BoxDecoration(
                      color: DashboardColors.warning,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(child: Text(w, style: DashboardTextStyles.sensorMeta)),
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DashboardColors.info.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: DashboardColors.info.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb_outline_rounded, color: DashboardColors.info, size: 20),
              const SizedBox(width: 8),
              Text(
                'Recomendaciones',
                style: DashboardTextStyles.deviceTitle.copyWith(color: DashboardColors.info),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...recommendations.map(
            (r) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    margin: const EdgeInsets.only(top: 6),
                    decoration: BoxDecoration(
                      color: DashboardColors.info,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(child: Text(r, style: DashboardTextStyles.sensorMeta)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
