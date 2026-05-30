import 'package:flutter/material.dart';
import '../../../data/intelligence_models.dart';
import '../intelligence_decisions_helpers.dart';
import '../../../../../../core/theme/design_colors.dart';
import '../../../../../../core/theme/design_spacing.dart';
import '../../../../../../core/theme/design_text_styles.dart';


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
      margin: EdgeInsets.only(bottom: DesignSpacing.lg),
      decoration: BoxDecoration(color: DesignColors.surface, border: Border.all(color: DesignColors.border, width: 0.5), borderRadius: BorderRadius.circular(DesignRadius.lg)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(DesignSpacing.lg),
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
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: severityColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(DesignRadius.md),
                  ),
                  child: Icon(IntelligenceDecisionsHelpers.severityIcon(decision.severity), color: severityColor, size: 22),
                ),
                SizedBox(width: DesignSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        decision.title,
                        style: DesignTextStyles.cardTitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: DesignSpacing.xs),
                      Text(
                        IntelligenceDecisionsHelpers.formatAge(decision.ageMinutes),
                        style: DesignTextStyles.timestamp,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(DesignRadius.xl),
                    border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(IntelligenceDecisionsHelpers.statusIcon(decision.status), size: 14, color: statusColor),
                      SizedBox(width: 4),
                      Text(
                        IntelligenceDecisionsHelpers.statusLabel(decision.status),
                        style: DesignTextStyles.timestamp.copyWith(color: statusColor),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(DesignSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  decision.summary,
                  style: DesignTextStyles.bodyText,
                ),
                SizedBox(height: DesignSpacing.lg),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    IntelligenceDecisionsHelpers.buildMetaChip(Icons.devices_rounded, decision.deviceName, DesignColors.cyanDim),
                    IntelligenceDecisionsHelpers.buildMetaChip(Icons.sensors_rounded, '${decision.affectedSensorIds.length} sensores', DesignColors.cyan),
                    IntelligenceDecisionsHelpers.buildMetaChip(Icons.event_rounded, '${decision.eventCount} eventos', DesignColors.amber),
                  ],
                ),
                if (decision.recommendedActions.isNotEmpty) ...[
                  SizedBox(height: DesignSpacing.lg),
                  Row(
                    children: [
                      Icon(Icons.lightbulb_outline_rounded, color: DesignColors.amber, size: 18),
                      SizedBox(width: DesignSpacing.sm),
                      Text('Acciones recomendadas', style: DesignTextStyles.bodyText),
                    ],
                  ),
                  SizedBox(height: DesignSpacing.md),
                  ...decision.recommendedActions.take(3).map((action) => IntelligenceDecisionsHelpers.buildActionItem(action)),
                  if (decision.recommendedActions.length > 3)
                    Padding(
                      padding: EdgeInsets.only(top: DesignSpacing.sm),
                      child: Text(
                        '+ ${decision.recommendedActions.length - 3} acciones más',
                        style: DesignTextStyles.timestamp,
                      ),
                    ),
                ],
              ],
            ),
          ),
          if (decision.status != 'resolved')
            Container(
              padding: EdgeInsets.all(DesignSpacing.lg),
              decoration: BoxDecoration(
                color: DesignColors.border,
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
                          foregroundColor: DesignColors.cyan,
                          side: BorderSide(color: DesignColors.cyan),
                          padding: EdgeInsets.symmetric(vertical: DesignSpacing.md),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(DesignRadius.sm)),
                        ),
                      ),
                    ),
                  if (decision.status == 'pending') SizedBox(width: DesignSpacing.md),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => onUpdateStatus('resolved'),
                      icon: const Icon(Icons.check_rounded, size: 18),
                      label: const Text('Resolver'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: DesignColors.green,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: DesignSpacing.md),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(DesignRadius.sm)),
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
