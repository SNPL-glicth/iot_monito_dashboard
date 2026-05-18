import 'package:flutter/material.dart';

import '../../../../monitoring/presentation/styles/dashboard_styles.dart';
import '../../widgets/intelligence_health_helpers.dart';
import '../../widgets/intelligence_health_widgets.dart';

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
      padding: const EdgeInsets.all(16),
      decoration: ModernCardDecoration.elevated(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IntelligenceHealthWidgets.sectionHeader(Icons.pattern_rounded, 'Patrones Detectados', Colors.indigo),
          const SizedBox(height: 16),
          if (!hasPatterns)
            Container(
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
                      'Sin patrones detectados en la ventana de análisis',
                      style: DashboardTextStyles.sensorMeta,
                    ),
                  ),
                ],
              ),
            )
          else ...[
            if (dominantPattern != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: IntelligenceHealthHelpers.getPatternColor(dominantPattern!).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
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
                    const SizedBox(width: 8),
                    const Text('Patrón dominante: ', style: DashboardTextStyles.sensorMeta),
                    Text(
                      IntelligenceHealthHelpers.getPatternLabel(dominantPattern!),
                      style: DashboardTextStyles.smallLabel.copyWith(
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
