import 'package:flutter/material.dart';

import '../../../../monitoring/presentation/styles/dashboard_styles.dart';
import '../../widgets/intelligence_health_helpers.dart';

/// Health header widget showing model health score and status
class HealthHeaderWidget extends StatelessWidget {
  const HealthHeaderWidget({
    super.key,
    required this.healthLabel,
    required this.healthScore,
    required this.modelHealth,
  });

  final String healthLabel;
  final int healthScore;
  final String modelHealth;

  @override
  Widget build(BuildContext context) {
    final gradient = IntelligenceHealthHelpers.getHealthGradient(modelHealth);
    final icon = IntelligenceHealthHelpers.getHealthIcon(modelHealth);

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
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
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
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
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
