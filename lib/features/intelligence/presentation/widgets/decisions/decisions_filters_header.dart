import 'package:flutter/material.dart';
import '../intelligence_decisions_helpers.dart';
import '../../../../../../core/theme/design_colors.dart';
import '../../../../../../core/theme/design_spacing.dart';
import '../../../../../../core/theme/design_text_styles.dart';


/// Header de la página de decisiones con filtros y última actualización.
class DecisionsFiltersHeader extends StatelessWidget {
  const DecisionsFiltersHeader({
    super.key,
    required this.lastUpdated,
    required this.statusFilter,
    required this.severityFilter,
    required this.onStatusChanged,
    required this.onSeverityChanged,
  });

  final DateTime? lastUpdated;
  final String statusFilter;
  final String severityFilter;
  final ValueChanged<String> onStatusChanged;
  final ValueChanged<String> onSeverityChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(DesignSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(DesignSpacing.sm),
                decoration: BoxDecoration(
                  color: DesignColors.cyan.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(DesignRadius.sm),
                ),
                child: Icon(
                  Icons.task_alt_rounded,
                  color: DesignColors.cyan,
                  size: 20,
                ),
              ),
              SizedBox(width: DesignSpacing.md),
              Text('Decisiones', style: DesignTextStyles.screenTitle),
            ],
          ),
          if (lastUpdated != null)
            Padding(
              padding: EdgeInsets.only(top: DesignSpacing.sm),
              child: Text(
                IntelligenceDecisionsHelpers.formatLastUpdated(lastUpdated),
                style: DesignTextStyles.timestamp,
              ),
            ),
          SizedBox(height: DesignSpacing.lg),
          Container(
            padding: EdgeInsets.all(DesignSpacing.md),
            decoration: BoxDecoration(color: DesignColors.surface, border: Border.all(color: DesignColors.border, width: 0.5), borderRadius: BorderRadius.circular(DesignRadius.lg)),
            child: Row(
              children: [
                Expanded(
                  child: IntelligenceDecisionsHelpers.buildFilterChip(
                    label: 'Estado',
                    value: statusFilter.isEmpty ? 'Todos' : IntelligenceDecisionsHelpers.statusLabel(statusFilter),
                    options: const [
                      {'value': '', 'label': 'Todos'},
                      {'value': 'pending', 'label': 'Pendiente'},
                      {'value': 'acknowledged', 'label': 'En proceso'},
                      {'value': 'resolved', 'label': 'Resuelto'},
                    ],
                    onChanged: onStatusChanged,
                  ),
                ),
                SizedBox(width: DesignSpacing.md),
                Expanded(
                  child: IntelligenceDecisionsHelpers.buildFilterChip(
                    label: 'Severidad',
                    value: severityFilter.isEmpty ? 'Todas' : severityFilter,
                    options: const [
                      {'value': '', 'label': 'Todas'},
                      {'value': 'critical', 'label': 'Crítica'},
                      {'value': 'warning', 'label': 'Advertencia'},
                      {'value': 'info', 'label': 'Informativa'},
                    ],
                    onChanged: onSeverityChanged,
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
