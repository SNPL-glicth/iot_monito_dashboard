import 'package:flutter/material.dart';
import '../../../crm/data/models/crm_alerts_models.dart';
import 'alerts_hub_helpers.dart';
import '../../../../../core/theme/design_colors.dart';
import '../../../../../core/theme/design_spacing.dart';
import '../../../../../core/theme/design_text_styles.dart';


/// Lista de alertas historial con filtrado por sensor e infinite scroll.
class AlertListView extends StatelessWidget {
  const AlertListView({
    super.key,
    required this.items,
    required this.selectedSensorId,
    required this.onFilterBySensor,
    required this.onAlertTap,
    this.scrollController,
    this.footer,
  });

  final List<CrmAlertHistoryItem> items;
  final String? selectedSensorId;
  final void Function(String? sensorId, String? sensorName) onFilterBySensor;
  final void Function(CrmAlertHistoryItem alert) onAlertTap;
  final ScrollController? scrollController;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: scrollController,
      padding: EdgeInsets.all(DesignSpacing.lg),
      itemCount: items.length + (footer != null ? 1 : 0),
      itemBuilder: (context, index) {
        if (footer != null && index == items.length) {
          return footer!;
        }
        final a = items[index];
        final color = AlertsHubHelpers.severityColor(a.severity);
        final icon = AlertsHubHelpers.severityIcon(a.severity);

        final threshold = (a.thresholdName ?? '').trim().isEmpty
            ? 'Alerta de umbral'
            : a.thresholdName!.trim();
        final when = a.triggeredAt;

        return Card(
          margin: EdgeInsets.only(bottom: DesignSpacing.sm),
          child: ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(DesignRadius.sm),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            title: Text(
              '$threshold (${a.severity.toUpperCase()})',
              style: DesignTextStyles.bodyText,
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: DesignSpacing.xs),
                Row(
                  children: [
                    Icon(Icons.device_hub, size: 12, color: DesignColors.textSecondary),
                    SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        a.deviceName,
                        style: TextStyle(color: DesignColors.textPrimary, fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 2),
                Row(
                  children: [
                    Icon(Icons.sensors, size: 12, color: DesignColors.textSecondary),
                    SizedBox(width: 4),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          if (a.sensorId != null && a.sensorId!.isNotEmpty) {
                            onFilterBySensor(a.sensorId, a.sensorName ?? 'Sensor');
                          }
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
                              child: Text(
                                a.sensorName ?? 'Sensor',
                                style: TextStyle(
                                  color: selectedSensorId == a.sensorId
                                      ? Colors.tealAccent
                                      : DesignColors.textPrimary,
                                  fontSize: 12,
                                  decoration: TextDecoration.underline,
                                  decorationColor: DesignColors.textDim,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (selectedSensorId != a.sensorId) ...[
                              SizedBox(width: 4),
                              Icon(
                                Icons.filter_list,
                                size: 10,
                                color: Colors.white.withValues(alpha: 0.4),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 2),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 12, color: DesignColors.textSecondary),
                    SizedBox(width: 4),
                    Text(
                      when,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 11,
                      ),
                    ),
                    const Spacer(),
                    AlertsHubHelpers.buildStatusBadge(a.status, color),
                  ],
                ),
              ],
            ),
            trailing: const Icon(Icons.chevron_right, color: DesignColors.textDim),
            onTap: () => onAlertTap(a),
          ),
        );
      },
    );
  }
}
