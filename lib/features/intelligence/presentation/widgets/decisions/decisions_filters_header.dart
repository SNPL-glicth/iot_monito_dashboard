import 'package:flutter/material.dart';

import '../../../../../features/monitoring/presentation/styles/dashboard_styles.dart';
import '../intelligence_decisions_helpers.dart';

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
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: DashboardColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.task_alt_rounded,
                  color: DashboardColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text('Decisiones', style: DashboardTextStyles.sectionHeader),
            ],
          ),
          if (lastUpdated != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                IntelligenceDecisionsHelpers.formatLastUpdated(lastUpdated),
                style: DashboardTextStyles.smallLabel,
              ),
            ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: ModernCardDecoration.elevated(),
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
                const SizedBox(width: 12),
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
