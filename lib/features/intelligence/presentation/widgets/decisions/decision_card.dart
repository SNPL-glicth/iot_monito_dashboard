import 'package:flutter/material.dart';

import '../../../../../features/monitoring/presentation/styles/dashboard_styles.dart';
import '../../../data/intelligence_models.dart';
import '../intelligence_decisions_helpers.dart';

/// Tarjeta de decisión del sistema con severidad, estado, metadatos y acciones.
class DecisionCard extends StatelessWidget {
  const DecisionCard({
    super.key,
    required this.decision,
    required this.onUpdateStatus,
  });

  final DecisionActionViewModel decision;
  final ValueChanged<String> onUpdateStatus;

  @override
  Widget build(BuildContext context) {
    final severityColor = IntelligenceDecisionsHelpers.severityColor(decision.severity);
    final statusColor = IntelligenceDecisionsHelpers.statusColor(decision.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: ModernCardDecoration.elevated(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  severityColor.withValues(alpha: 0.2),
                  severityColor.withValues(alpha: 0.05),
                ],
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: severityColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(IntelligenceDecisionsHelpers.severityIcon(decision.severity), color: severityColor, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        decision.title,
                        style: DashboardTextStyles.deviceTitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        IntelligenceDecisionsHelpers.formatAge(decision.ageMinutes),
                        style: DashboardTextStyles.smallLabel,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(IntelligenceDecisionsHelpers.statusIcon(decision.status), size: 14, color: statusColor),
                      const SizedBox(width: 4),
                      Text(
                        IntelligenceDecisionsHelpers.statusLabel(decision.status),
                        style: DashboardTextStyles.smallLabel.copyWith(color: statusColor),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  decision.summary,
                  style: DashboardTextStyles.alertText,
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    IntelligenceDecisionsHelpers.buildMetaChip(Icons.devices_rounded, decision.deviceName, DashboardColors.secondary),
                    IntelligenceDecisionsHelpers.buildMetaChip(Icons.sensors_rounded, '${decision.affectedSensorIds.length} sensores', DashboardColors.info),
                    IntelligenceDecisionsHelpers.buildMetaChip(Icons.event_rounded, '${decision.eventCount} eventos', DashboardColors.warning),
                  ],
                ),
                if (decision.recommendedActions.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      const Icon(Icons.lightbulb_outline_rounded, color: DashboardColors.warning, size: 18),
                      const SizedBox(width: 8),
                      const Text('Acciones recomendadas', style: DashboardTextStyles.sensorTitle),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...decision.recommendedActions.take(3).map((action) => IntelligenceDecisionsHelpers.buildActionItem(action)),
                  if (decision.recommendedActions.length > 3)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        '+ ${decision.recommendedActions.length - 3} acciones más',
                        style: DashboardTextStyles.smallLabel,
                      ),
                    ),
                ],
              ],
            ),
          ),
          if (decision.status != 'resolved')
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: DashboardColors.white05,
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
              ),
              child: Row(
                children: [
                  if (decision.status == 'pending')
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => onUpdateStatus('acknowledged'),
                        icon: const Icon(Icons.visibility_rounded, size: 18),
                        label: const Text('Marcar visto'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: DashboardColors.info,
                          side: const BorderSide(color: DashboardColors.info),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                  if (decision.status == 'pending') const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => onUpdateStatus('resolved'),
                      icon: const Icon(Icons.check_rounded, size: 18),
                      label: const Text('Resolver'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: DashboardColors.success,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
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
