import 'package:flutter/material.dart';

import '../../../../monitoring/presentation/styles/dashboard_styles.dart';
import '../../../data/ml_health_thresholds.dart';
import '../../widgets/intelligence_health_helpers.dart';

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
      padding: const EdgeInsets.all(20),
      decoration: ModernCardDecoration.gradient(gradient),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(healthLabel, style: DashboardTextStyles.sectionHeader),
                    const SizedBox(height: 4),
                    const Text(
                      'Puntuación de salud',
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ],
                ),
              ),
              // Semáforo
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Column(
                      children: [
                        _HealthTrafficLight(status: accStatus),
                        const SizedBox(height: 4),
                        const Text('ACC', style: TextStyle(color: Colors.white54, fontSize: 8)),
                      ],
                    ),
                    const SizedBox(width: 6),
                    Column(
                      children: [
                        _HealthTrafficLight(status: driftStatus),
                        const SizedBox(height: 4),
                        const Text('DRIFT', style: TextStyle(color: Colors.white54, fontSize: 8)),
                      ],
                    ),
                    const SizedBox(width: 6),
                    Column(
                      children: [
                        _HealthTrafficLight(status: freshStatus),
                        const SizedBox(height: 4),
                        const Text('FRESH', style: TextStyle(color: Colors.white54, fontSize: 8)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
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
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: healthScore / 100,
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }
}
