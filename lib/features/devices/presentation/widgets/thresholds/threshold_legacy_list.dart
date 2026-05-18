import 'package:flutter/material.dart';

import '../../../../../features/monitoring/data/models/monitoring_view_models.dart';
import '../../../../../features/monitoring/presentation/styles/dashboard_styles.dart';

/// Lista expandible de umbrales legacy.
class ThresholdLegacyList extends StatelessWidget {
  const ThresholdLegacyList({
    super.key,
    required this.thresholds,
    required this.canEdit,
    required this.onEdit,
    required this.onHistory,
    required this.formatRule,
  });

  final List<AlertThresholdViewModel> thresholds;
  final bool canEdit;
  final void Function(AlertThresholdViewModel) onEdit;
  final void Function(AlertThresholdViewModel) onHistory;
  final String Function(AlertThresholdViewModel) formatRule;

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      tilePadding: const EdgeInsets.symmetric(horizontal: 12),
      title: Text('Umbrales legacy (alert_thresholds)', style: DashboardTextStyles.deviceTitle),
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              if (thresholds.isEmpty)
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Sin límites legacy configurados.',
                    style: DashboardTextStyles.sensorMeta,
                  ),
                )
              else ...[
                if (thresholds.length > 1)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 10),
                    child: Text(
                      'Aviso: hay más de un límite legacy activo para este sensor (dato legado).',
                      style: DashboardTextStyles.sensorMeta,
                    ),
                  ),
                ...thresholds.map((t) {
                  final rule = formatRule(t);
                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.rule, color: Colors.white70),
                      title: Text(t.name, style: DashboardTextStyles.sensorTitle),
                      subtitle: Text(
                        'Severidad: ${t.severity}\n$rule',
                        style: DashboardTextStyles.sensorMeta,
                      ),
                      trailing: Wrap(
                        spacing: 6,
                        children: [
                          IconButton(
                            onPressed: () => onHistory(t),
                            icon: const Icon(Icons.history),
                            tooltip: 'Ver historial',
                          ),
                          if (canEdit)
                            IconButton(
                              onPressed: () => onEdit(t),
                              icon: const Icon(Icons.edit_outlined),
                              tooltip: 'Editar legacy',
                            ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
