import 'package:flutter/material.dart';

import '../../../data/intelligence_models.dart';
import '../../../../../core/theme/design_colors.dart';

/// Helpers de estilo para predicciones del sistema.
class PredictionHelpers {
  static IconData trendIcon(String trend) {
    switch (trend.toLowerCase()) {
      case 'up':
        return Icons.arrow_upward_rounded;
      case 'down':
        return Icons.arrow_downward_rounded;
      default:
        return Icons.horizontal_rule_rounded;
    }
  }

  static Color trendColor(String trend) {
    switch (trend.toLowerCase()) {
      case 'up':
        return DesignColors.amber;
      case 'down':
        return DesignColors.cyan;
      default:
        return Colors.grey;
    }
  }

  static Color severityColor(String severity) {
    final s = severity.toUpperCase();
    if (s == 'CRITICAL') return DesignColors.red;
    if (s == 'HIGH' || s == 'WARNING') return DesignColors.amber;
    if (s == 'MEDIUM') return Colors.amberAccent;
    return Colors.greenAccent;
  }

  static String severityLabel(String severity) {
    final s = severity.toUpperCase();
    if (s == 'CRITICAL') return 'Crítica';
    if (s == 'HIGH' || s == 'WARNING') return 'Alta';
    if (s == 'MEDIUM') return 'Media';
    return 'Baja';
  }

  static String anomalyLabel(PredictionSummaryViewModel p) {
    final sev = p.severity.toUpperCase().trim();
    if (sev == 'CRITICAL') return 'Anomalía crítica';
    if (sev == 'HIGH' || sev == 'WARNING') return 'Anomalía relevante';
    if (sev == 'MEDIUM') return 'Anomalía moderada';
    final score = p.anomalyScore.clamp(0.0, 1.0);
    if (!p.isAnomaly || score < 0.2) return 'Normal';
    if (score < 0.6) return 'Anomalía leve';
    return 'Anomalía fuerte';
  }
}
