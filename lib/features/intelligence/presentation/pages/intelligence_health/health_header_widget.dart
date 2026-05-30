import 'package:flutter/material.dart';
import '../../../data/ml_health_thresholds.dart';
import '../../widgets/intelligence_health_helpers.dart';
import '../../../../../../core/theme/design_colors.dart';
import '../../../../../../core/theme/design_spacing.dart';
import '../../../../../../core/theme/design_text_styles.dart';


/// Semáforo de salud del modelo ML con umbrales configurables.
class _HealthTrafficLight extends StatelessWidget {
  const _HealthTrafficLight({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status) {
      case 'green':
        color = Colors.green;
      case 'yellow':
        color = Colors.amber;
      case 'red':
        color = Colors.red;
      default:
        color = Colors.grey;
    }
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

/// Health header widget showing model health score, status and traffic light.
class HealthHeaderWidget extends StatelessWidget {
  const HealthHeaderWidget({
    super.key,
    required this.healthLabel,
    required this.healthScore,
    required this.modelHealth,
    this.accuracyPct,
    this.driftRate,
    this.hoursSinceUpdate,
  });

  final String healthLabel;
  final int healthScore;
  final String modelHealth;
  final double? accuracyPct;
  final double? driftRate;
  final int? hoursSinceUpdate;

  @override
  Widget build(BuildContext context) {
    final gradient = IntelligenceHealthHelpers.getHealthGradient(modelHealth);
    final icon = IntelligenceHealthHelpers.getHealthIcon(modelHealth);

    final accStatus = accuracyPct != null
        ? MlHealthThresholds.accuracyStatus(accuracyPct! / 100)
        : 'unknown';
    final driftStatus = driftRate != null
        ? MlHealthThresholds.driftStatus(driftRate!)
        : 'unknown';
    final freshStatus = hoursSinceUpdate != null
        ? MlHealthThresholds.freshnessStatus(hoursSinceUpdate!)
        : 'unknown';

    return Container(
      padding: EdgeInsets.all(DesignSpacing.lg),
      decoration: BoxDecoration(gradient: gradient, borderRadius: BorderRadius.circular(DesignRadius.lg)),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(DesignSpacing.md),
                decoration: BoxDecoration(
                  color: DesignColors.textPrimary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(DesignRadius.md),
                ),
                child: Icon(icon, color: Colors.white, size: 28),
              ),
              SizedBox(width: DesignSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(healthLabel, style: DesignTextStyles.screenTitle),
                    SizedBox(height: DesignSpacing.xs),
                    Text(
                      'Puntuación de salud',
                      style: TextStyle(color: DesignColors.textPrimary, fontSize: 13),
                    ),
                  ],
                ),
              ),
              // Semáforo
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(DesignRadius.sm),
                ),
                child: Row(
                  children: [
                    Column(
                      children: [
                        _HealthTrafficLight(status: accStatus),
                        SizedBox(height: DesignSpacing.xs),
                        Text('ACC', style: TextStyle(color: DesignColors.textSecondary, fontSize: 8)),
                      ],
                    ),
                    SizedBox(width: 6),
                    Column(
                      children: [
                        _HealthTrafficLight(status: driftStatus),
                        SizedBox(height: DesignSpacing.xs),
                        Text('DRIFT', style: TextStyle(color: DesignColors.textSecondary, fontSize: 8)),
                      ],
                    ),
                    SizedBox(width: 6),
                    Column(
                      children: [
                        _HealthTrafficLight(status: freshStatus),
                        SizedBox(height: DesignSpacing.xs),
                        Text('FRESH', style: TextStyle(color: DesignColors.textSecondary, fontSize: 8)),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(width: DesignSpacing.md),
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: DesignColors.textPrimary.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '$healthScore',
                    style: const TextStyle(
                      color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: DesignSpacing.lg),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: healthScore / 100,
              backgroundColor: DesignColors.textPrimary.withValues(alpha: 0.2),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }
}
