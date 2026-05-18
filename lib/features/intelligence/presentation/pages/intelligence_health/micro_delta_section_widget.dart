import 'package:flutter/material.dart';

import '../../../../monitoring/presentation/styles/dashboard_styles.dart';
import '../../widgets/intelligence_health_widgets.dart';

/// Micro delta section widget showing sensitivity to micro-changes
class MicroDeltaSectionWidget extends StatelessWidget {
  const MicroDeltaSectionWidget({
    super.key,
    required this.microChangeRate,
    required this.totalChanges,
    required this.microChanges,
    required this.ignoredChangesCount,
    required this.sensitivityThreshold,
  });

  final double microChangeRate;
  final int totalChanges;
  final int microChanges;
  final int ignoredChangesCount;
  final double sensitivityThreshold;

  @override
  Widget build(BuildContext context) {
    final microRate = microChangeRate;
    final rateColor = microRate > 70 ? Colors.blueGrey : microRate > 30 ? DashboardColors.info : DashboardColors.success;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: ModernCardDecoration.elevated(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IntelligenceHealthWidgets.sectionHeader(Icons.tune_rounded, 'Sensibilidad a Micro-cambios', Colors.cyan),
          const SizedBox(height: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Tasa de micro-cambios', style: DashboardTextStyles.sensorMeta),
                  Text('${microRate.toStringAsFixed(1)}%', style: DashboardTextStyles.smallLabel),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: microRate / 100,
                  backgroundColor: Colors.white.withValues(alpha: 0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(rateColor),
                  minHeight: 8,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: IntelligenceHealthWidgets.miniMetric(
                  'Total cambios',
                  '$totalChanges',
                  Icons.swap_vert_rounded,
                ),
              ),
              Expanded(
                child: IntelligenceHealthWidgets.miniMetric(
                  'Micro-cambios',
                  '$microChanges',
                  Icons.grain_rounded,
                  color: Colors.blueGrey,
                ),
              ),
              Expanded(
                child: IntelligenceHealthWidgets.miniMetric(
                  'Ignorados',
                  '$ignoredChangesCount',
                  Icons.visibility_off_rounded,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.blueGrey.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Cambios menores a $sensitivityThreshold% no afectan la predicción. '
              'Esto es comportamiento esperado para sensores estables.',
              style: DashboardTextStyles.sensorMeta.copyWith(fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }
}
