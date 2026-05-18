import 'package:flutter/material.dart';

import '../../../../monitoring/presentation/styles/dashboard_styles.dart';
import '../crm_dashboard_helpers.dart';
import '../../../data/models/crm_dashboard_models.dart';

/// Lista de alertas activas del dashboard CRM.
class CrmAlertQueue extends StatelessWidget {
  const CrmAlertQueue({
    super.key,
    required this.items,
  });

  final List<CrmAlertQueueItem> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Text(
        'No hay alertas activas/ack en el rango.',
        style: DashboardTextStyles.sensorMeta,
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final a = items[index];
        final color = CrmDashboardHelpers.severityColor(a.severity);

        return Card(
          child: ListTile(
            leading: Icon(Icons.warning_amber_rounded, color: color),
            title: Text(
              '${a.thresholdName} (${a.severity.toUpperCase()})',
              style: DashboardTextStyles.alertTitle,
            ),
            subtitle: Text(
              'Dispositivo: ${a.deviceName}\n'
              'Sensor: ${a.sensorName ?? '-'}\n'
              'Valor: ${a.triggeredValue} · Estado: ${a.status}\n'
              'Fecha: ${CrmDashboardHelpers.formatDateTime(a.triggeredAt)}',
              style: DashboardTextStyles.alertText,
            ),
          ),
        );
      },
    );
  }
}
