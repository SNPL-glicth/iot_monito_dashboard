import 'package:flutter/material.dart';

import '../../../../../core/theme/design_colors.dart';
import '../../../../../core/theme/design_spacing.dart';
import '../../../../../core/theme/design_text_styles.dart';
import '../crm_dashboard_helpers.dart';
import '../../../data/models/crm_dashboard_models.dart';

/// Lista de eventos recientes del dashboard CRM.
class CrmRecentEvents extends StatelessWidget {
  const CrmRecentEvents({
    super.key,
    required this.items,
  });

  final List<CrmRecentEvent> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Text('Sin eventos en el rango.', style: DesignTextStyles.bodyText);
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final e = items[index];
        final color = CrmDashboardHelpers.severityColor(e.severity);
        final payload = (e.payload ?? '').trim();

        final subtitleLines = <String>[
          'Dispositivo: ${e.deviceName}',
          'Tipo: ${e.eventType} · Severidad: ${e.severity}',
          'Fecha: ${CrmDashboardHelpers.formatDateTime(e.occurredAt)}',
          if (payload.isNotEmpty) 'Detalle: $payload',
        ];

        return Container(
          margin: EdgeInsets.only(bottom: DesignSpacing.sm),
          decoration: BoxDecoration(
            color: DesignColors.surface,
            border: Border.all(color: DesignColors.border, width: 0.5),
            borderRadius: BorderRadius.circular(DesignRadius.lg),
          ),
          child: ListTile(
            leading: Icon(Icons.event_note, color: color),
            title: Text(e.title, style: DesignTextStyles.bodyText),
            subtitle: Text(
              subtitleLines.join('\n'),
              style: DesignTextStyles.bodyText,
            ),
          ),
        );
      },
    );
  }
}
