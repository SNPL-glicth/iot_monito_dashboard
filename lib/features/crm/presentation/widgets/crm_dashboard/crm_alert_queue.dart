import 'package:flutter/material.dart';

import '../../../../../core/theme/design_colors.dart';
import '../../../../../core/theme/design_spacing.dart';
import '../../../../../core/theme/design_text_styles.dart';
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
      return Text('No hay alertas activas/ack en el rango.',
          style: DesignTextStyles.bodyText);
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final a = items[index];
        final color = CrmDashboardHelpers.severityColor(a.severity);

        return Container(
          margin: EdgeInsets.only(bottom: DesignSpacing.sm),
          decoration: BoxDecoration(
            color: DesignColors.surface,
            border: Border.all(color: DesignColors.border, width: 0.5),
            borderRadius: BorderRadius.circular(DesignRadius.lg),
          ),
          child: ListTile(
            leading: Icon(Icons.warning_amber_rounded, color: color),
            title: Text(
              '${a.thresholdName} (${a.severity.toUpperCase()})',
              style: DesignTextStyles.bodyText,
            ),
            subtitle: Text(
              'Dispositivo: ${a.deviceName}\n'
              'Sensor: ${a.sensorName ?? '-'}\n'
              'Valor: ${a.triggeredValue} · Estado: ${a.status}\n'
              'Fecha: ${CrmDashboardHelpers.formatDateTime(a.triggeredAt)}',
              style: DesignTextStyles.bodyText,
            ),
          ),
        );
      },
    );
  }
}
