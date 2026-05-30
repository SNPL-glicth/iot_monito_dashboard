import 'package:flutter/material.dart';
import '../../../crm/data/models/crm_alerts_models.dart';
import '../../../crm/data/models/pagination/crm_pagination_models.dart';
import 'alerts_hub_helpers.dart';
import 'alerts_hub_widgets.dart';
import 'alert_list_view.dart';
import '../../../../../core/theme/design_spacing.dart';
import '../../../../../core/theme/design_text_styles.dart';


/// FutureBuilder para cargar y mostrar alertas con filtros y resumen.
class AlertFutureBuilder extends StatelessWidget {
  const AlertFutureBuilder({
    super.key,
    required this.future,
    required this.selectedSensorId,
    required this.selectedSensorName,
    required this.onFilterBySensor,
    required this.onClearFilter,
    required this.onRefresh,
    required this.onAlertTap,
  });

  final Future<CrmPagedResponse<CrmAlertHistoryItem>> future;
  final String? selectedSensorId;
  final String? selectedSensorName;
  final void Function(String? sensorId, String? sensorName) onFilterBySensor;
  final VoidCallback onClearFilter;
  final VoidCallback onRefresh;
  final void Function(CrmAlertHistoryItem alert) onAlertTap;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<CrmPagedResponse<CrmAlertHistoryItem>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Error cargando alertas: ${snapshot.error}',
                  style: DesignTextStyles.bodyText,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: DesignSpacing.lg),
                ElevatedButton.icon(
                  onPressed: onRefresh,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reintentar'),
                ),
              ],
            ),
          );
        }

        var items = snapshot.data?.items ?? const <CrmAlertHistoryItem>[];

        items = List.from(items)..sort((a, b) {
          final severityCompare = AlertsHubHelpers.severityRank(a.severity).compareTo(AlertsHubHelpers.severityRank(b.severity));
          if (severityCompare != 0) return severityCompare;
          return b.triggeredAt.compareTo(a.triggeredAt);
        });

        if (items.isEmpty) {
          return const AlertEmptyState();
        }

        final criticalCount = items.where((a) => a.severity.toLowerCase() == 'critical').length;
        final warningCount = items.where((a) => a.severity.toLowerCase() == 'warning').length;

        return Column(
          children: [
            if (selectedSensorId != null)
              AlertSensorFilter(
                sensorName: selectedSensorName ?? 'Sensor',
                onClear: onClearFilter,
              ),
            if (criticalCount > 0 || warningCount > 0)
              AlertSummary(
                criticalCount: criticalCount,
                warningCount: warningCount,
                totalCount: items.length,
              ),
            Expanded(
              child: AlertListView(
                items: items,
                selectedSensorId: selectedSensorId,
                onFilterBySensor: onFilterBySensor,
                onAlertTap: onAlertTap,
              ),
            ),
          ],
        );
      },
    );
  }
}
