import 'package:flutter/material.dart';

import '../../../../monitoring/presentation/styles/dashboard_styles.dart';
import '../../../../devices/presentation/widgets/ml_model_state_widget.dart';
import '../../widgets/intelligence_health_widgets.dart';

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
      padding: const EdgeInsets.all(16),
      decoration: ModernCardDecoration.elevated(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IntelligenceHealthWidgets.sectionHeader(Icons.psychology_rounded, 'Features del Modelo ML', DashboardColors.accent),
          const SizedBox(height: 16),
          MLModelStateWidget(
            features: mlFeatures,
            compact: false,
            showDetails: true,
          ),
          if (mlFeatures == null)
            Container(
              margin: const EdgeInsets.only(top: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline_rounded, color: Colors.grey, size: 18),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Las features del modelo ML muestran confianza, patrones y anomalías en tiempo real.',
                      style: DashboardTextStyles.sensorMeta,
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
